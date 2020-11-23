//
//  XmlRpcRequestDelegate+Extension.swift
//  Linhome
//
//  Created by Christophe Deschamps on 25/06/2020.
//  Copyright © 2020 Belledonne communications. All rights reserved.
//

import Foundation
import linphonesw


class CallDelegateStub : CallDelegate {
	var _onStateChanged:  ((Call, Call.State, String) -> Void)?
	var _onNextVideoFrameDecoded:  ((Call) -> Void)?
	
	func onStateChanged(call: Call, state: Call.State, message: String) {_onStateChanged.map{$0(call,state,message)}}
	func onNextVideoFrameDecoded(call: Call) { _onNextVideoFrameDecoded.map{$0(call)}}
	
	init(
		onStateChanged:  ((Call, Call.State, String) -> Void)? = nil,
		onNextVideoFrameDecoded : ((Call) -> Void)? = nil
	) {
		self._onStateChanged = onStateChanged
		self._onNextVideoFrameDecoded = onNextVideoFrameDecoded
	}
}
