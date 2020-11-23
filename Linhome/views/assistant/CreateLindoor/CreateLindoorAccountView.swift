//
//  SideMenuViewViewController.swift
//  Linhome
//
//  Created by Christophe Deschamps on 22/06/2020.
//  Copyright © 2020 Belledonne communications. All rights reserved.
//

import UIKit
import linphonesw

class CreateLinhomeAccountView: CreatorAssistantView {
	
	override func viewDidLoad() {
		
		super.viewDidLoad()
		isRoot = false
		onTopOfBottomBar = true
		titleTextKey = "assistant"
		
		viewTitle.setText(textKey: "assistant_create_linhome_account")
		hideSubtitle()

		
		let model = CreateLinhomeAccountViewModel()
		manageModel(model)

		
		let userNameInput = LTextInput.addOne(titleKey: "username", targetVC: self, keyboardType: UIKeyboardType.default, validator: ValidatorFactory.nonEmptyStringValidator, liveInfo: model.username, inForm: form)
		let emailInput = LTextInput.addOne(titleKey: "email", targetVC: self, keyboardType: UIKeyboardType.emailAddress, validator: ValidatorFactory.nonEmptyStringValidator, liveInfo: model.email, inForm: form )
		let pass1Input = LTextInput.addOne(titleKey: "password", targetVC: self, keyboardType: UIKeyboardType.default, validator: ValidatorFactory.nonEmptyStringValidator, liveInfo: model.pass1, inForm: form, secure: true)
		let pass2Input = LTextInput.addOne(titleKey: "password_confirmation", targetVC: self, keyboardType: UIKeyboardType.default, validator: NonEmptyStringMatcherValidator(textInput: pass1Input, errorTextKey: "input_password_do_not_match"), liveInfo: model.pass2, inForm: form, secure: true)
		
		let createAccount = UIRoundRectButton(container:contentView, placedBelow:form, effectKey: "primary_color", tintColor: "color_c", textKey: "create_account", topMargin: 40, isLastInContainer: true)
		
		createAccount.onClick {
			userNameInput.validate()
			emailInput.validate()
			pass1Input.validate()
			pass2Input.validate()
			self.updateField(status: model.setUsername(field: model.username), textInput: userNameInput)
			self.updateField(status: model.setEmail(field: model.email), textInput: emailInput)
			self.updateField(status: model.setPassword(field: model.pass1), textInput: pass1Input)
			if (model.valid()) {
				self.showProgress()
				self.hideKeyBoard()
				model.creationResult.observeOnce(onChange: { status in
					self.hideProgress()
					if (status == AccountCreator.Status.AccountExist) {
						userNameInput.setError(Texts.get("linhome_account_username_already_exists"))
					} else if (status == AccountCreator.Status.AccountCreated) {
						NavigationManager.it.navigateTo(childClass: DevicesView.self, asRoot:true)
						DialogUtil.info("linhome_account_created", oneArg: model.username.first.value)
					} else {
						userNameInput.setError(Texts.get("linhome_account_creation_failed",oneArg: "$status")
						)
					}
				})
				if (try!model.accountCreator.createAccount() != AccountCreator.Status.RequestOk) {
					self.hideProgress()
					DialogUtil.error("linhome_account_creation_request_failed")
				}
			}
		}
				
	}
	
	override func viewDidAppear(_ animated: Bool) {
		//createAccount.moveBelow(form,withTopMargin: 40)
		super.viewDidAppear(animated)
	}
	
}
