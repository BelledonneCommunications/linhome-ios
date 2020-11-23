//
//  SideMenuViewViewController.swift
//  Linhome
//
//  Created by Christophe Deschamps on 22/06/2020.
//  Copyright © 2020 Belledonne communications. All rights reserved.
//

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
		
		
		let userNameInput = LTextInput.addOne(titleKey: "username", targetVC: self, keyboardType: UIKeyboardType.default, validator: ValidatorFactory.nonEmptyStringValidator, liveInfo: model.username, inForm: form)
		let domainInput = LTextInput.addOne(titleKey: "domain", targetVC: self, keyboardType: UIKeyboardType.emailAddress, validator: ValidatorFactory.nonEmptyStringValidator, liveInfo: model.domain, inForm: form )
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
				Account.it.sipAccountLogin(
					accountCreator: model.accountCreator,
					proxy: model.proxy.first.value,
					expiration: model.expiration.first.value!,
					pushReady: model.pushReady)
			}
		}
		
		model.pushReady.observeOnce(onChange: { pushready in
			self.hideProgress()
			if (pushready!) {
				DialogUtil.info("sip_account_created")
				NavigationManager.it.navigateTo(childClass: DevicesView.self, asRoot:true)
			} else {
				DialogUtil.error("failed_creating_pushgateway")
			}
		})
		
		
		more.onClick {
			model.moreOptionsOpened.value = true
			more.removeFromSuperview()
			let _ = LSegmentedControl.addOne(titleKey: "transport", targetVC: self, liveValue: model.transport, inForm: self.form, itemKeys: model.transportOptionKeys)
			let _ = LTextInput.addOne(titleKey: "proxy", targetVC: self, keyboardType: UIKeyboardType.default, validator: ValidatorFactory.hostnameEmptyOrValidValidator, liveInfo: model.proxy, inForm: self.form)
			let expiration = LTextInput.addOne(titleKey: "register_expiration", targetVC: self, keyboardType: UIKeyboardType.numberPad, validator: ValidatorFactory.numberEmptyOrValidValidator, liveInfo: model.expiration, inForm: self.form)
			login.snp.makeConstraints { (make) in
				make.top.equalTo(expiration.view.snp.bottom).offset(50)
			}
		}
		
	}
	
	
}
