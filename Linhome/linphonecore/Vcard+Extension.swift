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

extension Vcard {

	func isValid() -> Bool {
		
		guard let name = fullName else {
			Log.error("[Device] vCard validation : fullName is nil")
			return false
		}
		
		guard let address = sipAddresses.first else {
			Log.error("[Device] vCard validation : no sip address")
			return false
		}
		
		guard let type = getExtendedPropertiesValuesByName(name: Device.vcard_device_type_header).first, DeviceTypes.it.deviceTypeSupported(typeKey:type) else {
			Log.error("[Device] vCard validation : invalid type \(getExtendedPropertiesValuesByName(name: Device.vcard_device_type_header).first)")
			return false
		}
		guard let remoteDtmfMethod = getExtendedPropertiesValuesByName(name: Device.vcard_action_method_type_header).first,
				let localDtmfMethod = Device.vCardActionMethodsToDeviceMethods[remoteDtmfMethod],
				ActionsMethodTypes.it.methodTypeIsSupported(typeKey: localDtmfMethod) else {
			Log.error("[Device] vCard validation : invalid dtmf sending method \(getExtendedPropertiesValuesByName(name: Device.vcard_action_method_type_header).first)")
			return false
		}
		var validActions = true
		getExtendedPropertiesValuesByName(name: Device.vcard_actions_list_header).forEach { action in
			let components = action.components(separatedBy: ";")
			if (components.count == 2) {
				validActions = validActions && ActionTypes.it.isValid(typeKey: components.first!)
			} else {
				validActions = false
			}
			if (!validActions) {
				Log.error("[Device] vCard validation : invalid action \(action)")
			}
		}
		
		return validActions
	}
	
	
}
