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
	let xmlRpcSession = try!Core.get().createXmlRpcSession(url: CorePreferences.them.xmlRpcServerUrl)
	var loginResult = MutableLiveData<String>()
	var xmlRpcRequest : XmlRpcRequest?
	
	var xmlRpcRequestDelegateStub : XmlRpcRequestDelegateStub? = nil
	
	init() {
		super.init(defaultValuePath: CorePreferences.them.linhomeAccountDefaultValuesPath)
	}
	
	func valid() -> Bool {
		return username.second.value! && pass1.second.value!
	}
	
	func fireLogin() {
		xmlRpcRequest = try!xmlRpcSession.createRequest(returnType: XmlRpcArgType.String, method: "check_authentication")
		xmlRpcRequestDelegateStub = XmlRpcRequestDelegateStub(onResponse:  { (request:XmlRpcRequest) -> Void in
			self.loginResult.value = request.stringResponse
		})
		xmlRpcRequest!.addDelegate(delegate: xmlRpcRequestDelegateStub!)
		xmlRpcRequest!.addStringArg(value: username.first.value!)
		xmlRpcRequest!.addStringArg(value: CorePreferences.them.encryptedPass( user: username.first.value!, clearPass: pass1.first.value!)!)
		xmlRpcRequest!.addStringArg(value: CorePreferences.them.loginDomain!)
		xmlRpcSession.sendRequest(request: xmlRpcRequest!)
	}
	
}




