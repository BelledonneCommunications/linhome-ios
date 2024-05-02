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




// Core Extension provides a set of utilies to manage automatically a LinphoneCore no matter if it is from App or an extension.
// It is based on a singleton pattern and adds.

import UIKit
import linphonesw
import DeviceGuru

struct CoreError: Error {
	let message: String
	init(_ message: String) {
		self.message = message
	}
	public var localizedDescription: String {
		return message
	}
}

extension Core {
	
	private static var _instance : Core?
	public static var iterateTimers:[String:Timer] = [:]
	public static var pushToken : String?
	
	
	public static func get(autoIterate:Bool = true) -> Core { // Singleton initiatlisation
		if (_instance == nil) {
			_instance = getNewOne(autoIterate: autoIterate)
		}
		return _instance!
	}
	
	public static func getNewOne(autoIterate:Bool = true) -> Core? { // Singleton initiatlisation
		do {
			let config = Config.get()
			config.setString(section: "sound", key: "local_ring", value: nil)
			config.setString(section:"storage", key: "call_logs_db_uri",value: FileUtil.sharedContainerUrl().path + "/call_logs.db")
			let core = try Factory.Instance.createSharedCoreWithConfig(config: config, systemContext: nil, appGroupId: Config.appGroupName, mainCore: !runsInsideExtension() ) // Shared core makes use of the shared space in AppGroup.
			core.autoIterateEnabled = autoIterate
			core.disableChat(denyReason: .NotImplemented)
			core.nativeRingingEnabled = false
			try core.setStaticpicture(newValue: FileUtil.bundleFilePath("nowebcamCIF.jpg")!)
			if (!runsInsideExtension()) {
				core.ringDuringIncomingEarlyMedia = true
				core.setDefaultCodecs()
			}
			Log.debug("Created core \(Core.getVersion) with config:\n\(config.dump())")
			if (autoIterate && runsInsideExtension()) { // Core not working yet with autoiterate in extensions
				Log.warn("Manually iterating inside contenet app extension")
				iterateTimers["\(core)"] = Timer.scheduledTimer(timeInterval: 0.02, target: core, selector: #selector(myIterate), userInfo: nil, repeats: true)
			}
			core.setUserAgent()
			core.pushNotificationEnabled = true
			core.callkitEnabled = false
			return core
		} catch  {
			Log.error("Unable to create core \(error)")
			return nil
		}
	}
	
	@objc func myIterate() {
		self.iterate()
	}
	
	
	public static func runsInsideExtension() -> Bool { // Tells wether it is run inside app extension or the main app.
		let bundleUrl: URL = Bundle.main.bundleURL
		let bundlePathExtension: String = bundleUrl.pathExtension
		return bundlePathExtension == "appex"
	}
	
	func callLogsWithNonEmptyCallId() -> [CallLog] {
		return callLogs.filter { (callLog) -> Bool in
			callLog.callId != nil && callLog.callId != nil // CallID can be null in early stage of call.
		}.reversed()
	}
	
	
	
	func missedCount() -> Int {
		var count = 0
		callLogsWithNonEmptyCallId().forEach { it in
			if (it.isNew()) {
				count += 1
			}
		}
		return count
	}
	
	
	func workAroundFindCallLogFromCallId(callId: String) -> CallLog? { // Work around as Core.get.
																																		 // findCallLogFromCallId(callId: callId) // KO https://bugs.linphone.org/view.php?id=7765
		return callLogs.filter {$0.callId == callId}[0] // OK
	}
	
	
	func extendedStop() {
		stop()
		Core.iterateTimers["\(self)"]?.invalidate()
		Core.iterateTimers["\(self)"] = nil
	}
	
	func disableVP8() {
		videoPayloadTypes.filter{ $0.description.lowercased().contains("vp8")}.forEach {let _ = $0.enable(enabled: false)}
	}
	
	
	
	func setDefaultCodecs () {
		
		audioPayloadTypes.forEach {
			Log.info("Payload Type : \($0.mimeType)")
		}
		audioPayloadTypes.forEach {
			if (!CorePreferences.availableAudioCodecs.contains($0.mimeType.lowercased())) {
				let _ = $0.enable(enabled: false)
			}
		}
		
		let userDefaults = UserDefaults(suiteName: Config.appGroupName)!
		
		if (userDefaults.bool(forKey: "default_codec_set")) {
			return
		}
		
		let defaultVideoActive = ["h264"]
		let defaultAudioActive = ["pcmu", "pcma", "opus"]
		videoPayloadTypes.forEach { let _ = $0.enable(enabled: defaultVideoActive.contains($0.mimeType.lowercased()))}
		audioPayloadTypes.forEach {let _ = $0.enable(enabled: defaultAudioActive.contains($0.mimeType.lowercased()))}
		try?config?.sync()
		userDefaults.setValue(true, forKey: "default_codec_set")
		
	}
	
	func setUserAgent() {
		let deviceName: String =  "\(DeviceGuruImplementation().hardware)"
		let appName: String = Bundle.main.appName()
		let iosVersion = UIDevice.current.systemVersion
		let userAgent = "\(appName) \(Bundle.main.desc())/\(deviceName) (\(iosVersion)) LinphoneSDK"
		let sdkVersion = Core.getVersion
		setUserAgent(name: userAgent, version: sdkVersion)
	}
		
	public func configurePushNotifications(_ deviceToken:Data) { // Should be called by the app when a push token is made abvailable. It adds it to the default proxy config.
		Core.pushToken = deviceToken.map { String(format: "%02.2hhx", $0) }.joined()
		Log.info("Push token received from device:"+Core.pushToken!)
		didRegisterForRemotePushWithStringifiedToken(deviceTokenStr: Core.pushToken)
		Core.get().accountList.forEach { account in
			account.configurePushNotificationParameters()
		}
	}
	
	// Early media phase - work around to avoid playing audio back to user, but still have the stream
	public func muteAudioPLayBack() {
			playbackGainDb = -1000.0
	}

	public func unMuteAudioPLayBack() {
			playbackGainDb = 0.0
	}
	
	func cleanHistory() {
		callLogs.forEach {it in
			if (it.callId != nil) {
				HistoryEventStore.it.removeHistoryEventByCallId(callId: it.callId!)
			}
			removeCallLog(callLog: it)
		}
	}
	
}

