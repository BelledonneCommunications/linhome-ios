
import Foundation
import linphonesw
import linphone


class LoginSipAccountViewModel : CreatorAssistantViewModel {
	
	var username: Pair<MutableLiveData<String>, MutableLiveData<Bool>> = Pair(MutableLiveData<String>(), MutableLiveData<Bool>(false))
	var domain: Pair<MutableLiveData<String>, MutableLiveData<Bool>> = Pair(MutableLiveData<String>(), MutableLiveData<Bool>(false))
	var pass1: Pair<MutableLiveData<String>, MutableLiveData<Bool>> = Pair(MutableLiveData<String>(), MutableLiveData<Bool>(false))
	var transport = MutableLiveData<Int>(0)
	var transportOptionKeys = ["udp","tcp","tls"]
	var proxy: Pair<MutableLiveData<String>, MutableLiveData<Bool>> = Pair(MutableLiveData<String>(), MutableLiveData<Bool>(true))

	var expiration: Pair<MutableLiveData<String>, MutableLiveData<Bool>> = Pair(
		   MutableLiveData<String>(
			Config.get().getString(
				section: "proxy_default_values",
				key: "reg_expires",
				defaultString: "31536000"
			   )
		   ), MutableLiveData<Bool>(true)
	   )
	
	let moreOptionsOpened = MutableLiveData<Bool>(false)
	let pushReady = MutableLiveData<Bool>()
	
	init() {
		super.init(defaultValuePath: CorePreferences.them.sipAccountDefaultValuesPath)
	}
	
	func valid() -> Bool {
        return username.second.value! && domain.second.value! && pass1.second.value! && proxy.second.value! && expiration.second.value!
	}
	
}

