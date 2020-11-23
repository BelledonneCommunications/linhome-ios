
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
