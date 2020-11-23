
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
