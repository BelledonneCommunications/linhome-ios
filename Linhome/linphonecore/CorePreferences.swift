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
import CommonCrypto



class CorePreferences {
	
	var config:Config
	static let them = CorePreferences()
	static let availableAudioCodecs = ["pcmu","pcma","opus","g729"]
	
	init () {
		config = Config.get()
	}
	
	var xmlRpcServerUrl: String {
		get  {
			config.getString(section: "assistant", key: "xmlrpc_url",defaultString: "")
		}
		set {
			config.setString(section: "assistant", key: "xmlrpc_url", value: newValue)
		}
	}
	

	var showLatestSnapshot: Bool {
		  get {
			return config.getBool(section: "devices", key: "latest_snapshot", defaultValue: true)
		  }
		  set {
			config.setBool(section: "devices", key: "latest_snapshot", value: newValue)
		  }
	}
	
	
	var linhomeAccountDefaultValuesPath: String {
		get { return FileUtil.bundleFilePath("/assistant_linhome_account_default_values")! }
	}

	var sipAccountDefaultValuesPath: String {
		get { return FileUtil.bundleFilePath("/assistant_sip_account_default_values")! }

	}
	
	var loginDomain: String? {
		get  { return config.getString(section: "assistant", key: "domain") }
		set { config.setString(section: "assistant", key: "domain", value: newValue) }
	}
	
	var passwordAlgo: String? {
		get  { return config.getString(section: "assistant", key: "password_algo") }
		set { config.setString(section: "assistant", key: "password_algo", value: newValue) }
	}
	
	
	var debugLog: Bool {
		get  { return config.getBool(section: "app", key: "debug", defaultValue: true) }
		set {
			config.setBool(section: "app", key: "debug", value: newValue)
			Log.instance.debugEnabled = newValue
			Log.instance.setMask()
		}
	}
	
    func encryptedPass(user: String, clearPass: String)-> String? {
		switch (passwordAlgo) {
		case "SHA-256":
			return "\(user):\(loginDomain!):\(clearPass)".sha256()
		case "MD5":
			return "\(user):\(loginDomain!):\(clearPass)".md5()
		default:
			return nil
		}
    }
			
}

extension String {
	 func sha256() -> String {
		let data = self.data(using: .utf8)!
		var digest = [UInt8](repeating: 0, count: Int(CC_SHA256_DIGEST_LENGTH))
		data.withUnsafeBytes({
			_ = CC_SHA256($0, CC_LONG(data.count), &digest)
		})
		return digest.map({ String(format: "%02hhx", $0) }).joined(separator: "")
	}
	func md5() -> String {
		let data = self.data(using: .utf8)!
		var digest = [UInt8](repeating: 0, count: Int(CC_MD5_DIGEST_LENGTH))
		data.withUnsafeBytes({
			_ = CC_MD5($0, CC_LONG(data.count), &digest)
		})
		return digest.map({ String(format: "%02hhx", $0) }).joined(separator: "")
	}
}
