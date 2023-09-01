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
import CoreTelephony

class GSMActivityHelper : NSObject {
	
	static let it = GSMActivityHelper()
	var ongoingGSMCall = MutableLiveData(false)
	var callCenter = CTCallCenter() // Deprecated, but only alternative to avoid CallKit and comply with Chinese AppStore
	
	override init () {
		super.init()
		ongoingGSMCall.value = callCenter.currentCalls?.count ?? 0 > 0
		callCenter.callEventHandler = { call in
			self.ongoingGSMCall.value = self.callCenter.currentCalls?.count ?? 0 > 0
		}
	}
	
}
