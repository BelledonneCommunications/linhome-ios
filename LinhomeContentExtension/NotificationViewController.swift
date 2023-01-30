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


import UIKit
import UserNotifications
import UserNotificationsUI
import linphonesw
import Firebase

class NotificationViewController: UIViewController, UNNotificationContentExtension {

	@IBOutlet weak var videoPreview: UIView!
	@IBOutlet weak var activityIndicator: UIActivityIndicatorView!
	@IBOutlet weak var audioMedia: UIImageView!
	
	var coreDelegateStub : CoreDelegateStub? = nil
	var declined = false
	var core: Core?
	var call: Call?
	
	var actionTakenForCallIds:[String] = []
	
	override func viewDidLoad() {
		super.viewDidLoad()
	}
	
    func didReceive(_ notification: UNNotification) {
		HistoryEventStore.refresh()
		FirebaseApp.configure()
		Log.info("Notification received \(notification.request.content.userInfo)")
		guard let callId = notification.request.content.userInfo["call-id"] as! String? else {
			Log.warn("Missing call ID in push for Content Extension - ignoring")
			return
		}
		
		
		Call.requestOwnerShip()
		
		if (!Call.waitSyncForReleased(timeoutSec: 30)) {
			Log.warn("Timer out waiting for call to be released in Service Extension : \(callId)")
			return
		}
		Call.takeOwnerShip()

		
		
		declined = false
		startIt(request: notification.request)
    }

	
	func startIt(request : UNNotificationRequest) {
		if (core != nil) {
			return
		}
		coreDelegateStub = CoreDelegateStub(onCallStateChanged:  {(lc: linphonesw.Core, call: linphonesw.Call, cstate: linphonesw.Call.State, message: String)  in
			guard let callId = call.callLog?.callId, let notifCallId = request.content.userInfo["call-id"] as! String?, callId == notifCallId else {
				Log.info("Ignoring a onCallStateChanged for a call that is not related to that noficiation. update:\(call.callLog?.callId ?? "nil") notificaiton:\(request.content.userInfo["call-id"] ?? "nil")")
				return
			}
			let hasVideo = call.remoteParams?.videoEnabled ?? false
			self.audioMedia.isHidden = hasVideo
			if (!hasVideo) {
				self.activityIndicator.isHidden = true
			}
			if (cstate == linphonesw.Call.State.IncomingReceived) {
				if (!self.declined) {
					if (hasVideo) {
						lc.nativeVideoWindowId = UnsafeMutableRawPointer(Unmanaged.passUnretained(self.videoPreview).toOpaque()) // Set the video window
						call.extendedAcceptEarlyMedia(core: self.core!)
						self.activityIndicator.stopAnimating()
						self.activityIndicator.isHidden = true
					}
				}
				self.call = call
			}
			
			if (cstate == linphonesw.Call.State.Released || cstate == linphonesw.Call.State.End) {
				if #available(iOS 12.0, *) {
					self.extensionContext?.dismissNotificationContentExtension()
				}
			}
		})
		core = Core.getNewOne()
		core?.addDelegate(delegate: coreDelegateStub!)
		try?core?.extendedStart()
	}

	func didReceive(_ response: UNNotificationResponse, completionHandler completion: @escaping (UNNotificationContentExtensionResponseOption) -> Void) { // !! can be called before didReceive
		
		Log.info("User pressed action in notification (notification service handler): \(response.actionIdentifier)")

		guard let callId = response.notification.request.content.userInfo["call-id"] as! String?, let userDefaults = UserDefaults(suiteName: Config.appGroupName) else {
			Log.warn("Missing call ID for notification action or failed retrieving user defaults: \(response.actionIdentifier)")
			return
		}
		
	
		guard !actionTakenForCallIds.contains(callId) else {
			Log.warn("Action already taken for call Id : \(callId)")
			return
		}
		
		
		actionTakenForCallIds.append(callId)
				
		if (response.actionIdentifier == "accept") {
			Log.info("accept call button pressed for call Id : \(callId)")
			userDefaults.set(true, forKey: "accepted_calls_via_notif_\(callId)")
			self.end()
			completion(.dismissAndForwardAction)
			return
		}
		if (response.actionIdentifier == "decline") {
			self.declined = true
			startIt(request: response.notification.request)
			Log.info("decline call button pressed for call Id : \(callId)")
			userDefaults.set(true, forKey: "declined_calls_via_notif_\(callId)")
			var i = 0
			while (self.call == nil && i < 10*50) {
				Log.info("Waiting for the call \(callId) (max 10seconds) to decline it. time elapsed in ms \(i*50)")
				self.core?.iterate()
				usleep(20000)
				i+=1
			}
			self.end()
			completion(.dismiss)
			return
		}
	}

	
	override func viewWillDisappear(_ animated: Bool) {
		end()
		super.viewWillDisappear(animated)
	}
	
	func end() {
		core?.removeDelegate(delegate: coreDelegateStub!)
		call.map { it in
			if (it.params?.isRecording == true) {
				it.stopRecording()
				HistoryEventStore.it.sync()
			}
		}
		try?call?.decline(reason: declined ? .Declined : .IOError)
		Call.releaseOwnerShip()
		core?.extendedStop()
		core = nil
		call = nil
	}
	
}


