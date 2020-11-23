//
//  CoreContext.swift
//  Linhome
//
//  Created by Christophe Deschamps on 23/06/2020.
//  Copyright © 2020 Belledonne communications. All rights reserved.
//

import Foundation
import linphonesw
import CommonCrypto



class CorePreferences {
	
	var config:Config
	static let them = CorePreferences()
	
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
