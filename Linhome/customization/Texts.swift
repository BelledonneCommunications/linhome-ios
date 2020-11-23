//
//  Customisation.swift
//  Linhome
//
//  Created by Christophe Deschamps on 18/06/2020.
//  Copyright © 2020 Belledonne communications. All rights reserved.
//

import UIKit
import linphonesw

class Texts {
	
	static let appName = pureGet(key: "appname")
	
	private class func formatText( textKey: String, args: [String]? ) -> String { // Args should be in {0} {1} etc .. in text string
		var text = get(textKey)
		if let args = args {
			for (index, arg) in args.enumerated() {
				text = text.replacingOccurrences(of: "{\(index)}", with: arg)
			}
		}
		return text
	}
	
	private class func getPreferredLocale() -> Locale {
		guard let preferredIdentifier = Locale.preferredLanguages.first else {
			return Locale.current
		}
		return Locale(identifier: preferredIdentifier)
	}
	
	private class func pureGet(key: String) -> String {
		if let deviceLanguage = getPreferredLocale().languageCode {
			if let translation = Customisation.it.textsConfig.getString(section: key, key: deviceLanguage) {
				return translation
			}
		}
		if let def = Customisation.it.textsConfig.getString(section: key, key: "default") {
			return def
		}
		return key
	}
	
	class func get(_ textKey: String, args: [String]? = nil)-> String {
		return formatText(textKey:textKey,args:args)
	}
	
	class func get(_ textKey: String, oneArg: String)-> String {
		return get(textKey, args:[oneArg])
	}
	
	class func get(_ textKey: String, arg1: String, arg2:String)-> String {
		return get(textKey, args:[arg1,arg2])
	}
	
	class func get(_ key: String)-> String {
		return pureGet(key : key).replacingOccurrences(of: "{appname}", with: appName).replacingOccurrences(of: "\\n", with: "\r")
	}
	
}
