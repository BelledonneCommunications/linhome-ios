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
