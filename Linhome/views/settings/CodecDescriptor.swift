//
//  CodecDescriptor.swift
//  Linhome
//
//  Created by Christophe Deschamps on 29/06/2020.
//  Copyright © 2020 Belledonne communications. All rights reserved.
//

import Foundation


class CodecDescriptor {
	var title:String
	var rate:String?
	var liveState:MutableLiveData<Bool>
	
	init(title:String, rate: String?, liveState :MutableLiveData<Bool>) {
		self.title = title
		self.rate = rate
		self.liveState = liveState
	}
}
