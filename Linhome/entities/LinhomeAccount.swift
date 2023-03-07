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
	
	static let PUSH_GW_ID_KEY = "linhome_pushgateway"
	private static let PUSH_GW_USER_PREFIX = "linhome_generated"
	private static let PUSH_GW_DISPLAY_NAME = "Linhome"
	let xmlRpcSession = try!Core.get().createXmlRpcSession(url: CorePreferences.them.xmlRpcServerUrl)
	var xmlRpcRequest : XmlRpcRequest?
	var xmlRpcRequestDelegateStub : XmlRpcRequestDelegateStub? = nil
	
	private var creatorDelegate : AccountCreatorDelegateStub? = nil
	private var coreDelegate : CoreDelegateStub? = nil
	
	
	func configured() -> Bool {
		return Core.get().proxyConfigList.count > 0
	}
	
	func get() -> Account? {
		return Core.get().accountList.filter{$0.params?.idkey != LinhomeAccount.PUSH_GW_ID_KEY}.first
	}
	
	func linhomeAccountCreateProxyConfig(accountCreator: AccountCreator) {
		let _ = try!accountCreator.createProxyConfig() // Account creator does not support yet Account creation (createAccount creates in on server). Create proxy config will create the local account. 30.1.2023
		Core.get().accountList.first.map { account in
			account.addPushToken()
			account.findAuthInfo().map { authInfo in
				authInfo.clone().map { clonedAuthInfo in
					Core.get().removeAuthInfo(info: authInfo)
					clonedAuthInfo.algorithm = CorePreferences.them.passwordAlgo!
					Core.get().addAuthInfo(info: clonedAuthInfo)
				}
			}
		}
	}
	
	
	func sipAccountLogin(
		accountCreator: AccountCreator,
		proxy: String?,
		expiration: Int,
		pushReady: MutableLiveData<Bool>,
		sipRegistered: MutableLiveData<Bool>
	) {
		let transports = ["udp","tcp","tls"]
		let _  = try!accountCreator.createProxyConfig()
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
				if (state == .Ok) {
					core.removeDelegate(delegate: self.coreDelegate!)
					sipRegistered.value = true
					if (self.pushGateway() != nil) {
						self.linkProxiesWithPushGateway(pushReady: pushReady)
					} else {
						self.createPushGateway(pushReady: pushReady)
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
	
	func pushGateway() -> Account? {
		return Core.get().getAccountByIdkey(idkey: LinhomeAccount.PUSH_GW_ID_KEY)
	}
	
	func createPushGateway(pushReady: MutableLiveData<Bool>) {
		
		Core.get().loadConfigFromXml(xmlUri: CorePreferences.them.linhomeAccountDefaultValuesPath)
		xmlRpcRequest = try!xmlRpcSession.createRequest(returnType: XmlRpcArgType.StringStruct, method: "create_push_account")
		xmlRpcRequestDelegateStub = XmlRpcRequestDelegateStub(onResponse:  { (request:XmlRpcRequest) -> Void in
			let responseValues = request.listResponse
			if (request.status == XmlRpcStatus.Ok) {
				if let params = try?Core.get().createAccountParams() {
					params.idkey = LinhomeAccount.PUSH_GW_ID_KEY
					params.registerEnabled = true
					params.publishEnabled = false
					if let address = try?Factory.Instance.createAddress(addr: "sips:\(responseValues[1]);transport=tls") {
						try?params.setRoutesaddresses(newValue:[address])
					}
					params.remotePushNotificationAllowed = true
					params.pushNotificationAllowed = false // No voip push
					if let address =  try?Factory.Instance.createAddress(addr: "sip:\(responseValues[0])@\(responseValues[1])") {
						try?params.setIdentityaddress(newValue: address)
					}
					if let authInfo = try?Factory.Instance.createAuthInfo(username: responseValues[0],userid: responseValues[0],passwd: nil,ha1: responseValues[2],realm: responseValues[1],domain: responseValues[1]) {
						Core.get().addAuthInfo(info: authInfo)
					} else {
						Log.error("Unable to create push gateway auth into")
					}
					guard let pushGw = try?Core.get().createAccount(params: params) else {
						Log.error("Unable to create push gateway proxy config")
						return
					}
					pushGw.addPushToken()
					try?Core.get().addAccount(account: pushGw)
					self.linkProxiesWithPushGateway(pushReady: pushReady)
				}
			} else {
				pushReady.value = false
			}
		})
		xmlRpcRequest!.addDelegate(delegate: xmlRpcRequestDelegateStub!)
		xmlRpcRequest!.addStringArg(value: Core.get().userAgent)
		xmlRpcRequest!.addStringArg(value: CorePreferences.them.loginDomain!)
		xmlRpcRequest!.addStringArg(value: CorePreferences.them.passwordAlgo!)
		xmlRpcSession.sendRequest(request: xmlRpcRequest!)
		
	}
	
	func linkProxiesWithPushGateway(pushReady: MutableLiveData<Bool>) {
		pushGateway().map { pgw in
			Core.get().accountList.forEach { it in
				if (it.params?.idkey != LinhomeAccount.PUSH_GW_ID_KEY) {
					it.dependency = pgw
					if let clonedParams = pgw.params?.clone(), let expiration = it.params?.expires  {
						clonedParams.expires = expiration
						pgw.params = clonedParams
						pgw.refreshRegister()
					}
				}
			}
		}
		pushReady.value = true
	}
	
	func disconnect() {
		Core.get().accountList.forEach { it in
			it.params?.clone().map { clonedParams in
				clonedParams.expires = 0
				clonedParams.pushNotificationAllowed = false
				clonedParams.remotePushNotificationAllowed = false
				it.params = clonedParams
			}
			Core.get().removeAccount(account: it)
		}
	}
	
	func delete() {
		Core.get().accountList.forEach { it in
			Core.get().removeAccount(account: it)
		}
	}
		
}




