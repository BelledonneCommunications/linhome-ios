/*
* Copyright (c) 2010-2020 Belledonne Communications SARL.
*
* This file is part of linhome
*
* This program is free software: you can redistribute it and/or modify
* it under the terms of the GNU General Public License as published by
* the Free Software Foundation, either version 3 of the License, or
* (at your option) any later version.
*
* This program is distributed in the hope that it will be useful,
* but WITHOUT ANY WARRANTY; without even the implied warranty of
* MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
* GNU General Public License for more details.
*
* You should have received a copy of the GNU General Public License
* along with this program. If not, see <http://www.gnu.org/licenses/>.
*/


// Adapted from Linphone's ProviderDelegate and CallManager (release/5.0).
// Keep CallKit reporting separate from Linhome's existing video/door-action views.
import UIKit
import CallKit
import AVFoundation
import linphonesw

class NativeIncomingCallManager: NSObject, CXProviderDelegate {
	private class IncomingCall {
		let uuid = UUID()
		var call: Call
		var reported = false
		var endReason: CXCallEndedReason?
		var answerAction: CXAnswerCallAction?
		var connected = false

		init(_ call: Call) { self.call = call }
	}

	private let provider: CXProvider
	private var incoming = [String: IncomingCall]()

	override init() {
		let configuration = CXProviderConfiguration(localizedName: Texts.appName)
		configuration.supportsVideo = true
		configuration.maximumCallGroups = 1
		configuration.maximumCallsPerCallGroup = 1
		configuration.supportedHandleTypes = [.generic]
		provider = CXProvider(configuration: configuration)
		super.init()
		provider.setDelegate(self, queue: .main)
	}

	func onCallStateChanged(core: Core, call: Call, state: Call.State) {
		// OutgoingInit may precede allocation of the SIP Call-ID.
		if state == .OutgoingInit {
			if incoming.isEmpty { core.callkitEnabled = false }
			return
		}
		guard let callId = call.callLog?.callId, !callId.isEmpty else { return }
		switch state {
		case .PushIncomingReceived, .IncomingReceived, .IncomingEarlyMedia:
			core.callkitEnabled = true
			if let entry = incoming[callId] {
				entry.call = call
				if entry.endReason == nil {
					provider.reportCall(with: entry.uuid, updated: update(for: call))
					answerIfReady(entry)
				}
			} else {
				let entry = IncomingCall(call)
				incoming[callId] = entry
				// Report synchronously from the SDK's PushIncomingReceived callback.
				// Waiting for the SIP INVITE first would violate PushKit's CallKit deadline.
				provider.reportNewIncomingCall(with: entry.uuid, update: update(for: call)) { [weak self] error in
					DispatchQueue.main.async {
						guard let self = self else { return }
						entry.reported = true
						if let error = error {
							Log.warn("CallKit could not present incoming call: \(error.localizedDescription)")
							entry.answerAction?.fail()
							self.incoming.removeValue(forKey: callId)
							// Busy rejects only this branch, leaving other household devices ringing.
							try? entry.call.decline(reason: .Busy)
						} else if let reason = entry.endReason {
							self.finish(callId: callId, entry: entry, reason: reason)
						} else {
							self.provider.reportCall(with: entry.uuid, updated: self.update(for: entry.call))
						}
					}
				}
			}
		case .Connected, .StreamsRunning:
			incoming[callId]?.connected = true
		case .End, .Error, .Released:
			guard let entry = incoming[callId] else { return }
			let reason: CXCallEndedReason
			if call.callLog?.status == .AcceptedElsewhere {
				reason = .answeredElsewhere
			} else if call.callLog?.status == .DeclinedElsewhere {
				reason = .declinedElsewhere
			} else if state == .Error {
				reason = .failed
			} else {
				reason = entry.connected ? .remoteEnded : .unanswered
			}
			finish(callId: callId, entry: entry, reason: reason)
		default:
			break
		}
	}

