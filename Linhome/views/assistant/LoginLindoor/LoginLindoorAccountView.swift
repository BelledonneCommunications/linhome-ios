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
						LinhomeAccount.it.linhomeAccountCreateProxyConfig(accountCreator: model.accountCreator)
						NavigationManager.it.navigateTo(childClass: DevicesView.self, asRoot:true)
						DialogUtil.info("linhome_account_loggedin")
						DispatchQueue.main.async {// Fetch vcards
							Core.get().stop()
							try?Core.get().start()
						}
					} else {
						userNameInput.setError(Texts.get("linhome_account_login_failed_unknown_user_or_wroong_password"))
					}
				})
				model.fireLogin()
			}
		}
	}
	
}
