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
import linphonesw
import UserNotifications
import Firebase
import AVFoundation
import SVProgressHUD

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, UNUserNotificationCenterDelegate {
	
	
	var window: UIWindow?
	
	var coreDelegate : CoreDelegateStub?
	var notificationAction : String?
	var hasBeenConnected : [String?] = []
	
	var coreState = MutableLiveData(linphonesw.GlobalState.Off)
	
	func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
				
		FirebaseApp.configure()
		
		UserDefaults.standard.set(false, forKey: "_UIConstraintBasedLayoutLogUnsatisfiable")
		
		_ = Customisation.it
		
		var fromPush = false
		if let userDefaults = UserDefaults(suiteName: Config.appGroupName) {
			if let lastPushTime = userDefaults.value(forKey: "lastpushtime") as! Date? {
				if let lastLaunchTime = userDefaults.value(forKey: "lastlaunchtime") as! Date? {
					if (lastPushTime > lastLaunchTime) {
						fromPush = true
						if (Date().timeIntervalSince1970 - lastPushTime.timeIntervalSince1970 < 5.0) { // Fresh push most likely waiting for core to start
							SVProgressHUD.show()
							DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(3)) {
								SVProgressHUD.dismiss()
							}
						}
					}
				}
			}
			userDefaults.set(Date(), forKey: "lastlaunchtime")
		}
		
		self.window = UIWindow(frame: UIScreen.main.bounds)
		window?.rootViewController = fromPush ? MainView() : Splash()
		window?.makeKeyAndVisible()
		
		coreDelegate = CoreDelegateStub(onCallStateChanged : { (lc: linphonesw.Core, call: linphonesw.Call, cstate: linphonesw.Call.State, message: String) -> Void in
			
			if (cstate == linphonesw.Call.State.End && UIApplication.shared.applicationState == .background) { // A call is terminated in background
				DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(1)) {
					self.applicationWillResignActive(UIApplication.shared)
				}
			}
						
			if (cstate == linphonesw.Call.State.Error && call.callLog?.dir == Call.Dir.Outgoing) {
				DispatchQueue.main.async {
					DialogUtil.error("unable_to_call_device")
				}
			}
			
			if ([Call.State.IncomingReceived, Call.State.IncomingEarlyMedia].contains(call.state)) {
				if let log = call.callLog, let userDefaults = UserDefaults(suiteName: Config.appGroupName), userDefaults.bool(forKey: "accepted_calls_via_notif_\(log.callId)") {
					Log.info("Accepting call Id in app (accept button pressed on notif) : \(log.callId)")
					call.extendedAccept(core: Core.get())
					return
				}
				if let log = call.callLog, let userDefaults = UserDefaults(suiteName: Config.appGroupName), userDefaults.bool(forKey: "declined_calls_via_notif_\(log.callId)") {
					Log.info("Declining call Id in app (accept button pressed on notif) : \(log.callId)")
					try?call.decline(reason: .Declined)
					return
				}
			}
			
			if (cstate == linphonesw.Call.State.IncomingReceived && !self.hasBeenConnected.contains(call.callLog?.callId ?? nil)) {
				DispatchQueue.main.async {
					NavigationManager.it.navigateTo(childClass: CallIncomingView.self, asRoot:false, argument:Pair(call, [Call.State.IncomingReceived, Call.State.IncomingEarlyMedia]))
				}
			}
			if (cstate == linphonesw.Call.State.Connected) {
				call.callLog.map{self.hasBeenConnected.append($0.callId)}
				DispatchQueue.main.async {
					NavigationManager.it.navigateTo(childClass: CallInProgressView.self, asRoot:false, argument:Pair(call, [Call.State.Connected, Call.State.StreamsRunning, Call.State.Updating, Call.State.UpdatedByRemote]))
				}
			}
			if (cstate == linphonesw.Call.State.OutgoingInit) {
				DispatchQueue.main.async {
					NavigationManager.it.navigateTo(childClass: CallOutgoingView.self, asRoot:false, argument:Pair(call, [Call.State.OutgoingRinging, Call.State.OutgoingProgress, Call.State.OutgoingInit, Call.State.OutgoingEarlyMedia]))
				}
			}
		}, onGlobalStateChanged: { (core: linphonesw.Core, state: linphonesw.GlobalState, message: String) -> Void in
			self.coreState.value = state
		})
		
		requestMirophonePermission()
		
	
		return true
	}
	
	func registerForPushNotifications() {
		let options: UNAuthorizationOptions = [.alert, .sound, .badge]
		UNUserNotificationCenter.current().requestAuthorization(options: options) {
			(didAllow, error) in
			if !didAllow {
				DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(Customisation.it.themeConfig.getInt(section: "arbitrary-values", key: "splash_display_duration_ms", defaultValue: 2000))) {
					DialogUtil.info("service_description")
				}
			} else {
				DispatchQueue.main.async {
					// Add the actions here as the user can take the decision to refuse/accept from the caller ID ( no need to wait to receive the call)
						let accept = UNNotificationAction(identifier: "accept", title: Texts.get("call_button_accept"), options: [.foreground, .authenticationRequired])
						let decline = UNNotificationAction(identifier: "decline", title: Texts.get("call_button_decline"), options: [.destructive])
						let earlyMediaCategoryIdentifier = UNNotificationCategory(identifier: Config.earlymediaContentExtensionCagetoryIdentifier,
																				  actions: [accept, decline],
																				  intentIdentifiers: [],
																				  options: .customDismissAction)
						UNUserNotificationCenter.current().setNotificationCategories([earlyMediaCategoryIdentifier])
						
					UIApplication.shared.registerForRemoteNotifications()
					UNUserNotificationCenter.current().delegate = self 
				}
			}
		}
	}
	
	func requestMirophonePermission() {
		AVAudioSession.sharedInstance().requestRecordPermission { granted in
			if !granted {
				DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(Customisation.it.themeConfig.getInt(section: "arbitrary-values", key: "splash_display_duration_ms", defaultValue: 2000))) {
					DialogUtil.info("record_audio_permission_denied_dont_ask_again")
				}
			}
		}
	}
	
	
	func application(_ application: UIApplication,
					 didRegisterForRemoteNotificationsWithDeviceToken
		deviceToken: Data) {
		Core.get().configurePushNotifications(deviceToken)
	}
	
	func applicationWillTerminate(_ application: UIApplication) {
		Core.get().stop()
		Call.releaseOwnerShip()
	}
	
	func application(_ application: UIApplication,
					 didFailToRegisterForRemoteNotificationsWithError
		error: Error) {
		Log.error("Failed regidstering to remote notifications \(error)")
	}
	
	func applicationDidBecomeActive(_ application: UIApplication) {
		HistoryEventStore.refresh()
		if let userDefaults = UserDefaults(suiteName: Config.appGroupName) {
			userDefaults.set(true, forKey: "appactive")
		}
		if (Core.get().callsNb == 0) {
			Call.requestAndWaitForOwnerShip()
		}
		try?Config.get().sync()
		registerForPushNotifications()
		Core.get().addDelegate(delegate: self.coreDelegate!)
		try?Core.get().extendedStart()
		Core.get().ensureRegistered()
		Core.get().enterForeground()
		NavigationManager.it.mainView?.tabbarViewModel.updateUnreadCount()
	}
	
	func applicationWillResignActive(_ application: UIApplication) {
		if let userDefaults = UserDefaults(suiteName: Config.appGroupName) {
			userDefaults.set(false, forKey: "appactive")
		}
		try?Config.get().sync()
		Core.get().enterBackground()
		if (Core.get().callsNb == 0) {
			Core.get().stop()
			Call.releaseOwnerShip()
			Core.get().removeDelegate(delegate: self.coreDelegate!)
		}
	}
	
	// UNUserNotificationCenterDelegate functions
	
	func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
		Log.info("willPresentnotification")
	}
	
	
	func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
		Log.info("didReceiveRemoteNotification")
	}
	
	// Actions on the notification here. If the user press too quick on the actions it comes directly here.
	
	func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
		Log.info("User pressed action in notification. (app) : \(response.actionIdentifier)")
		
		guard  let callId = response.notification.request.content.userInfo["call-id"] as! String?, let userDefaults = UserDefaults(suiteName: Config.appGroupName) else {
			Log.warn("No call ID found in notification or failed getting user detaults : \(response.actionIdentifier)")
			return
		}
			
		if response.actionIdentifier == "accept" {
			SVProgressHUD.show()
			DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(3)) {
				SVProgressHUD.dismiss()
			}
			Log.info("Accept call button pressed for call Id : \(callId)")
			userDefaults.set(true, forKey: "accepted_calls_via_notif_\(callId)")
		}
		if response.actionIdentifier == "decline"{
			Log.info("Decline call button pressed for call Id : \(callId)")
			userDefaults.set(true, forKey: "declined_calls_via_notif_\(callId)")
		}
		completionHandler()
	}
	
	
	
}
