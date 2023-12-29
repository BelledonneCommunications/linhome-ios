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


class LoginLinhomeAccountViewModel : CreatorAssistantViewModel {
	
	var username: Pair<MutableLiveData<String>, MutableLiveData<Bool>> = Pair(MutableLiveData<String>(), MutableLiveData<Bool>(false))
	var pass1: Pair<MutableLiveData<String>, MutableLiveData<Bool>> = Pair(MutableLiveData<String>(), MutableLiveData<Bool>(false))
	var accountCreatorResult = MutableLiveData<AccountCreator.Status>()
	var sipRegistrationResult = MutableLiveData<Bool>()

	init() {
		super.init(defaultValuePath: CorePreferences.them.linhomeAccountDefaultValuesPath)
		creatorDelegate = AccountCreatorDelegateStub(onIsAccountExist:  { (creator:AccountCreator, status:AccountCreator.Status, response:String) -> Void in
			self.accountCreatorResult.value = status
			self.accountCreator.removeDelegate(delegate: self.creatorDelegate!)
		})
	}
	
	func valid() -> Bool {
		return username.second.value! && pass1.second.value!
	}
	
	func fireLogin() {
		if (accountCreator.isAccountExist() == .RequestOk) {
			accountCreator.addDelegate(delegate: creatorDelegate!)
		} else {
			self.accountCreatorResult.value = .UnexpectedError
		}
	}
	
}




