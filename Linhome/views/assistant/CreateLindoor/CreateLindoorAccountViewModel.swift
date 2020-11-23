
import Foundation
import linphonesw
import linphone


class CreateLinhomeAccountViewModel : CreatorAssistantViewModel {
	
	var username: Pair<MutableLiveData<String>, MutableLiveData<Bool>> = Pair(MutableLiveData<String>(), MutableLiveData<Bool>(false))
	var email: Pair<MutableLiveData<String>, MutableLiveData<Bool>> = Pair(MutableLiveData<String>(), MutableLiveData<Bool>(false))
	var pass1: Pair<MutableLiveData<String>, MutableLiveData<Bool>> = Pair(MutableLiveData<String>(), MutableLiveData<Bool>(false))
	var pass2: Pair<MutableLiveData<String>, MutableLiveData<Bool>> = Pair(MutableLiveData<String>(), MutableLiveData<Bool>(false))
	var creationResult = MutableLiveData<AccountCreator.Status>()
	
	var delegate : AccountCreatorDelegateStub? = nil
	
	init() {
		super.init(defaultValuePath: CorePreferences.them.linhomeAccountDefaultValuesPath)
		delegate = AccountCreatorDelegateStub(onCreateAccount:  { (creator:AccountCreator, status:AccountCreator.Status, response:String) -> Void in
			if (status == AccountCreator.Status.AccountCreated) {
				Account.it.linhomeAccountCreateProxyConfig(accountCreator: creator)
			}
			self.creationResult.value = status
		})
	}
	
	func valid() -> Bool {
		return username.second.value! && email.second.value! && pass1.second.value! && pass2.second.value!
	}
		
	override func onStart() {
		super.onStart()
		delegate.map{accountCreator.addDelegate(delegate:$0)}
	}
	
	override func onEnd() {
		delegate.map{accountCreator.removeDelegate(delegate:$0)}
		super.onEnd()
	}
	
}



