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

class CreatorAssistantViewModel : ViewModel {
	
	let accountCreator: AccountCreator

	init(defaultValuePath:String) {
		Core.get().loadConfigFromXml(xmlUri: defaultValuePath)
		accountCreator = try!Core.get().createAccountCreator(xmlrpcUrl: CorePreferences.them.xmlRpcServerUrl)
		if (CorePreferences.them.loginDomain != nil) {
			accountCreator.domain  = CorePreferences.them.loginDomain!
		}
		if (Locale.current.languageCode != nil) {
			accountCreator.language = Locale.current.languageCode!
		}
		accountCreator.algorithm = CorePreferences.them.passwordAlgo!
    }

    func setUsername(field: Pair<MutableLiveData<String>, MutableLiveData<Bool>>) ->  LinphoneAccountCreatorUsernameStatus? {
		if (TextUtils.isEmpty(field.first.value)) {
            return nil
		}
		accountCreator.username = field.first.value!
		let result = accountCreator.setUserName(field.first.value!)
        field.second.value = result == LinphoneAccountCreatorUsernameStatusOk
        return result
    }

    func setPassword(field: Pair<MutableLiveData<String>, MutableLiveData<Bool>>) ->  LinphoneAccountCreatorPasswordStatus? {
		if (TextUtils.isEmpty(field.first.value)) {
            return nil
		}
		let result = accountCreator.setPassword( field.first.value!)
        field.second.value = result == LinphoneAccountCreatorPasswordStatusOk
        return result
    }

    func setEmail(field: Pair<MutableLiveData<String>, MutableLiveData<Bool>>) ->  LinphoneAccountCreatorEmailStatus? {
		if (TextUtils.isEmpty(field.first.value)) {
            return nil
		}
        let result = accountCreator.setEmail(field.first.value!)
        field.second.value = result == LinphoneAccountCreatorEmailStatusOk
        return result
    }

    func setDomain(field: Pair<MutableLiveData<String>, MutableLiveData<Bool>>) ->  LinphoneAccountCreatorDomainStatus? {
		if (TextUtils.isEmpty(field.first.value)) {
            return nil
		}
		let result = accountCreator.setDomain(field.first.value!)
        field.second.value = result == LinphoneAccountCreatorDomainOk
        return result
    }

    func setTransport(transport: TransportType) {
        accountCreator.transport = transport
    }


}
