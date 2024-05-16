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
	
	// Vcard related
	static var vcardListUrl:String? {
		get { get().getString(section: "misc", key: "contacts-vcard-list", defaultString: nil) }
	}
	
	// Apple related
	static let appGroupName = "group.org.linhome" // Needs to be the same name in App Group (capabilities in ALL targets - app & extensions - content + service), can't be stored in the Config itself the Config needs this value to get created
	static let teamID = Config.get().getString(section: "app", key: "team_id", defaultString: "")
	static let earlymediaContentExtensionCagetoryIdentifier = Config.get().getString(section: "app", key: "extension_category", defaultString: "")
	
	// Default values in app
	static let serveraddress =  Config.get().getString(section: "app", key: "server", defaultString: "")
	static let defaultUsername =  Config.get().getString(section: "app", key: "user", defaultString: "")
	static let defaultPass =  Config.get().getString(section: "app", key: "pass", defaultString: "")
	
	// Push related
	static let pushNotificationsInterval =  Config.get().getInt(section: "net", key: "pn-call-remote-push-interval", defaultValue: 3)
	static let PUSH_GW_ID_KEY = "linhome_pushgateway"
#if DEBUG
		static let pushProvider = "apns.dev"
#else
		static let pushProvider = "apns"
#endif
	
	// FlexiApi Requests token with 1h validity, and one time usage
	
	static var flexiApiToken: String? {
		get {
			let token = Config.get().getString(section: "account_creator", key: "account_creation_token", defaultString: "")
			if (token.isEmpty) {
				return nil
			}
			let tokenValidity = Config.get().getInt64(section: "account_creator", key: "account_creation_token_retry_minutes", defaultValue: 60)
			let tokenStoreTime = Config.get().getInt64(section: "account_creator", key: "account_creation_token_store_time", defaultValue: 0)
			if (tokenStoreTime + tokenValidity * 60 > Int64(Date().timeIntervalSince1970)) {
				Log.info("Reusing account creation token \(token)")
				return token
			} else {
				Log.info("Removing stored account creation token as it expired token = \(token) store time was \(tokenStoreTime)")
				Config.get().setString(section: "account_creator", key: "account_creation_token", value: "")
				return nil
			}
		}
		set {
			Config.get().setString(section: "account_creator", key: "account_creation_token", value: newValue)
			Config.get().setInt64(
				section: "account_creator",
				key: "account_creation_token_store_time",
				value: newValue != nil ? Int64(Date().timeIntervalSince1970) : Int64(0))
		}
		
	}

	
}