	private func update(for call: Call) -> CXCallUpdate {
		let update = CXCallUpdate()
		let address = call.remoteAddress
		let device = address.flatMap { DeviceStore.it.findDeviceByAddress(address: $0) }
		update.remoteHandle = CXHandle(type: .generic, value: address?.asStringUriOnly() ?? Texts.appName)
		update.localizedCallerName = device?.name ?? address?.displayName ?? Texts.get("notif_incoming_call")
		update.hasVideo = call.remoteParams?.videoEnabled ?? false
		update.supportsHolding = false
		update.supportsGrouping = false
		update.supportsUngrouping = false
		update.supportsDTMF = false // Use the existing configured door-action buttons in Linhome.
		return update
	}

	private func finish(callId: String, entry: IncomingCall, reason: CXCallEndedReason) {
		guard incoming[callId] === entry else { return }
		entry.answerAction?.fail()
		entry.answerAction = nil
		entry.endReason = entry.endReason ?? reason
		// The caller may cancel before reportNewIncomingCall's completion executes.
		guard entry.reported else { return }
		provider.reportCall(with: entry.uuid, endedAt: Date(), reason: entry.endReason ?? reason)
		incoming.removeValue(forKey: callId)
	}

	private func answerIfReady(_ entry: IncomingCall) {
		guard let action = entry.answerAction, entry.endReason == nil,
			[Call.State.IncomingReceived, .IncomingEarlyMedia].contains(entry.call.state) else { return }
		entry.answerAction = nil
		Core.get().configureAudioSession()
		if entry.call.extendedAccept(core: Core.get()) {
			entry.connected = true
			action.fulfill()
		} else {
			action.fail()
			try? entry.call.terminate()
		}
	}

	func provider(_ provider: CXProvider, perform action: CXAnswerCallAction) {
		guard let entry = incoming.values.first(where: { $0.uuid == action.callUUID && $0.endReason == nil }) else {
			action.fail()
			return
		}
		entry.answerAction = action
		// Answer can arrive before SIP registration/INVITE. Keep it pending until IncomingReceived.
		answerIfReady(entry)
	}

	func provider(_ provider: CXProvider, perform action: CXEndCallAction) {
		guard let pair = incoming.first(where: { $0.value.uuid == action.callUUID }) else {
			action.fail()
			return
		}
		let entry = pair.value
		entry.answerAction?.fail()
		entry.answerAction = nil
		if [Call.State.IncomingReceived, .IncomingEarlyMedia].contains(entry.call.state) {
			try? entry.call.decline(reason: .Declined)
		} else {
			try? entry.call.terminate()
		}
		finish(callId: pair.key, entry: entry, reason: .remoteEnded)
		action.fulfill()
	}

	func provider(_ provider: CXProvider, perform action: CXSetMutedCallAction) {
		guard incoming.values.contains(where: { $0.uuid == action.callUUID && $0.endReason == nil }) else {
			action.fail()
			return
		}
		Core.get().micEnabled = !action.isMuted
		action.fulfill()
	}

	func provider(_ provider: CXProvider, timedOutPerforming action: CXAction) {
		if let pair = incoming.first(where: { $0.value.uuid == (action as? CXCallAction)?.callUUID }) {
			pair.value.answerAction = nil
			try? pair.value.call.terminate()
			finish(callId: pair.key, entry: pair.value, reason: .failed)
		}
		action.fail()
	}

	func providerDidReset(_ provider: CXProvider) {
		let entries = Array(incoming.values)
		incoming.removeAll()
		for entry in entries {
			entry.answerAction?.fail()
			try? entry.call.terminate()
		}
		Core.get().activateAudioSession(activated: false)
	}

	func provider(_ provider: CXProvider, didActivate audioSession: AVAudioSession) {
		Core.get().activateAudioSession(activated: true)
	}

	func provider(_ provider: CXProvider, didDeactivate audioSession: AVAudioSession) {
		Core.get().activateAudioSession(activated: false)
	}
}
