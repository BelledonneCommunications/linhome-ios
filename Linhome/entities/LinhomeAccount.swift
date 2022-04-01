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
	
	
	func configured() -> Bool {
		return Core.get().proxyConfigList.count > 0
	}
	
	func get() -> ProxyConfig? {
		return Core.get().proxyConfigList.filter{$0.idkey != LinhomeAccount.PUSH_GW_ID_KEY}.first
	}
	
	func linhomeAccountCreateProxyConfig(accountCreator: AccountCreator) {
		let proxyConfig = try!accountCreator.createProxyConfig()
		proxyConfig.findAuthInfo()?.algorithm = CorePreferences.them.passwordAlgo!
		Core.get().addPushTokenToProxyConfig(proxyConfig: proxyConfig)
		
		let account = Core.get().accountList.first
		let address = "sip:fs-test-conf.linphone.org:5061;transport=tls"
		try?account?.params?.setServeraddr(newValue: address)		
	}
	
	
	func sipAccountLogin(
		accountCreator: AccountCreator,
		proxy: String?,
		expiration: String,
		pushReady: MutableLiveData<Bool>
	) {
		let transports = ["udp","tcp","tls"]
		let _  = try!accountCreator.createProxyConfig()
		let account = Core.get().accountList.first
		account?.params?.expires = Int(expiration)!
		if (!TextUtils.isEmpty(proxy) ) {
			let address = (accountCreator.transport == .Tls ? "sips:" : "sip:") + proxy! + ";transport="+transports[accountCreator.transport.rawValue]
			try?account?.params?.setServeraddr(newValue: address)
		}
		if (pushGateway() != nil) {
			linkProxiesWithPushGateway(pushReady: pushReady)
		} else {
			createPushGateway(pushReady: pushReady)
		}
	}
	
	func pushGateway() -> ProxyConfig? {
		return Core.get().getProxyConfigByIdkey(idkey: LinhomeAccount.PUSH_GW_ID_KEY)
	}
	
	func createPushGateway(pushReady: MutableLiveData<Bool>) {
	
		Core.get().loadConfigFromXml(xmlUri: CorePreferences.them.linhomeAccountDefaultValuesPath)
		xmlRpcRequest = try!xmlRpcSession.createRequest(returnType: XmlRpcArgType.StringStruct, method: "create_push_account")
		xmlRpcRequestDelegateStub = XmlRpcRequestDelegateStub(onResponse:  { (request:XmlRpcRequest) -> Void in
			let responseValues = request.listResponse
			if (request.status == XmlRpcStatus.Ok) {
				guard let pushGw = try?Core.get().createProxyConfig() else {
					Log.error("Unable to create push gateway proxy config")
					return
				}
				pushGw.idkey = LinhomeAccount.PUSH_GW_ID_KEY
				pushGw.registerEnabled = true
				pushGw.publishEnabled = false
				pushGw.expires = 31536000
				try?pushGw.setServeraddr(newValue: "sips:\(responseValues[1]);transport=tls")
				try?pushGw.setRoutes(newValue: [pushGw.serverAddr])
				pushGw.pushNotificationAllowed = true
				try?pushGw.setIdentityaddress(newValue: Core.get().createAddress(address: "sip:\(responseValues[0])@\(responseValues[1])"))
				if let authInfo = try?Factory.Instance.createAuthInfo(username: responseValues[0],userid: responseValues[0],passwd: nil,ha1: responseValues[2],realm: responseValues[1],domain: responseValues[1]) {
					Core.get().addAuthInfo(info: authInfo)
				} else {
					Log.error("Unable to create push gateway auth into")
				}
				try?Core.get().addProxyConfig(config: pushGw)
				self.linkProxiesWithPushGateway(pushReady: pushReady)
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
			Core.get().proxyConfigList.forEach { it in
				if (it.idkey != LinhomeAccount.PUSH_GW_ID_KEY) {
					it.dependency = pgw
				}
			}
		}
		pushReady.value = true
	}
	
	func disconnect() {
		Core.get().proxyConfigList.forEach { it in
			it.edit()
			it.expires = 0
			try!it.done()
			Core.get().removeProxyConfig(config: it)
		}
	}
	
}




