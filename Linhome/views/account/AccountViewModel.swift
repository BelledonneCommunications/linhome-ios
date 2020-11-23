import Foundation
import linphonesw

class AccountViewModel : ViewModel {
	let account = Account.it.get()
	let pushGw = Account.it.pushGateway()
	var accountDesc  =  MutableLiveData("")
	var pushGWDesc  =  MutableLiveData("")
	private var coreDelegate : CoreDelegateStub?
	
	override  init() {
		super.init()
		accountDesc.value = getDescription(key: "account_info",proxyConfig: account)
		pushGWDesc.value = getDescription(key: "push_account_info",proxyConfig: pushGw)
		coreDelegate = CoreDelegateStub(onRegistrationStateChanged : { (core: linphonesw.Core, cfg: linphonesw.ProxyConfig, state: linphonesw.RegistrationState, message: String) -> Void in
			if (cfg.idkey == Account.PUSH_GW_ID_KEY) {
				self.pushGWDesc.value = self.getDescription(key: "push_account_info",proxyConfig: self.pushGw)
			} else {
				self.accountDesc.value = self.getDescription(key: "account_info",proxyConfig: self.account)
			}
		})
		Core.get().addDelegate(delegate: self.coreDelegate!)
	}
	

	func end()  {
		DispatchQueue.main.async {
			Core.get().removeDelegate(delegate: self.coreDelegate!)
		}
	}
	
	
	func refreshRegisters() {
		account?.refreshRegister()
		pushGw?.refreshRegister()
	}
	
	
	func getDescription(key:String, proxyConfig: ProxyConfig?) -> String? {
		if let state = proxyConfig?.state.toHumanReadable(), let ident = proxyConfig?.identityAddress?.asStringUriOnly() {
			return Texts.get(key, arg1: ident, arg2: state)
		} else {
			return Texts.get("no_account_configured")
		}
	}
	
	
}


