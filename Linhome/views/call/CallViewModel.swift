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


import Foundation
import linphonesw
import AVFoundation


class CallViewModel : ViewModel {
	
	var call : Call
	var device : Device?
	let defaultDeviceType = DeviceTypes.it.defaultType
	
	var callState :  MutableLiveData<Call.State>
	let videoContent = MutableLiveData(false)
	let videoFullScreen = MutableLiveData(false)
	
	var speakerDisabled = MutableLiveData(true)
	let microphoneMuted = MutableLiveData(!Core.get().micEnabled)
	
	let videoSize = MutableLiveData<CGSize>()
	
	private var historyEvent : HistoryEvent
	private var callDelegate :  CallDelegateStub?
	
	init (call:Call)  {
		self.call = call
		historyEvent = call.callLog!.getHistoryEvent()
		self.device = DeviceStore.it.findDeviceByAddress(address: call.remoteAddress!)
		self.callState  = MutableLiveData(call.state)
		super.init()
		self.speakerDisabled.value = !speakerOn()
		if let event = call.callLog?.getHistoryEvent() {
			videoContent.value = event.hasVideo
		}
		
		callDelegate =  CallDelegateStub(
			onStateChanged : { (call: linphonesw.Call, state: linphonesw.Call.State, message: String) -> Void in
				self.historyEvent = call.callLog!.getHistoryEvent()
				self.fireActionsOnCallStateChanged(cstate: state)
				self.attemptSetDeviceThumbnail(cstate: state)
				call.remoteParams.map{
					if ($0.videoEnabled) {
						call.requestNotifyNextVideoFrameDecoded()
					}
				}
				if (state != .Released) {
					self.callState.value = state
				}
			},
			onNextVideoFrameDecoded : { (call: linphonesw.Call) -> Void in
				self.videoContent.value = true
				if let event = call.callLog?.getHistoryEvent() {
					if (!event.hasVideo) {
						event.hasVideo = true
						event.persist()
					}
					if (!event.hasMediaThumbnail()) {
						try? call.takeVideoSnapshot(filePath: event.mediaThumbnailFileName)
						DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(500)) {
							if (event.hasMediaThumbnail()) {
								if let image = UIImage(contentsOfFile: event.mediaThumbnailFileName), let remoteAddress = call.remoteAddress?.asStringUriOnly() {
									self.videoSize.value = image.size
									CorePreferences.them.config.setString(section: "detected_video_dimensions",key: remoteAddress,value: "\(image.size.width),\(image.size.height)")
								}
							}
						}
					}
				}
			})
		call.addDelegate(delegate: callDelegate!)
		fireActionsOnCallStateChanged(cstate: call.state)
		if let address = call.remoteAddress?.asStringUriOnly(){
			let storedDimensions = CorePreferences.them.config.getString(section: "detected_video_dimensions",key: address ,defaultString: "").components(separatedBy: ",")
			guard storedDimensions.count == 2 else {
				return
			}
			videoSize.value = CGSize(width:  Double(storedDimensions.first!)!,height: Double(storedDimensions.last!)!)
		}
	}
	
	
	func proceedCurrentCallState() {
		fireActionsOnCallStateChanged(cstate: call.state)
	}
	
	private func fireActionsOnCallStateChanged(cstate: Call.State) {
		if (cstate == Call.State.IncomingReceived) {
			call.extendedAcceptEarlyMedia(core: Core.get())
		}
		if (cstate == Call.State.StreamsRunning && call.callLog?.dir == Call.Dir.Outgoing && call.params?.isRecording != true) {
			call.startRecording()
		}
	}
	
	
	private func attemptSetDeviceThumbnail(cstate: Call.State) {
		if (cstate == Call.State.End) { // Copy call media file to device file if there is none or user needs last
			if (device != nil) {
				if (CorePreferences.them.showLatestSnapshot || !self.device!.hasThumbNail()) {
					if let event = call.callLog?.getHistoryEvent() {
						DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(500)) {
							if (event.hasMediaThumbnail()) {
								FileUtil.copy(event.mediaThumbnailFileName, self.device!.thumbNail, overWrite: true)
								DeviceStore.it.updatedSnapshotDeviceId.value = self.device!.id
							}
						}
						
					}
				}
			}
			
		}
	}
	
	func end()  {
		DispatchQueue.main.async {
			self.call.removeDelegate(delegate: self.callDelegate!)
		}
	}
	
	
	func decline() {
		try?call.decline(reason: .Declined)
	}
	
	func cancel() {
		try?call.terminate()
	}
	
	func terminate() {
		try?call.terminate()
	}
	
	
	func toggleMute() {
		let micEnabled = Core.get().micEnabled
		Core.get().micEnabled = !micEnabled
		microphoneMuted.value = micEnabled
	}
	
	
	func speakerOn() -> Bool {
		return AVAudioSession.sharedInstance().currentRoute.outputs.count > 0 && AVAudioSession.sharedInstance().currentRoute.outputs[0].portType == .builtInSpeaker
	}
	
	
	func toggleSpeaker() {
		do {
			if (speakerOn()) {
				try AVAudioSession.sharedInstance().overrideOutputAudioPort(.none)
				let buildinPort = AudioHelper.builtinAudioDevice()
				try AVAudioSession.sharedInstance().setPreferredInput(buildinPort)
				UIDevice.current.isProximityMonitoringEnabled = true
				speakerDisabled.value = true
			} else if (AudioHelper.speakerAllowed()){
				try AVAudioSession.sharedInstance().overrideOutputAudioPort(.speaker)
				UIDevice.current.isProximityMonitoringEnabled = false
				speakerDisabled.value = false
			}
		} catch {
			Log.error("Failed changing audio route: err \(error)")
		}
	}
	
	
	func toggleVideoFullScreen() {
		videoFullScreen.value = !videoFullScreen.value!
	}
	
	func performAction(action: Action) {
		do {
			try device.map { d in
				if (d.actionsMethodType == "method_dtmf_sip_info") {
					Core.get().useInfoForDtmf = true
					try call.sendDtmfs(dtmfs: action.code!)
				}
				if (d.actionsMethodType == "method_dtmf_rfc_4733") {
					Core.get().useRfc2833ForDtmf = true
					try call.sendDtmfs(dtmfs: action.code!)
				}
				if (d.actionsMethodType == "method_sip_message")  {
					let params = try Core.get().createDefaultChatRoomParams()
					params.groupEnabled = false
					params.encryptionEnabled = false
					var chatRoom = Core.get().searchChatRoom(params: params, localAddr: call.remoteAddress, remoteAddr: call.remoteAddress, participants: [call.remoteAddress!])
					if (chatRoom == nil)  {
						chatRoom = try Core.get().createChatRoom(params: params, localAddr: call.remoteAddress, participants: [call.remoteAddress!])
					}
					let message = try chatRoom?.createMessageFromUtf8(message: action.code!)
					message?.send()
				}
			}
		} catch {
			Log.error("Unable to perform action \(action) error is \(error)")
		}
	}
	
	func extendedAccept() {
		if (LinhomeCXCallObserver.it.ongoingCxCall.value == true) {
			DialogUtil.toast(textKey: "unable_to_accept_call_gsm_call_in_progress")
		} else {
			call.extendedAccept(core : Core.get())
		}
	}
	
	
}


