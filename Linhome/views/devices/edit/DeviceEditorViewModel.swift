
import Foundation
import linphonesw
import linphone


class DeviceEditorViewModel : ViewModel{
	
	static let defaultDeviceType = 2 	// Video Intercom
	static let defaulMethodType = 1 	// DTMF SIP INFO

	
	var name = Pair(MutableLiveData<String>(), MutableLiveData(false))
	var address = Pair(MutableLiveData<String>(), MutableLiveData(false))
	
	var availableDeviceTypes =  [SpinnerItem]()
	var deviceType = MutableLiveData(defaultDeviceType)
	
	var availableMethodTypes =  [SpinnerItem]()
	var actionsMethod = MutableLiveData(defaulMethodType)
	
	var availableActionTypes = [SpinnerItem]()
	var actionsViewModels = [DeviceEditorActionViewModel]()
	
	
	var device: Device?  {
		didSet {
			device.map { it in
				name.first.value = it.name
				address.first.value = it.address
				deviceType.value = availableDeviceTypes.firstIndex{$0.backingKey == it.type}
				actionsMethod.value = availableMethodTypes.firstIndex{$0.backingKey == it.actionsMethodType}
			}
		}
	}
	
	var refreshActions = MutableLiveData(true)
	
	override init ()  {
		
		availableDeviceTypes.append(SpinnerItem(textKey: "device_type_select_prompt"))
		availableDeviceTypes.append(contentsOf: DeviceTypes.it.deviceTypes)
		
		availableMethodTypes.append(SpinnerItem(textKey: "action_method_prompt"))
		availableMethodTypes.append(contentsOf: ActionsMethodTypes.it.spinnerItems)
		
		availableActionTypes.append(SpinnerItem(textKey: "action_prompt"))
		availableActionTypes.append(contentsOf: ActionTypes.it.spinnerItems)
		
	}
	
	func valid() -> Bool {
		return name.second.value! && address.second.value!
	}
	
	func saveDevice() -> Bool {
		if (!valid()) {
			return false
		}
		for actionModel in actionsViewModels {
			if (!actionModel.valid()) {
				return false
			}
		}
		
		if (device == nil) {
			device = Device(
				type:deviceType.value == 0 ? nil : availableDeviceTypes[deviceType.value!].backingKey,
				name:name.first.value!,
				address:(address.first.value!.hasPrefix("sip:") || address.first.value!.hasPrefix("sips:")) ? address.first.value! :  "sip:\(address.first.value!)",
				actionsMethodType:actionsMethod.value == 0 ? nil :  availableMethodTypes[actionsMethod.value!].backingKey,
				actions:[Action]()
			)
			actionsViewModels.forEach { it in
				if (it.notEmpty()) {
					device?.actions?.append(
						Action(
							type:availableActionTypes[it.type.value!].backingKey,
							code:it.code.first.value!
						)
					)
				}
			}
			DeviceStore.it.persistDevice(device: device!)
		} else {
			device!.type = deviceType.value == 0 ? nil : availableDeviceTypes[deviceType.value!].backingKey
			device!.name = name.first.value!
			device!.address = (address.first.value!.hasPrefix("sip:") || address.first.value!.hasPrefix("sips:")) ? address.first.value! :  "sip:\(address.first.value!)"
			device!.actionsMethodType = actionsMethod.value == 0 ? nil :  availableMethodTypes[actionsMethod.value!].backingKey
			device!.actions = [Action]()
			actionsViewModels.forEach { action in
				if (action.notEmpty()) {
					device!.actions?.append(
						Action(
							type:availableActionTypes[action.type.value!].backingKey,
							code:action.code.first.value!
						)
					)
				}
			}
			DeviceStore.it.sync()
		}
		
		return true
	}
	
	

	
	func removeActionViewModel(viewModel: DeviceEditorActionViewModel) {
		actionsViewModels.removeAll(where: { $0 === viewModel })
		refreshActions.value = true
	}

	
}




