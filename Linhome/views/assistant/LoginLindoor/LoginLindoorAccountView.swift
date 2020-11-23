//
//  SideMenuViewViewController.swift
//  Linhome
//
//  Created by Christophe Deschamps on 22/06/2020.
//  Copyright © 2020 Belledonne communications. All rights reserved.
//

import UIKit
import linphonesw

class LoginLinhomeAccountView: CreatorAssistantView {
	
	
	override func viewDidLoad() {
		
		super.viewDidLoad()
		isRoot = false
		onTopOfBottomBar = true
		titleTextKey = "assistant"
		
		viewTitle.setText(textKey: "assistant_use_linhome_account")
		hideSubtitle()
		
		let model = LoginLinhomeAccountViewModel()
		manageModel(model)

		let userNameInput = LTextInput.addOne(titleKey: "username", targetVC: self, keyboardType: UIKeyboardType.default, validator: ValidatorFactory.nonEmptyStringValidator, liveInfo: model.username, inForm: form)
		let pass1Input = LTextInput.addOne(titleKey: "password", targetVC: self, keyboardType: UIKeyboardType.default, validator: ValidatorFactory.nonEmptyStringValidator, liveInfo: model.pass1, inForm: form, secure: true)
		
		let login = UIRoundRectButton(container:contentView, placedBelow:form, effectKey: "primary_color", tintColor: "color_c", textKey: "login", topMargin: 40, isLastInContainer: true)

				
		login.onClick {
			userNameInput.validate()
			pass1Input.validate()
			self.updateField(status: model.setUsername(field: model.username), textInput: userNameInput)
			self.updateField(status: model.setPassword(field: model.pass1), textInput: pass1Input)
			if (model.valid()) {
				self.showProgress()
				self.hideKeyBoard()
				model.loginResult.observeOnce(onChange: { stringResponse in
					self.hideProgress()
					if (stringResponse == "OK") {
						Account.it.linhomeAccountCreateProxyConfig(accountCreator: model.accountCreator)
						NavigationManager.it.navigateTo(childClass: DevicesView.self, asRoot:true)
						DialogUtil.info("linhome_account_loggedin")
					} else {
						userNameInput.setError(Texts.get("linhome_account_login_failed_unknown_user_or_wroong_password"))
					}
				})
				model.fireLogin()
			}
		}
	}
	
}
