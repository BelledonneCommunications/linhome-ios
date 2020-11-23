//
//  XmlRpcRequestDelegate+Extension.swift
//  Linhome
//
//  Created by Christophe Deschamps on 25/06/2020.
//  Copyright © 2020 Belledonne communications. All rights reserved.
//

import Foundation
import linphonesw


class PlayerDelegateStub : PlayerDelegate {
	var _onEofReached:  ((Player) -> Void)?
	
	func onEofReached(player: Player) {_onEofReached.map{$0(player)}}
	
	init(
		onEofReached : ((Player) -> Void)? = nil
	) {
		self._onEofReached = onEofReached
	}
}
