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


