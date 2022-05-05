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
				LinhomeAccount.it.linhomeAccountCreateProxyConfig(accountCreator: creator)
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



