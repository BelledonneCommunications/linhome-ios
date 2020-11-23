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

class DeviceStore {
	
	static let it = DeviceStore()
	
	private var devicesConfig: Config
	
	var devices =  [Device]()
	var devicesXml = StorageManager.it.devicesXml
	
	let updatedSnapshotDeviceId = MutableLiveData<String>()
	
	init () {
		FileUtil.ensureFileExists(path: devicesXml)
		devicesConfig = try!Factory.Instance.createConfig(path: "") // we want to store in XML as there could be some funny names.
		let _ = devicesConfig.loadFromXmlFile(filename: devicesXml)
		devices = readFromXml()
	}
	
	func readFromXml() -> [Device] {
		var result = [Device]()
		devicesConfig.sectionsNamesList.forEach { section in
			var actions = [Action]()
			let actionsString = devicesConfig.getString(section: section, key: "actions", defaultString: nil)
			if (actionsString.count > 0) {
				actionsString.components(separatedBy: "|").forEach { it in
					actions.append(Action(type: it.components(separatedBy: ",").first, code: it.components(separatedBy: ",").last))
				}
			}
			result.append(
				Device(
					id: section,
					type: devicesConfig.getString(section: section, key: "type"),
					name: devicesConfig.getString(section: section, key: "name", defaultString: "missing"),
					address: devicesConfig.getString(section: section, key: "address", defaultString: "missing"),
					actionsMethodType: devicesConfig.getString(section: section, key: "actions_method_type"),
					actions: actions
				)
			)
		}
		result.sort()
		return result
	}
	
	func sync() {
		devicesConfig.sectionsNamesList.forEach { it in
			devicesConfig.cleanSection(section: it)
		}
		devices.sort()
		devices.forEach { device in
			devicesConfig.setString(section: device.id, key: "type", value: device.type)
			devicesConfig.setString(section: device.id, key: "name", value: device.name)
			devicesConfig.setString(section: device.id, key: "address", value: device.address)
			devicesConfig.setString(section: device.id, key: "actions_method_type", value: device.actionsMethodType)
			var actionString = String()
			device.actions?.forEach { it in
				let separator = actionString.isEmpty ?  "" : "|"
				actionString += separator + it.type! + "," + it.code!
			}
			devicesConfig.setString(section: device.id, key: "actions", value: actionString)
		}
		FileUtil.write(string: devicesConfig.dumpAsXml(), toPath: devicesXml)
	}
	
	func persistDevice(device: Device) {
		devices.append(device)
		sync()
	}
	
	func removeDevice(device: Device) {
		if (FileUtil.fileExists(path: device.thumbNail)) {
			FileUtil.delete(path: device.thumbNail)
		}
		devices.removeAll { $0.id == device.id }
		sync()
	}
	
	func findDeviceByAddress(address: Address) -> Device? {
		if let device = devices.first(where: { $0.address == address.asStringUriOnly() }) {
			return device
		}
		return nil
	}
	
	func findDeviceByAddress(address: String?) -> Device? {
		guard address != nil else {
			return nil
		}
		do {
			return findDeviceByAddress(address: try Core.get().createAddress(address: address!))
		} catch {
			return nil
		}
	}
	
}
