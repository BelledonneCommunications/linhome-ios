//
//  Config+Double.swift
//  Linhome
//
//  Created by Christophe Deschamps on 06/03/2020.
//  Copyright © 2020 Belledonne communications. All rights reserved.
//

import Foundation
import linphonesw

// Singleton that manages the Shared Config between app and app extension.

extension Config {

	private static var _instance : Config?

	public func getDouble(section:String, key:String, defaultValue:Double) -> Double {
		if (self.hasEntry(section: section, key: key) != 1) {
			return defaultValue
		}
		let stringValue = self.getString(section: section, key: key, defaultString: "")
		return Double(stringValue) ?? defaultValue
	}

	public static func get() -> Config {
		if (_instance == nil) {
			let factoryPath = FileUtil.bundleFilePath(Core.runsInsideExtension() ? "linphonerc-factory-appex" : "linphonerc-factory-app")!
			_instance =  Config.newForSharedCore(appGroupId: Config.appGroupName, configFilename: "linphonerc", factoryConfigFilename: factoryPath)!
		}
		return _instance!
	}
	
	public func getString(section:String, key:String) -> String? {
		return hasEntry(section: section, key: key) == 1  ? getString(section: section, key: key, defaultString: "") : nil
	}
	
	// Apple related
	static let appGroupName = "group.org.linhome" // Needs to be the same name in App Group (capabilities in ALL targets - app & extensions - content + service), can't be stored in the Config itself the Config needs this value to get created
	static let teamID = Config.get().getString(section: "app", key: "team_id", defaultString: "")
	static let earlymediaContentExtensionCagetoryIdentifier = Config.get().getString(section: "app", key: "extension_category", defaultString: "")
	
	// Default values in app
	static let domain = Config.get().getString(section: "app", key: "domain", defaultString: "")
	static let serveraddress =  Config.get().getString(section: "app", key: "server", defaultString: "")
	static let defaultUsername =  Config.get().getString(section: "app", key: "user", defaultString: "")
	static let defaultPass =  Config.get().getString(section: "app", key: "pass", defaultString: "")
	

	
}
