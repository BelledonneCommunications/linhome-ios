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

extension Device  {
	
	
	func call() {
		
		if (Core.get().callsNb > 0) {
			return
		}
		
		
		let params = try!Core.get().createCallParams(call: nil)
		if (type != nil) {
			params.videoEnabled = DeviceTypes.it.supportsVideo(typeKey: type!)
			params.audioEnabled = DeviceTypes.it.supportsAudio(typeKey: type!)
		}
		let historyEvent = HistoryEvent()
		params.recordFile = historyEvent.mediaFileName
		guard let lpAddress = try?Core.get().createAddress(address: address) else {
			DialogUtil.error("unable_to_call_device")
			return
		}
		
		Core.get().useRfc2833ForDtmf = actionsMethodType == "method_dtmf_rfc_4733"
		Core.get().useInfoForDtmf = actionsMethodType == "method_dtmf_sip_info"

		let call = Core.get().inviteAddressWithParams(addr: lpAddress, params: params)
		if (call != nil) {
			call!.cameraEnabled = false
			call!.callLog?.userData = UnsafeMutableRawPointer(Unmanaged.passRetained(historyEvent).toOpaque())  // Retrieved in CallViewModel and bound with call ID when available
		} else {
			DialogUtil.error("unable_to_call_device")
		}
	}

	
}
