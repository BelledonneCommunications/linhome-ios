//
//  Log.swift
//  Linhome
//
//  Created by Christophe Deschamps on 24/02/2020.
//  Copyright © 2020 Belledonne communications. All rights reserved.
//

// Singleton instance that logs both info from the App and from the core, using the core log level. ([app] log_level parameter in linphonerc-factory-app

import UIKit
import os
import linphonesw
import linphone
import Firebase

class Log: LoggingServiceDelegate {
	
	static let instance = Log()
		
	var debugEnabled = CorePreferences.them.debugLog
	var service = LoggingService.Instance

	
	private init() {
		service.domain = Bundle.main.bundleIdentifier!
		Core.setLogCollectionPath(path: Factory.Instance.getDownloadDir(context: UnsafeMutablePointer<Int8>(mutating: (Config.appGroupName as NSString).utf8String)))
		Core.enableLogCollection(state: LogCollectionState.Enabled)
		setMask()
		LoggingService.Instance.addDelegate(delegate: self)
		
	}
	
	func setMask() {
		if (debugEnabled) {
			LoggingService.Instance.logLevelMask = UInt(LogLevel.Fatal.rawValue +  LogLevel.Error.rawValue +  LogLevel.Warning.rawValue + LogLevel.Message.rawValue +  LogLevel.Trace.rawValue +  LogLevel.Debug.rawValue)
		} else {
			LoggingService.Instance.logLevelMask = UInt(LogLevel.Fatal.rawValue +  LogLevel.Error.rawValue +  LogLevel.Warning.rawValue)
		}
	}
	
	let levelToStrings :[Int: String] =
		[LogLevel.Debug.rawValue:"Debug",
		 LogLevel.Trace.rawValue:"Trace",
		 LogLevel.Message.rawValue:"Message",
		 LogLevel.Warning.rawValue:"Warning",
		 LogLevel.Error.rawValue:"Error",
		 LogLevel.Fatal.rawValue:"Fatal"];
	
	let levelToOSleLogLevel :[Int: OSLogType] =
		[LogLevel.Debug.rawValue:.debug,
		 LogLevel.Trace.rawValue:.info,
		 LogLevel.Message.rawValue:.info,
		 LogLevel.Warning.rawValue:.error,
		 LogLevel.Error.rawValue:.error,
		 LogLevel.Fatal.rawValue:.fault];
	

	
	public class func debug(_ message:String) {
		if (instance.debugEnabled) {
			instance.output(message,Int(LinphoneLogLevelDebug.rawValue))
		}
		instance.service.debug(message: message)
	}
	public class func info(_ message:String) {
		instance.output(message,Int(LinphoneLogLevelMessage.rawValue))
		instance.service.message(message: message)
	}
	public class func warn(_ message:String) {
		instance.output(message,Int(LinphoneLogLevelWarning.rawValue))
		instance.service.warning(message: message)
	}
	public class func error(_ message:String) {
		instance.output(message,Int(LinphoneLogLevelError.rawValue))
		instance.service.error(message: message)
	}
	public class func fatal(_ message:String) {
		instance.output(message,Int(LinphoneLogLevelFatal.rawValue))
		instance.service.fatal(message: message)
	}
	
	private func output(_ message:String, _ level:Int, _ domain:String = Bundle.main.bundleIdentifier!) {
		let log = "[\(domain)][\(levelToStrings[level] ?? "Unkown")] \(message)\n"
		if #available(iOS 10.0, *) {
			os_log("%{public}@", type: levelToOSleLogLevel[level] ?? .info,log)
		} else {
			NSLog(log)
		}
#if !targetEnvironment(simulator)
		Crashlytics.crashlytics().log(log)
#endif
	}
		
	
	func onLogMessageWritten(logService: linphonesw.LoggingService, domain: String, level: linphonesw.LogLevel, message: String) {
		output(message,level.rawValue,domain)
	}

	
	public class func stackTrace() {
		Thread.callStackSymbols.forEach{print($0)}
	}
	
	
	// Debug CD
	
	public class func cdlog(_ message:String) {
		info("cdes>\(message)")
	}
		

}
