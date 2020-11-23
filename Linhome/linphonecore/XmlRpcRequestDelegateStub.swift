//
//  XmlRpcRequestDelegate+Extension.swift
//  Linhome
//
//  Created by Christophe Deschamps on 25/06/2020.
//  Copyright © 2020 Belledonne communications. All rights reserved.
//

import Foundation
import linphonesw


class XmlRpcRequestDelegateStub : XmlRpcRequestDelegate {
	var _onResponse:  ((XmlRpcRequest) -> Void)?
	
	func onResponse(request: XmlRpcRequest) {
		_onResponse.map{$0(request)}
	}
	
	init(
		onResponse:  ((XmlRpcRequest) -> Void)? = nil
	) {
		self._onResponse = onResponse
	}
	
}


