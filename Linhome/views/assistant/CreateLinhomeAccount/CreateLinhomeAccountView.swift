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
					} else if (status == AccountCreator.Status.RequestTooManyRequests) {
						userNameInput.setError(Texts.get("account_creator_token_requests_failed_too_many"))
					} else if (status == AccountCreator.Status.UnexpectedError) {
						userNameInput.setError(Texts.get("account_creator_token_requests_failed_generic"))
					} else {
						userNameInput.setError(Texts.get("linhome_account_creation_failed",oneArg: "\(status)"))
					}
				})
				model.create()
			}
		}
				
	}
	
	override func viewDidAppear(_ animated: Bool) {
		//createAccount.moveBelow(form,withTopMargin: 40)
		super.viewDidAppear(animated)
	}
	
}
