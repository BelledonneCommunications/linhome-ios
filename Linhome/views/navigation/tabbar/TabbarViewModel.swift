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
import UIKit

class TabbarViewModel : ViewModel {
	var unreadCount = MutableLiveData(0)
	private var delegate : CoreDelegateStub?
	
	func updateUnreadCount() {
		unreadCount.value =  Core.get().missedCount()
		UIApplication.shared.applicationIconBadgeNumber = unreadCount.value!
	}
	
	override func onStart() {
		super.onStart()
		if (delegate == nil) {
			delegate = CoreDelegateStub(onCallLogUpdated: { (lc, newCl) in
				self.updateUnreadCount()
			})
		}
		delegate.map{Core.get().addDelegate(delegate:$0)}


	}
	
	override func onEnd() {
		delegate.map{Core.get().removeDelegate(delegate:$0)}
		super.onEnd()
	}
	
}
