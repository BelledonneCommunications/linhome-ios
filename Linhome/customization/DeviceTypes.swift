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

class DeviceTypes {
	
	static let it = DeviceTypes()
	
	var deviceTypes  = [SpinnerItem]()
	var defaultType: String? = nil
	
	let deviceTypesConfig = Customisation.it.deviceTypesConfig
	
	init () {
		deviceTypesConfig.map { config in
			config.sectionsNamesList.forEach { it in
				if (config.getBool(section: it, key: "default", defaultValue: false)) {
					defaultType = it
				}
				deviceTypes.append(
					SpinnerItem(
						textKey: config.getString(section: it, key: "textkey", defaultString: "missing"),
						iconFile: config.getString(section: it, key: "icon"),
						backingKey: it
					)
				)
			}
		}
	}
	
	func iconNameForDeviceType(typeKey: String, circle: Bool = false) -> String? {
		return deviceTypesConfig?.getString(section: typeKey, key: "icon" + (circle ?  "_circle" :  ""))!
	}
	
	func typeNameForDeviceType(typeKey: String)-> String? {
		return Texts.get(deviceTypesConfig?.getString(section: typeKey, key: "textkey", defaultString: deviceTypes[0].backingKey!) ?? "")
	}
	
	func supportsAudio(typeKey: String) -> Bool {
		return deviceTypesConfig?.getBool(section: typeKey, key: "hasaudio", defaultValue: true) ?? true
	}
	
	func supportsVideo(typeKey: String) -> Bool {
		return deviceTypesConfig?.getBool(section: typeKey, key: "hasvideo", defaultValue: true) ?? false
	}
	
}
