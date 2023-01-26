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
import Foundation

class DialogUtil: NSObject {
	
	private class func rootVC() -> UIViewController {
		return UIApplication.getTopMostViewController()!
	}
	
	class func error(_ textKey:String, postAction:@escaping ()->Void) {
		let alert = UIAlertController(title: Texts.get("generic_dialog_error_title"), message:Texts.get(textKey), preferredStyle: .alert)
		alert.addAction(UIAlertAction(title: Texts.get("ok"), style: .default, handler: {(alert: UIAlertAction!) in
			postAction()
		}))
		DispatchQueue.main.async {
			rootVC().present(alert, animated: true, completion: nil)
		}
	}
	
	class func error(_ textKey:String) {
		let alert = UIAlertController(title: Texts.get("generic_dialog_error_title"), message:Texts.get(textKey), preferredStyle: .alert)
		alert.addAction(UIAlertAction(title: Texts.get("ok"), style: .default, handler:nil))
		rootVC().present(alert, animated: true, completion: nil)
	}
	
	class func info(_ textKey:String, oneArg:String? = nil) {
		let alert = UIAlertController(title: Texts.get("message"), message: oneArg != nil ? Texts.get(textKey,oneArg:oneArg!) : Texts.get(textKey), preferredStyle: .alert)
		alert.addAction(UIAlertAction(title: Texts.get("ok"), style: .default, handler: nil))
		rootVC().present(alert, animated: true, completion: nil)
	}
	
	class func error(_ textKey:String, oneArg:String? = nil) {
		let alert = UIAlertController(title:  Texts.get("generic_dialog_error_title"), message: oneArg != nil ? Texts.get(textKey,oneArg:oneArg!) : Texts.get(textKey), preferredStyle: .alert)
		alert.addAction(UIAlertAction(title: Texts.get("ok"), style: .default, handler: nil))
		rootVC().present(alert, animated: true, completion: nil)
	}
	
	class func confirm(titleTextKey:String? = nil, messageTextKey:String, oneArg:String? = nil, confirmAction:@escaping ()->Void, cancelAction:( ()->Void)? = nil, confirmTextKey:String = "confirm") {
		let alertController = UIAlertController(title: titleTextKey != nil ? Texts.get(titleTextKey!) : nil, message: oneArg != nil ? Texts.get(messageTextKey, oneArg: oneArg!) : Texts.get(messageTextKey), preferredStyle: .alert)
		alertController.addAction(UIAlertAction(title: Texts.get(confirmTextKey), style: .default, handler: {(alert: UIAlertAction!) in confirmAction()}))
		alertController.addAction(UIAlertAction(title: Texts.get("cancel"), style: .cancel, handler: {(alert: UIAlertAction!) in
			if (cancelAction != nil) {
				cancelAction!()
			}
		}))
		rootVC().present(alertController, animated: true, completion: nil)
	}
	
	static var toastQueue: [String] = []
	
	static func toast(textKey:String,oneArg:String? = nil, timeout:CGFloat = 1.5) {
		let message = oneArg != nil ? Texts.get(textKey,oneArg: oneArg!) : Texts.get(textKey)
		if (toastQueue.count > 0) {
			toastQueue.append(message)
			return
		}
		let rootVc = rootVC()
		let alert = UIAlertController(title: nil, message: message, preferredStyle: .actionSheet)
		alert.popoverPresentationController?.sourceView = rootVc.view
		rootVc.present(alert, animated: true)
		DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + timeout) {
			alert.dismiss(animated: true)
			if (toastQueue.count > 0) {
				let message = toastQueue.first
				toastQueue.remove(at: 0)
				self.toast(textKey:textKey, oneArg: oneArg)
			}
		}
	}
	
}
