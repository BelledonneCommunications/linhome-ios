
import UIKit
import linphonesw

extension Call {
	
	
	func extendedAcceptEarlyMedia(core:Core) {
		do {
			let earlyMediaCallParams: CallParams = try core.createCallParams(call: self)
			earlyMediaCallParams.recordFile = callLog!.getHistoryEvent().mediaFileName!
			cameraEnabled = false
			try acceptEarlyMediaWithParams(params: earlyMediaCallParams)
			startRecording()
			sendVfuRequest()
		} catch {
			Log.error("[extendedAcceptEarlyMedia] exception \(error) ")
		}
	}
	
	func extendedAccept(core:Core) {
		do {
			let inCallParams: CallParams = try!core.createCallParams(call: self)
			inCallParams.recordFile = callLog!.getHistoryEvent().mediaFileName!
			cameraEnabled = false
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

	
	static func hasOwnerShip() -> Bool {
		let result =  Bundle.main.bundleURL.path == userDefaults.object(forKey: "owning") as! String?
		return result
	}
	
	static func ownerShipRequessted() -> Bool {
		let result = Bundle.main.bundleURL.path == userDefaults.object(forKey: "owning") as! String? && userDefaults.bool(forKey:"requesting")
		Log.info("[OwnerShip] ownerShipRequessted ? = \(result)")
		return result
	}
		
	static func requestOwnerShip(){
		Log.info("[OwnerShip] requestOwnerShip ")
		userDefaults.setValue(true, forKey:"requesting")
	}
	
	static func takeOwnerShip(){
		Log.info("[OwnerShip] takeOwnerShip ")
		userDefaults.setValue(Bundle.main.bundleURL.path, forKey:"owning")
	}
	
	static func releaseOwnerShip() {
		Log.info("[OwnerShip] releaseOwnerShip ")
		userDefaults.removeObject(forKey: "owning")
		userDefaults.removeObject(forKey: "requesting")
	}
	
	static func ownerShipReleased() -> Bool {
		let result = userDefaults.object(forKey: "owning")  == nil
		Log.info("[OwnerShip] ownerShipReleased ? = \(result) ")
		return result
	}
	
	static func waitSyncForReleased(timeoutSec:Int) -> Bool {
		var i = 0
		while (!ownerShipReleased() && i < timeoutSec*50 && !hasOwnerShip()) {
			Log.info("[OwnerShip] Waiting for ownerShip ")
			usleep(20000)
			i+=1
		}
		Log.info("[OwnerShip]  waitSyncForReleased ? = \(i < timeoutSec*50)")
		return i < timeoutSec*50
	}
	
	
	
	static func requestAndWaitForOwnerShip() {
		Log.warn("[OwnerShip] requestAndWaitForOwnerShip  ")
		requestOwnerShip()
		if (!Call.waitSyncForReleased(timeoutSec: 5)) {
			Log.warn("[OwnerShip] Timed out waiting for call to be released in Service Extension")
			return
		}
		takeOwnerShip()
	}
	
	func requestAndWaitForOwnerShip() {
		Call.requestAndWaitForOwnerShip()
	}
	
	
}
