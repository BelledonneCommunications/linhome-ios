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

extension Call {
	
	
	func extendedAcceptEarlyMedia(core:Core) {
		do {
			let earlyMediaCallParams: CallParams = try core.createCallParams(call: self)
			earlyMediaCallParams.recordFile = callLog!.getHistoryEvent().mediaFileName!
			cameraEnabled = false
			muteAudioPLayBack()
			try acceptEarlyMediaWithParams(params: earlyMediaCallParams)
			startRecording()
		} catch {
			Log.error("[extendedAcceptEarlyMedia] exception \(error) ")
		}
	}
	
	func extendedAccept(core:Core) {
		do {
			let inCallParams: CallParams = try!core.createCallParams(call: self)
			inCallParams.recordFile = callLog!.getHistoryEvent().mediaFileName!
			cameraEnabled = false
			unMuteAudioPLayBack()
			if let device = DeviceStore.it.findDeviceByAddress(address: remoteAddress!) {
				Core.get().useRfc2833ForDtmf = device.actionsMethodType == "method_dtmf_rfc_4733"
				Core.get().useInfoForDtmf = device.actionsMethodType == "method_dtmf_sip_info"
			}
			try acceptWithParams(params: inCallParams)
			startRecording()
		} catch {
			Log.error("[extendedAccept] exception \(error) ")
		}
	}
	
	
	// Sharing between extension & app
	
	static  let userDefaults = UserDefaults(suiteName: Config.appGroupName)!

	
	static func hasOwnerShip(_ callId:String) -> Bool {
		let result =  Bundle.main.bundleURL.path == userDefaults.object(forKey: "owning"+callId) as! String?
		return result
	}
	
	static func ownerShipRequessted(_ callId:String) -> Bool {
		let result = Bundle.main.bundleURL.path == userDefaults.object(forKey: "owning"+callId) as! String? && userDefaults.bool(forKey:"requesting"+callId)
		return result
	}
		
	static func requestOwnerShip(_ callId:String){
		Log.info("[OwnerShip] requestOwnerShip "+callId)
		userDefaults.setValue(true, forKey:"requesting"+callId)
	}
	
	static func takeOwnerShip(_ callId:String){
		Log.info("[OwnerShip] takeOwnerShip "+callId)
		userDefaults.setValue(Bundle.main.bundleURL.path, forKey:"owning"+callId)
	}
	
	static func releaseOwnerShip(_ callId:String) {
		Log.info("[OwnerShip] releaseOwnerShip "+callId)
		userDefaults.removeObject(forKey: "owning"+callId)
		userDefaults.removeObject(forKey: "requesting"+callId)
	}
	
	static func ownerShipReleased(_ callId:String) -> Bool {
		let result = userDefaults.object(forKey: "owning"+callId)  == nil
		Log.info("[OwnerShip] ownerShipReleased ? = \(result) "+callId)
		return result
	}
	
	static func waitSyncForReleased(timeoutSec:Int,_ callId:String) -> Bool {
		var i = 0
		while (!ownerShipReleased(callId) && i < timeoutSec*50 && !hasOwnerShip(callId)) {
			usleep(20000)
			i+=1
		}
		Log.info("[OwnerShip]  waitSyncForReleased ? \(i < timeoutSec*50) "+callId)
		return i < timeoutSec*50
	}
	
	
	
	static func requestAndWaitForOwnerShip(_ callId:String) {
		Log.warn("[OwnerShip] requestAndWaitForOwnerShip  "+callId)
		requestOwnerShip(callId)
		if (!Call.waitSyncForReleased(timeoutSec: 5,callId)) {
			Log.warn("[OwnerShip] Timed out waiting for call to be released in Service Extension "+callId)
			return
		}
		takeOwnerShip(callId)
	}
	
	func requestAndWaitForOwnerShip(_ callId:String) {
		Call.requestAndWaitForOwnerShip(callId)
	}
	
	// Early media phase - work around to avoid playing audio back to user, but still have the stream
	public func muteAudioPLayBack() {
		speakerVolumeGain = -1000.0
	}

	public func unMuteAudioPLayBack() {
		speakerVolumeGain = 0.0
	}
	
}
