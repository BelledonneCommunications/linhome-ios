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


import UserNotifications
import linphonesw
import Firebase


class NotificationService: UNNotificationServiceExtension {
	var contentHandler: ((UNNotificationContent) -> Void)?
	var bestAttemptContent: UNMutableNotificationContent?
	var waitForACall = true
	var finishedHere = false
	var candidateCall:Call?
	var coreDelegateStub : CoreDelegateStub?
	var callManagingComponentObserver: NSKeyValueObservation?
	let userDefaults = UserDefaults(suiteName: Config.appGroupName)!
	private var callDelegate :  CallDelegateStub?
	private let extensionCutoffTimeSec = 20
		
	override func didReceive(_ request: UNNotificationRequest, withContentHandler contentHandler: @escaping (UNNotificationContent) -> Void) {
		
		
		HistoryEventStore.refresh()
		
		FirebaseApp.configure()
		
		self.contentHandler = contentHandler
		bestAttemptContent = (request.content.mutableCopy() as? UNMutableNotificationContent)
		Log.info("didReceive \(bestAttemptContent?.userInfo.debugDescription ?? "nil")")
		
		guard let notifCallId = request.content.userInfo["call-id"] as! String? else {
			Log.error("No call Id in notification")
			return
		}
					
				
		bestAttemptContent?.title = Texts.get("notif_incoming_call")
		bestAttemptContent?.body = ""
		
		if let aps = request.content.userInfo["aps"] as? [String: Any], let alert = aps["alert"] as? [String: Any], let locKey = alert["loc-key"] as? String, locKey == "Missing call" {
			bestAttemptContent?.title = Texts.get("notif_missed_call_title")
			contentHandler(bestAttemptContent!)
			return
		}
		
		if let lastNotifFime = userDefaults.object(forKey: "notification_time_"+notifCallId) as? Date {
			Log.info("[NotificationService] - subsequent push notification received for call Id \(notifCallId) last notif time was : \(lastNotifFime)")
			bestAttemptContent?.body = Texts.get(userDefaults.bool(forKey: "has_video_"+notifCallId) ? "notif_incoming_call_video" : "notif_incoming_call_audio")
			bestAttemptContent?.title = userDefaults.string(forKey: "notification_title_"+notifCallId) ?? ""
			bestAttemptContent?.badge = NSNumber(value: userDefaults.integer(forKey: "notification_badge_"+notifCallId))
			bestAttemptContent?.sound=UNNotificationSound.init(named: UNNotificationSoundName.init("bell.caf"))
			bestAttemptContent?.categoryIdentifier = Config.earlymediaContentExtensionCagetoryIdentifier
			if (lastNotifFime.timeIntervalSince1970 + Double(Config.pushNotificationsInterval) > Date().timeIntervalSince1970 ) {
				let interval = UInt32(Double(Config.pushNotificationsInterval) - (Date().timeIntervalSince1970-lastNotifFime.timeIntervalSince1970))
				Log.info("[NotificationService] subsequent notif, about to sleep \(interval)")
				usleep(interval*1_000_000)
				Log.info("[NotificationService] subsequent notif, slept \(interval)")
			}
			userDefaults.set(Date(), forKey: "notification_time_"+notifCallId)
			contentHandler(bestAttemptContent!)
			return
		}
	
		userDefaults.set(Date(), forKey: "notification_time_"+notifCallId)
	
		coreDelegateStub = CoreDelegateStub(onCallStateChanged : { (lc: linphonesw.Core, call: linphonesw.Call, cstate: linphonesw.Call.State, message: String) -> Void in
			
			Log.info("CoreDelegateStub - onCallStateChanged : \(cstate)")
			
			guard let callId = call.callLog?.callId, callId == notifCallId else {
				Log.info("ignoring a onCallStateChanged for a call that is not related to that notification. update:\(call.callLog?.callId ?? "nil") notificaiton:\(request.content.userInfo["call-id"] ?? "nil")")
				return
			}
			if (cstate == linphonesw.Call.State.IncomingReceived) {
				self.candidateCall = call
				self.waitForACall = false
			}
			
			call.remoteParams.map{
				if ($0.videoEnabled) {
					call.requestNotifyNextVideoFrameDecoded()
				}
			}
			
			if (cstate == linphonesw.Call.State.End) {
				self.waitForACall = false
				self.finishedHere = true
				if (call.isRecording) {
					call.stopRecording()
					HistoryEventStore.it.sync()
				}
				Log.info("CoreDelegateStub - Call ended here ")
			}
		})
		
		userDefaults.set(Date(), forKey: "lastpushtime")
		if (userDefaults.bool(forKey: "appactive")) {
			Log.info("Application is active. Ignoring push notification.")
			userDefaults.set(Date(), forKey: "notification_time_"+notifCallId)
			contentHandler(bestAttemptContent!)
			return
		}
		
		Call.takeOwnerShip()
		
		guard let core = Core.getNewOne(autoIterate: false) else {
			Log.error("unable to create a executor core.")
			Call.releaseOwnerShip()
			userDefaults.set(Date(), forKey: "notification_time_"+notifCallId)
			contentHandler(bestAttemptContent!)
			return
		}
		core.disableVP8() // Two heavy to run in ServiceExtension

		core.addDelegate(delegate: coreDelegateStub!)
		try?core.extendedStart()
		
		// Wait for a call to showup
		
		var i = 0
		while (waitForACall && i < extensionCutoffTimeSec*50 ) { // wait 25 second or call ready to handle - Timers do not work in UNNotificationServiceExtension (normal way of iterating the linphone core, but they work in UNNotificationContentExtension. So here iteration is done as loop). Wait 25 econds max not to be killed.
			core.iterate()
			usleep(20000)
			i+=1
		}
		guard let bestAttemptContent = self.bestAttemptContent else {
			Log.info("Best attempt comptent is null - stopping")
			core.stop()
			Call.releaseOwnerShip()
			return
		}
		guard let call = self.candidateCall else {
			Log.info("Candidate call is null stopping")
			bestAttemptContent.title = Texts.get("notif_missed_call_title")
			Call.releaseOwnerShip()
			userDefaults.set(Date(), forKey: "notification_time_"+notifCallId)
			contentHandler(bestAttemptContent)
			core.stop()
			return
		}
		
		let hasVideo = call.remoteParams?.videoEnabled ?? false
		
		bestAttemptContent.body =  Texts.get(call.state == .End ? "notif_missed_call_title" : hasVideo ? "notif_incoming_call_video" : "notif_incoming_call_audio")
		userDefaults.set(hasVideo,forKey: "has_video_"+notifCallId)
		if let name = DeviceStore.it.findDeviceByAddress(address: call.remoteAddress?.asString())?.name {
			bestAttemptContent.title = name
		} else {
			bestAttemptContent.title = call.remoteAddress?.asString() ?? ""
		}
		userDefaults.set(bestAttemptContent.title, forKey: "notification_title_"+notifCallId)

		
		callDelegate =  CallDelegateStub(onNextVideoFrameDecoded : { (call: linphonesw.Call) -> Void in
				if let event = call.callLog?.getHistoryEvent() {
					if (!event.hasVideo) {
						event.hasVideo = true
						event.persist()
					}
					if (!event.hasMediaThumbnail()) {
						try? call.takeVideoSnapshot(filePath: event.mediaThumbnailFileName)
					}
				}
		})
		call.addDelegate(delegate: callDelegate!)
		
		
		call.extendedAcceptEarlyMedia(core:core)
		bestAttemptContent.sound=UNNotificationSound.init(named: UNNotificationSoundName.init("bell.caf"))
		bestAttemptContent.categoryIdentifier = Config.earlymediaContentExtensionCagetoryIdentifier
		bestAttemptContent.badge = NSNumber(value: core.missedCount() + 1)
		userDefaults.set(bestAttemptContent.badge, forKey: "notification_badge_"+notifCallId)
		Log.info("About to send the notification to contentHandler")
		userDefaults.set(Date(), forKey: "notification_time_"+notifCallId)
		contentHandler(bestAttemptContent)
		Log.info("Sent the notification to contentHandler")
		
		// Wait for the call to be picked up elsewhere (content extension or app) or terminate or extension time out
		while (i < extensionCutoffTimeSec*50 &&
				Call.hasOwnerShip() &&
				!Call.ownerShipRequessted() &&
			   !self.finishedHere
		) {
			core.iterate()
			usleep(20000)
			i+=1
		}
		Log.info("Finished waiting - stopping core, stopping recording and declining with IO error and release ownership")
		if (call.isRecording) {
			call.stopRecording()
			HistoryEventStore.it.sync()
		}
		core.removeDelegate(delegate: self.coreDelegateStub!)
		call.removeDelegate(delegate: callDelegate!)

		try?call.decline(reason: .IOError)
		Call.releaseOwnerShip()
		core.stop()
		
	}
	
	override func serviceExtensionTimeWillExpire() {
		waitForACall = false
	}
}


