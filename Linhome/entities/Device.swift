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
	
	var id: String = xDigitsUUID()
	var type: String?
	var name: String
	var address: String
	var actionsMethodType: String?
	var actions: [Action]?
	
	
	init(
		id: String = xDigitsUUID(),
		type: String?,
		name: String,
		address: String,
		actionsMethodType: String?,
		actions: [Action]?
	) {
		self.id = id
		self.type = type
		self.name = name
		self.address = address
		self.actionsMethodType = actionsMethodType
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
