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
import linphone


class LoginSipAccountViewModel : FlexiApiPushAccountCreationViewModel {
	
	var username: Pair<MutableLiveData<String>, MutableLiveData<Bool>> = Pair(MutableLiveData<String>("cd1"), MutableLiveData<Bool>(false))
	var domain: Pair<MutableLiveData<String>, MutableLiveData<Bool>> = Pair(MutableLiveData<String>("sip.linphone.org"), MutableLiveData<Bool>(false))
	var pass1: Pair<MutableLiveData<String>, MutableLiveData<Bool>> = Pair(MutableLiveData<String>("cd1"), MutableLiveData<Bool>(false))
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
	let sipRegistered = MutableLiveData<Bool>()

	init() {
		super.init(defaultValuePath: CorePreferences.them.sipAccountDefaultValuesPath)
	}
	
	func valid() -> Bool {
        return username.second.value! && domain.second.value! && pass1.second.value! && proxy.second.value! && expiration.second.value!
	}
	
	func sipAccountLogin(
		proxy: String?,
		expiration: Int,
		sipRegistered: MutableLiveData<Bool>
	) {
		let transports = ["udp","tcp","tls"]
		let _  = try!accountCreator.createAccountInCore()
		let account = Core.get().accountList.first
		account?.params?.clone().map {clonedAccountParams in
			clonedAccountParams.expires = expiration
			if (!TextUtils.isEmpty(proxy) ) {
				if let address = try?Factory.Instance.createAddress(addr: (accountCreator.transport == .Tls ? "sips:" : "sip:") + proxy! + ";transport="+transports[accountCreator.transport.rawValue]) {
					try?clonedAccountParams.setRoutesaddresses(newValue: [address])
				}
			}
			account?.params = clonedAccountParams
		}
		
		coreDelegate =  CoreDelegateStub(
			onAccountRegistrationStateChanged : { (core: Core, account: Account, state: RegistrationState, message: String) -> Void in
				if (account.params?.idkey == Config.PUSH_GW_ID_KEY) {
					return
				}
				if (state == .Ok) {
					core.removeDelegate(delegate: self.coreDelegate!)
					sipRegistered.value = true
					if (LinhomeAccount.it.pushAccount() != nil) {
						LinhomeAccount.it.linkProxiesWithPushAccount(pushReady: self.pushReady)
					} else {
						self.createPushAccount()
					}
					DispatchQueue.main.async {
						DeviceStore.it.fetchVCards()
					}
				}
				if (state == .Failed) {
					core.removeDelegate(delegate: self.coreDelegate!)
					sipRegistered.value = false
				}
			}
		)
		Core.get().addDelegate(delegate: coreDelegate!)
		account?.refreshRegister()
	}
	
}

