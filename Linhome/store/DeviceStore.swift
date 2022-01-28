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
	
	private var devicesConfig: Config? = nil
	
	var devices =  [Device]()
	var devicesXml = StorageManager.it.devicesXml
	
	let updatedSnapshotDeviceId = MutableLiveData<String>()
	let local_devices_fl_name = "local_devices"
	let devicesUpdated = MutableLiveData<Bool>()
	
	var coreDelegate:CoreDelegateStub? = nil

	init () {
		if (FileManager.default.fileExists(atPath: devicesXml)) {
			devicesConfig = try!Factory.Instance.createConfig(path: "")
			let _ = devicesConfig?.loadFromXmlFile(filename: devicesXml)
			devices = readFromXml()
			saveLocalDevices()
			try? FileManager.default.removeItem(atPath: devicesXml)
		}
		devices = readFromFriends()
		devicesUpdated.value = true
		coreDelegate = CoreDelegateStub( onFriendListCreated : { (core, list) in
				Log.info("[DeviceStore] friend list created. \(list.displayName)")
				if (core.globalState == .On) {
					self.devices = self.readFromFriends()
					self.devicesUpdated.value = true
				}
			})
		Core.get().addDelegate(delegate: self.coreDelegate!)
	}
	
	
	func readFromFriends() -> [Device] {
		var result = [Device]()
		Core.get().getFriendListByName(name: local_devices_fl_name)?.friends.forEach { friend in
			guard let card: Vcard = friend.vcard else {
				return
			}
			result.append(Device(card: card, isRemotelyProvisionned: false))
		}
		if let remoteFlName = Core.get().config?.getString(section: "misc", key: "contacts-vcard-list", defaultString: nil),  let serverFriendList = Core.get().getFriendListByName(name:remoteFlName) {
			serverFriendList.friends.forEach { friend in
				guard let card: Vcard = friend.vcard, Device.remoteVcardValid(card: card) else {
					Log.error("[DeviceStore] received invalid or malformed vCard from remote : \(friend.vcard?.asVcard4String() ?? "nil")")
					return
				}
				result.append(Device(card: card, isRemotelyProvisionned: true))
			}
		}
		result.sort()
		return result
	}
	
	func readFromXml() -> [Device] {
		var result = [Device]()
		guard let devicesConfig = devicesConfig  else {
			return result
		}
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
					actions: actions,
					isRemotelyProvisionned: false
				)
			)
		}
		result.sort()
		return result
	}
	
	func saveLocalDevices() {
		var localDevicesFriendList:FriendList?
		if let localList = Core.get().getFriendListByName(name:local_devices_fl_name) {
			Core.get().removeFriendList(list: localList)
		}
		localDevicesFriendList = try?Core.get().createFriendList()
		localDevicesFriendList?.displayName = local_devices_fl_name
		devices.sort()
		devices.forEach { device in
			if let friend = device.friend, !device.isRemotelyProvisionned {
				let _ = localDevicesFriendList?.addFriend(linphoneFriend: friend)
			}
		}
		localDevicesFriendList.map { Core.get().addFriendList(list: $0) }
	}
	
	func persistDevice(device: Device) {
		devices.append(device)
		saveLocalDevices()
	}
	
	func removeDevice(device: Device) {
		if (FileUtil.fileExists(path: device.thumbNail)) {
			FileUtil.delete(path: device.thumbNail)
		}
		devices.removeAll { $0.id == device.id }
		saveLocalDevices()
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
