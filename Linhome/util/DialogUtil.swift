//
//  Alert.swift
//  Linhome
//
//  Created by Christophe Deschamps on 26/02/2020.
//  Copyright © 2020 Belledonne communications. All rights reserved.
//

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
	
}
