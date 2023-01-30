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
	let account = LinhomeAccount.it.get()
	let pushGw = LinhomeAccount.it.pushGateway()
	var accountDesc  =  MutableLiveData("")
	var pushGWDesc  =  MutableLiveData("")
	private var coreDelegate : CoreDelegateStub?
	
	override  init() {
		super.init()
		accountDesc.value = getDescription(key: "account_info",account: account)
		pushGWDesc.value = getDescription(key: "push_account_info",account: pushGw)
		coreDelegate = CoreDelegateStub(onAccountRegistrationStateChanged : { (core: linphonesw.Core, cfg: linphonesw.Account, state: linphonesw.RegistrationState, message: String) -> Void in
			if (cfg.params?.idkey == LinhomeAccount.PUSH_GW_ID_KEY) {
				self.pushGWDesc.value = self.getDescription(key: "push_account_info",account: self.pushGw)
			} else {
				self.accountDesc.value = self.getDescription(key: "account_info",account: self.account)
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
	
	
	func getDescription(key:String, account: Account?) -> String? {
		if let state = account?.state.toHumanReadable(), let ident = account?.params?.identityAddress?.asStringUriOnly() {
			return Texts.get(key, arg1: ident, arg2: state)
		} else {
			return Texts.get("no_account_configured")
		}
	}
	
	
}


