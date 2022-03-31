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

class Device  {
	
	static let vcard_device_type_header = "X-LINPHONE-ACCOUNT-TYPE"
	static let vcard_actions_list_header = "X-LINPHONE-ACCOUNT-ACTION"
	static let vcard_action_method_type_header = "X-LINPHONE-ACCOUNT-DTMF-PROTOCOL"
	static let serverActionMethodsToLocalMethods = [ "sipinfo":"method_dtmf_sip_info","rfc2833":"method_dtmf_rfc_4733","sipmessage":"method_sip_message"] // Server side method names to local app names
	
	var id: String = xDigitsUUID()
	var type: String?
	var name: String
	var address: String
	var actionsMethodType: String?
	var actions: [Action]?
	var isRemotelyProvisionned: Bool = false

	
	var friend: Friend? {
		get {
			do {
				let friend = try Core.get().createFriend()
				let _ = try friend.createVcard(name: name)
				friend.vcard?.addExtendedProperty(name: Device.vcard_device_type_header, value: type!)
				friend.vcard?.addSipAddress(sipAddress: address)
				friend.vcard?.addExtendedProperty(name: Device.vcard_action_method_type_header,value: actionsMethodType!)
				actions?.forEach { it in
					friend.vcard?.addExtendedProperty(name: Device.vcard_actions_list_header,value:it.type! + ";" + it.code!)
				}
				Log.info("[Device] created vCard for device: \(name) \(friend.vcard?.asVcard4String() ?? "nil")")
				return friend
			} catch {
				Log.error("[Device] unable to create associated vcard  : \(name) \(error)")
				return nil
			}
		}
	}
	
	
	init(
		id: String = xDigitsUUID(),
		type: String?,
		name: String,
		address: String,
		actionsMethodType: String?,
		actions: [Action]?,
		isRemotelyProvisionned:Bool
	) {
		self.id = id
		self.type = type
		self.name = name
		self.address = address
		self.actionsMethodType = actionsMethodType
		self.actions = actions
		self.isRemotelyProvisionned = isRemotelyProvisionned
	}
	
	
	init(card:Vcard, isRemotelyProvisionned:Bool) {
		self.isRemotelyProvisionned = isRemotelyProvisionned
		self.id = card.uid
		self.type =  card.getExtendedPropertiesValuesByName(name: Device.vcard_device_type_header).first
		self.name = card.fullName
		self.address = isRemotelyProvisionned ? (card.sipAddresses.first?.asStringUriOnly())! : (card.sipAddresses.first?.asString())!
		self.actionsMethodType = isRemotelyProvisionned ? Device.serverActionMethodsToLocalMethods[card.getExtendedPropertiesValuesByName(name: Device.vcard_action_method_type_header).first!] : card.getExtendedPropertiesValuesByName(name: Device.vcard_action_method_type_header).first!
		var actions = [Action]()
		card.getExtendedPropertiesValuesByName(name: Device.vcard_actions_list_header).forEach { action in
			let components = action.components(separatedBy: ";")
			guard components.count == 2 else {
				Log.error("Unable to create action from VCard \(action)")
				return
			}
			actions.append(Action(type: components.first!, code: components.last))
		}
		self.actions = actions
	}
	
	var thumbNail: String {
		get {
			return StorageManager.it.devicesThumnailPath+"\(id).jpg"
		}
	}
	
	
	func supportsVideo() -> Bool {
		return type != nil ? DeviceTypes.it.supportsVideo(typeKey: type!) : false
	}
	
	func supportsAudio() -> Bool {
		return type != nil ? DeviceTypes.it.supportsAudio(typeKey: type!) : false
	}
	
	
	func typeName()-> String? {
		return DeviceTypes.it.typeNameForDeviceType(typeKey: type ?? "")
	}
	
	func typeIcon()-> String? {
		return DeviceTypes.it.iconNameForDeviceType(typeKey: type ?? "")
	}
	
	func hasThumbNail()-> Bool {
		return FileUtil.fileExistsAndIsNotEmpty(path: thumbNail)
	}
	
}


extension Device : Comparable {
	static func == (lhs: Device, rhs: Device) -> Bool {
		return (lhs.address, lhs.name) ==
			(rhs.address, rhs.name)
	}
	
	static func < (lhs: Device, rhs: Device) -> Bool {
		return (lhs.name, lhs.address) <
			(rhs.name, rhs.address)
	}
}
