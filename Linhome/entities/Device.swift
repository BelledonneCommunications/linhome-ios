
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
