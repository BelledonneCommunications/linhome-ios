
class DeviceEditorActionViewModel : ViewModel {
	var owningViewModel: DeviceEditorViewModel
	var displayIndex: Int
    var type = MutableLiveData<Int>(0)
    var code = Pair(MutableLiveData<String>(), MutableLiveData<Bool>(false))
	var actionRow : ActionRow?
	
	init (owningViewModel: DeviceEditorViewModel,displayIndex: Int) {
		self.owningViewModel = owningViewModel
		self.displayIndex = displayIndex
	}

    func valid() -> Bool {
		return (type.value == 0 && (code.first.value == nil || code.first.value!.isEmpty)) || (type.value != 0 && code.second.value!)
    }

    func notEmpty() -> Bool {
        return type.value != 0 && !(code.first.value == nil || code.first.value!.isEmpty)
    }

}
