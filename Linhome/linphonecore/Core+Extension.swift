//
//  CoreManager.swift
//  Linhome
//
//  Created by Christophe Deschamps on 24/02/2020.
//  Copyright © 2020 Belledonne communications. All rights reserved.
//


// Core Extension provides a set of utilies to manage automatically a LinphoneCore no matter if it is from App or an extension.
// It is based on a singleton pattern and adds.

import UIKit
import linphonesw

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
	private static var _iterateTimer:Timer?
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
			let result = try Factory.Instance.createSharedCoreWithConfig(config: config, systemContext: nil, appGroupId: Config.appGroupName, mainCore: !runsInsideExtension() ) // Shared core makes use of the shared space in AppGroup.
			result.autoIterateEnabled = autoIterate
			result.disableChat(denyReason: .NotImplemented)
			try result.setStaticpicture(newValue: FileUtil.bundleFilePath("nowebcamCIF.jpg")!)
			if (!runsInsideExtension()) {
				result.ring = FileUtil.bundleFilePath("bell.caf")!
				result.nativeRingingEnabled = false
				result.ringDuringIncomingEarlyMedia = true
				result.audioDevices.forEach { device in
					if (device.hasCapability(capability: .CapabilityPlay)) {
						if (device.type == .Speaker) {
							do {
								try result.setRingerdevice(newValue: device.id)
								Log.info("Ringer device set to \(result.ringerDevice)")
							} catch {
								Log.error("Unable to set ringer device \(error)")
							}
						}
					}
				}
				result.setDefaultCodecs()
			}
			Log.debug("Created core with config:\n\(config.dump())")
			return result
		} catch  {
			Log.error("Unable to create core \(error)")
			return nil
		}
	}
	
	
	public func configurePushNotifications(_ deviceToken:Data) { // Should be called by the app when a push token is made abvailable. It adds it to the default proxy config.
		Core.pushToken = deviceToken.map { String(format: "%02.2hhx", $0) }.joined()
		Log.info("Push token received from device:"+Core.pushToken!)
		guard let p = defaultProxyConfig else {
			Log.warn("No default proxy config.")
			return
		}
		addPushTokenToProxyConfig(proxyConfig: p)
	}
	
	public func addPushTokenToProxyConfig(proxyConfig:ProxyConfig) { // UPdate the registration of a Proxy config with Push parameters.
		guard let pushToken = Core.pushToken else {
			Log.warn("No push token.")
			return
		}
		proxyConfig.edit()
		let services = "remote"
		let token = pushToken+":"+services
		#if DEBUG
			let pushEnvironment = ".dev"
		#else
			let pushEnvironment = ""
		#endif
		proxyConfig.contactUriParameters = "pn-provider=apns"+pushEnvironment+";pn-prid="+token+";pn-param="+Config.teamID+"."+Bundle.main.bundleIdentifier!+"."+services+";pn-silent=1;pn-msg-str=IM_MSG;pn-call-str=IC_MSG;"
		proxyConfig.contactParameters = ""
		try?proxyConfig.done()
	}
	

	public static func runsInsideExtension() -> Bool { // Tells wether it is run inside app extension or the main app. 
		let bundleUrl: URL = Bundle.main.bundleURL
		let bundlePathExtension: String = bundleUrl.pathExtension
		return bundlePathExtension == "appex"
	}
	
	func callLogsWithNonEmptyCallId() -> [CallLog] {
		return callLogs.filter { (callLog) -> Bool in
			callLog.callId != nil && callLog.callId.count > 0 // CallID can be null in early stage of call.
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
	
	
	func extendedStart() throws {
		try start()
		callLogsDatabasePath = FileUtil.sharedContainerUrl().path + "/call_logs.db" // Needed here to refresh cache of existing core after un update from another core
	}
	
	func disableVP8() {
		videoPayloadTypes.filter{ $0.description.lowercased().contains("vp8")}.forEach {let _ = $0.enable(enabled: false)}
	}
	
	
	func setDefaultCodecs () {
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
}

