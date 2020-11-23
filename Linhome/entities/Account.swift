//
//  Account.swift
//  Linhome
//
//  Created by Christophe Deschamps on 22/06/2020.
//  Copyright © 2020 Belledonne communications. All rights reserved.
//

import UIKit
import linphonesw

class Account {
	
	static let it = Account()
	
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
		return Core.get().proxyConfigList.filter{$0.idkey != Account.PUSH_GW_ID_KEY}.first
	}
	
	func linhomeAccountCreateProxyConfig(accountCreator: AccountCreator) {
		let proxyConfig = try!accountCreator.createProxyConfig()
		proxyConfig.findAuthInfo()?.algorithm = CorePreferences.them.passwordAlgo!
		Core.get().addPushTokenToProxyConfig(proxyConfig: proxyConfig)
	}
	
	
	func sipAccountLogin(
		accountCreator: AccountCreator,
		proxy: String?,
		expiration: String,
		pushReady: MutableLiveData<Bool>
	) {
		let proxyConfig: ProxyConfig? = try!accountCreator.createProxyConfig()
		proxyConfig?.expires = Int(expiration)!
		try!proxyConfig?.setServeraddr(newValue: (!TextUtils.isEmpty(proxy) ? proxy :  accountCreator.domain)!)
		if (pushGateway() != nil) {
			linkProxiesWithPushGateway(pushReady: pushReady)
		} else {
			createPushGateway(pushReady: pushReady)
		}
	}
	
	func pushGateway() -> ProxyConfig? {
		return Core.get().getProxyConfigByIdkey(idkey: Account.PUSH_GW_ID_KEY)
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
				pushGw.idkey = Account.PUSH_GW_ID_KEY
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
				if (it.idkey != Account.PUSH_GW_ID_KEY) {
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




