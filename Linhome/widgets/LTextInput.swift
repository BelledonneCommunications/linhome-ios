//
//  LtextInput.swift
//  Linhome
//
//  Created by Christophe Deschamps on 23/06/2020.
//  Copyright © 2020 Belledonne communications. All rights reserved.
//

import UIKit


class LTextInput: UIViewController, UITextFieldDelegate {
	@IBOutlet weak var inputTitle: UILabel!
	@IBOutlet weak var inputText: LEditText!
	@IBOutlet weak var inputError: UILabel!
	
	var validator:GenericStringValidator?
	var liveString:MutableLiveData<String>?
	var liveValidity:MutableLiveData<Bool>?

	
	
	override func viewDidLoad() {
		super.viewDidLoad()
		inputTitle.prepare(styleKey: "form_input_title")
		inputText.prepare(styleKey: "text_input_text")
		inputError.prepare(styleKey: "text_input_error")
	}
	
	class func addOne(titleKey:String, targetVC:UIViewController, keyboardType: UIKeyboardType = UIKeyboardType.default, validator:GenericStringValidator,liveInfo:Pair<MutableLiveData<String>,MutableLiveData<Bool>>, inForm form:UIStackView, secure:Bool = false, hintKey:String? = nil) -> LTextInput {
		let previousSibbling = form.arrangedSubviews.last
		let child = LTextInput()
		targetVC.addChild(child)
		form.addArrangedSubview(child.view)
		child.didMove(toParent: targetVC)
		child.inputText.keyboardType = keyboardType
		child.inputText.isSecureTextEntry = secure
		child.inputText.addTarget(child, action: #selector(LTextInput.textFieldDidChange(_:)), for: .editingChanged)
		child.inputText.text = liveInfo.first.value
		if (hintKey != nil) {
			child.inputText.setHint(text: Texts.get(hintKey!))
		}
		child.validator =  validator
		child.inputTitle.setText(text:Texts.get(titleKey))
		child.liveString = liveInfo.first
		child.liveValidity = liveInfo.second
		
		previousSibbling.map{ previous in
			child.view.snp.makeConstraints { (make) -> Void in
				make.top.equalTo(previous.snp.bottom)
			}
		}
		
		
		return child
	}
		
	@objc func textFieldDidChange(_ textField: UITextField) {
		self.inputText.virgin =  !(self.inputText.virgin && textField.text?.count ?? 0 > 0)
		liveString.map { $0.value = textField.text }
	}
	
	func textFieldShouldReturn(_ textField: UITextField) -> Bool {
		inputText.resignFirstResponder()
		return true
	}
	
	func textFieldShouldEndEditing(_ textField: UITextField) -> Bool {
		return true
	}
	
	
	func validate() {
		   validator.map { v in
			inputText.text.map { it in
				let validityResult = v.validity(s: it)
				   if (!validityResult.valid) {
					   liveValidity?.value = false
					   validityResult.error.map { error in
						   setError(error)
					   }
				   } else {
					   liveValidity?.value = true
					   clearError()
				   }
			   }
		   }
	   }
	
	func setError(_ message: String) {
		inputText.errorMode()
		inputError.text = message
	}
	
	func clearError() {
		inputText.inputMode()
		inputError.text = nil
	}
	
}

