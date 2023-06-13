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
import linphone

class DeviceStore {
	
	static let it = DeviceStore()
	static  let userDefaults = UserDefaults(suiteName: Config.appGroupName)!

	private var devicesConfig: Config? = nil
	
	var devices =  [Device]()
	var devicesXml = StorageManager.it.devicesXml
	
	let updatedSnapshotDeviceId = MutableLiveData<String>()
	let local_devices_fl_name = "local_devices"
	let devicesUpdated = MutableLiveData<Bool>()
	var storageMigrated = false

	var coreDelegate:CoreDelegateStub? = nil
	
	var enteringBackground = false

	init () {
		coreDelegate = CoreDelegateStub(
			onGlobalStateChanged: { (core: linphonesw.Core, state: linphonesw.GlobalState, message: String) -> Void in
				Log.info("Core state changed to \(state)")
				if (!self.enteringBackground && core.globalState == .On) {
					Core.get().friendsDatabasePath = FileUtil.sharedContainerUrl().path + "/devices.db"
					if (Core.get().getFriendListByName(name:self.local_devices_fl_name) == nil) {
						let localDevicesFriendList = try?Core.get().createFriendList()
						localDevicesFriendList?.displayName = self.local_devices_fl_name
						localDevicesFriendList.map { Core.get().addFriendList(list: $0) }
					}
					DispatchQueue.main.async { // Leave one cycle to the core to create the friend list
						if (!self.storageMigrated) {
							self.migrateFromXmlStorage()
						} else {
							self.readDevicesFromFriends()
						}
					}
				}
			},
			onConfiguringStatus : { (core, state, message) in
				if (state == .Successful) {
					self.readDevicesFromFriends()
				}
			},
			onFriendListCreated : { (core, list) in
				Log.info("[DeviceStore] friend list created. \(list.displayName)")
				if (core.globalState == .On) {
					self.readDevicesFromFriends()
				}
			}
		)
		Core.get().addDelegate(delegate: self.coreDelegate!)
	}
	
	
	func migrateFromXmlStorage() {
		storageMigrated = true
		if (!FileManager.default.fileExists(atPath: devicesXml)) {
			Log.info("[DeviceStore] no xml migration storage to perform")
			return
		}
		self.devicesConfig = try!Factory.Instance.createConfig(path: "")
		let _ = self.devicesConfig?.loadFromXmlFile(filename: self.devicesXml)
		self.devices = self.readFromXml()
		self.saveLocalDevices()
		self.readDevicesFromFriends()
		try? FileManager.default.removeItem(atPath: self.devicesXml)
		let isLinhomeAccount = Core.get().accountList.filter{$0.params?.idkey != Config.PUSH_GW_ID_KEY}.first?.params?.domain == CorePreferences.them.loginDomain
		if (isLinhomeAccount) {
				Core.get().config?.setString(section: "misc", key: "contacts-vcard-list", value: "https://subscribe.linhome.org/contacts/vcard")
				try?Core.get().config?.sync()
				Core.get().stop()
				try?Core.get().start()
		}
		Log.info("[DeviceStore] migration done")
	}

	
	func readDevicesFromFriends() {
		self.devices = [Device]()
		Core.get().getFriendListByName(name: local_devices_fl_name)?.friends.forEach { friend in
			guard let card = friend.vcard, card.isValid() else {
				Log.error("[DeviceStore] unable to create device from card (card is null or invdalid) \(friend.vcard?.asVcard4String() ?? "nil")")
				return
			}
			let device = Device(card: card, isRemotelyProvisionned: false)
			Log.info("[DeviceStore] found local device : \(device)")
			self.devices.append(device)
		}
		if let remoteFlName = Core.get().config?.getString(section: "misc", key: "contacts-vcard-list", defaultString: nil),  let serverFriendList = Core.get().getFriendListByName(name:remoteFlName) {
			serverFriendList.friends.forEach { friend in
				guard let card: Vcard = friend.vcard, card.isValid() else {
					Log.error("[DeviceStore] received invalid or malformed vCard from remote : \(friend.vcard?.asVcard4String() ?? "nil")")
					return
				}
				let device = Device(card: card, isRemotelyProvisionned: true)
				if (self.devices.filter { $0.address == device.address}.count == 0) {
					Log.info("[DeviceStore] found remotely provisionned device : \(device)")
					self.devices.append(device)
				}
			}
		}
		self.devices.forEach {
			DeviceStore.userDefaults.set( $0.name , forKey: "cached_device_names_"+$0.address)
		}
		self.devices.sort()
		self.devicesUpdated.value = true
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
		Core.get().getFriendListByName(name:local_devices_fl_name)?.friends.forEach {
			let _ = Core.get().getFriendListByName(name:local_devices_fl_name)?.removeFriend(linphoneFriend: $0)
		}
		devices.sort()
		devices.forEach { device in
			if let friend = device.friend, !device.isRemotelyProvisionned {
				if (Core.get().getFriendListByName(name:local_devices_fl_name)?.addFriend(linphoneFriend: friend) != .OK) {
					Log.error("[DeviceStore] unable to save device to local friend list.")
				}
			}
			DeviceStore.userDefaults.set( device.name , forKey: "cached_device_names_"+device.address)
		}
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
	
	static func getDeviceNameForExtension(address: Address) -> String {
		if let cached = DeviceStore.userDefaults.string(forKey: "cached_device_names_"+address.asStringUriOnly()) {
			return cached
		} else {
			return address.username
		}
	}
}
