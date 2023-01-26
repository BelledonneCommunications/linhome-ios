//
//  LinhomeCXCallObserver.swift
//  Linhome
//
//  Created by Tof on 26/01/2023.
//  Copyright © 2023 Belledonne communications. All rights reserved.
//

import Foundation
import CallKit


class LinhomeCXCallObserver : NSObject, CXCallObserverDelegate {
	
	static let it = LinhomeCXCallObserver()
	var ongoingCxCall = MutableLiveData(false)
	var callObserver = CXCallObserver()
	
	override init () {
		super.init()
		callObserver.setDelegate(self, queue: nil)
		ongoingCxCall.value = callObserver.calls.count > 0
	}
	
	func callObserver(_ callObserver: CXCallObserver, callChanged call: CXCall) {
		ongoingCxCall.value = callObserver.calls.count > 0
	}
	
	
}
