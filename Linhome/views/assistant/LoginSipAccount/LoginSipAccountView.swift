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

class LoginSipAccountView: CreatorAssistantView {
	

	override func viewDidLoad() {
		
		super.viewDidLoad()
		isRoot = false
		onTopOfBottomBar = true
		titleTextKey = "assistant"
		
		scrollView.addSubview(contentView)
		scrollView.contentSize = contentView.frame.size
		
		viewTitle.prepare(styleKey: "view_main_title",textKey: "assistant_use_sip_account")
		hideSubtitle()

		
		let model = LoginSipAccountViewModel()
		manageModel(model)
		
		
		let userNameInput = LTextInput.addOne(titleKey: "username", targetVC: self, keyboardType: UIKeyboardType.default, validator: ValidatorFactory.nonEmptyStringValidator, liveInfo: model.username, inForm: form, hintKey: "sip_user_hint")
		let domainInput = LTextInput.addOne(titleKey: "domain", targetVC: self, keyboardType: UIKeyboardType.emailAddress, validator: ValidatorFactory.nonEmptyStringValidator, liveInfo: model.domain, inForm: form, hintKey: "sip_domain_hint")
		let pass1Input = LTextInput.addOne(titleKey: "password", targetVC: self, keyboardType: UIKeyboardType.default, validator: ValidatorFactory.nonEmptyStringValidator, liveInfo: model.pass1, inForm: form, secure: true)
		
		
		let more = UIRoundRectButtonWithIcon(container:contentView, placedBelow:form, effectKey: "secondary_color", tintColor: "color_c", textKey: "more_settings", topMargin: 20, iconName: "icons/more")
		let login = UIRoundRectButton(container:contentView, placedBelow:more, effectKey: "primary_color", tintColor: "color_c", textKey: "login", topMargin: 40, isLastInContainer: true)

		
		login.onClick {
			userNameInput.validate()
			domainInput.validate()
			pass1Input.validate()
			self.updateField(status: model.setUsername(field: model.username), textInput: userNameInput)
			self.updateField(status: model.setDomain(field: model.domain), textInput: domainInput)
			self.updateField(status: model.setPassword(field: model.pass1), textInput: pass1Input)
			model.setTransport(transport: TransportType.init(rawValue: model.transport.value!)!)
			
			if (model.valid()) {
				self.hideKeyBoard()
				self.showProgress()
				if let expiration = Int(model.expiration.first.value!) {
					model.sipAccountLogin(
						proxy: model.proxy.first.value,
						expiration: expiration,
						sipRegistered: model.sipRegistered)
				}
			}
		}
		
		model.pushReady.observeOnce(onChange: { pushready in
			self.hideProgress()
			if (pushready!) {
				DialogUtil.info("sip_account_created")
				NavigationManager.it.navigateTo(childClass: DevicesView.self, asRoot:true)
			} else {
				DialogUtil.error("failed_creating_pushgateway")
				NavigationManager.it.navigateTo(childClass: DevicesView.self, asRoot:true)
			}
		})
		
		model.sipRegistered.observe(onChange: { sipRegistered in
			if (!sipRegistered!) {
				self.hideProgress()
				DialogUtil.confirm(titleTextKey: nil, messageTextKey: "failed_sip_login_modify_parameters", confirmAction: {
					LinhomeAccount.it.disconnect()
				}, confirmTextKey: "yes", cancelTextKey: "no")
			}
		})
		
		more.onClick {
			model.moreOptionsOpened.value = true
			more.removeFromSuperview()
			let _ = LSegmentedControl.addOne(titleKey: "transport", targetVC: self, liveValue: model.transport, inForm: self.form, itemKeys: model.transportOptionKeys)
			let _ = LTextInput.addOne(titleKey: "proxy", targetVC: self, keyboardType: UIKeyboardType.default, validator: ValidatorFactory.hostnameEmptyOrValidValidator, liveInfo: model.proxy, inForm: self.form, hintKey: "sip_proxy_hint")
			let expiration = LTextInput.addOne(titleKey: "register_expiration", targetVC: self, keyboardType: UIKeyboardType.numberPad, validator: ValidatorFactory.numberEmptyOrValidValidator, liveInfo: model.expiration, inForm: self.form)
			login.snp.makeConstraints { (make) in
				make.top.equalTo(expiration.view.snp.bottom).offset(50)
			}
		}
		
	}
	
	
}
