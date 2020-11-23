//
//  NotificationService.swift
//  LinhomeServiceExtension
//
//  Created by Christophe Deschamps on 04/03/2020.
//  Copyright © 2020 Belledonne communications. All rights reserved.
//

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
	private let extensionCutoffTimeSec = 29
	
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
				Log.info("CoreDelegateStub - Call ended here - removing notification")
				UNUserNotificationCenter.current().removeDeliveredNotifications(withIdentifiers: [request.identifier])
			}
		})
		
		userDefaults.set(Date(), forKey: "lastpushtime")
		if (userDefaults.bool(forKey: "appactive")) {
			Log.info("Application is active. Ignoring push notification.")
			contentHandler(bestAttemptContent!)
			return
		}
		
		Call.takeOwnerShip()
		
		guard let core = Core.getNewOne(autoIterate: false) else {
			Log.error("unable to create a executor core.")
			Call.releaseOwnerShip()
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
			contentHandler(bestAttemptContent)
			core.stop()
			return
		}
		
		let hasVideo = call.remoteParams?.videoEnabled ?? false
		
		bestAttemptContent.body =  Texts.get(call.state == .End ? "notif_missed_call_title" : hasVideo ? "notif_incoming_call_video" : "notif_incoming_call_audio")
		if let name = DeviceStore.it.findDeviceByAddress(address: call.remoteAddress?.asString())?.name {
			bestAttemptContent.title = name
		} else {
			bestAttemptContent.title = call.remoteAddress?.asString() ?? ""
		}
		
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
		Log.info("About to send the notification to contentHandler")
		contentHandler(bestAttemptContent)
		Log.info("Sent the notification to contentHandler")

		UIDevice.vibrate()
		
		// Wait for the call to be picked up elsewhere (content extension or app) or terminate or extension time out
		while (i < extensionCutoffTimeSec*50 &&
				Call.hasOwnerShip() &&
				!Call.ownerShipRequessted() &&
			   !self.finishedHere
		) {
			if (i % 100 == 0) {
				if (!UIDevice.ipad()) {
			 	UIDevice.vibrate()
				}
			}
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


