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

import UIKit
import linphonesw

class LinhomeAccount {
	
	static let it = LinhomeAccount()
	
	private static let PUSH_GW_USER_PREFIX = "linhome_generated"
	private static let PUSH_GW_DISPLAY_NAME = "Linhome"
			
	func configured() -> Bool {
		return Core.get().proxyConfigList.count > 0
	}
	
	func get() -> Account? {
		return Core.get().accountList.filter{$0.params?.idkey != Config.PUSH_GW_ID_KEY}.first
	}
	
	
	func pushAccount() -> Account? {
		return Core.get().getAccountByIdkey(idkey: Config.PUSH_GW_ID_KEY)
	}
	
	
	func linkProxiesWithPushAccount(pushReady: MutableLiveData<Bool>) {
		pushAccount().map { pushAccount in
			Core.get().accountList.forEach { it in
				if (it.params?.idkey != Config.PUSH_GW_ID_KEY) {
					it.dependency = pushAccount
					if let clonedParams = pushAccount.params?.clone(), let expiration = it.params?.expires  {
						clonedParams.expires = expiration
						pushAccount.params = clonedParams
						pushAccount.refreshRegister()
					}
				}
			}
			enablePushAccount(pushAccount:pushAccount)
		}
		pushReady.value = true
	}
	
	func disconnect() {
		Core.get().accountList.forEach { it in
			if (it.params?.idkey == Config.PUSH_GW_ID_KEY) {
				disablePushAccount(pushAccount: it)
			} else {
				it.params?.clone().map { clonedParams in
					clonedParams.expires = 0
					it.params = clonedParams
				}
				it.refreshRegister()
				Core.get().removeAccount(account: it)
			}
		}
		Core.get().cleanHistory()
		try?Core.get().setProvisioninguri(newValue: "")
		Config.get().cleanEntry(section: "misc", key: "config-uri")
		Core.get().stop()
		try?Core.get().start()
		DeviceStore.it.clearRemoteProvisionnedDevicesUponLogout()
	}
	
	private func disablePushAccount(pushAccount:Account) {
		pushAccount.params?.clone().map {
			$0.expires = 0
			pushAccount.params = $0
			pushAccount.refreshRegister()
		}
	}
	
	private func enablePushAccount(pushAccount:Account) {
		pushAccount.params?.clone().map {
			$0.expires = Config.get().getInt(section: "proxy_default_values",key: "reg_expires",defaultValue: 31536000)
			pushAccount.params = $0
			pushAccount.refreshRegister()
		}
	}

}




