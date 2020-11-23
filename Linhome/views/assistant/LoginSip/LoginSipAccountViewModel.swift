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

