//
//  SideMenuViewViewController.swift
//  Linhome
//
//  Created by Christophe Deschamps on 22/06/2020.
//  Copyright © 2020 Belledonne communications. All rights reserved.
//

import UIKit
import linphonesw

class RemoteUrlView: MainViewContentWithScrollableForm {
	
	override func viewDidLoad() {
		
		super.viewDidLoad()
		
		isRoot = false
		onTopOfBottomBar = true
		titleTextKey = "assistant"
		
		viewTitle.setText(textKey: "assistant_remote_prov_from_url")
		hideSubtitle()
		
		let model = RemoteAnyViewModel()
		manageModel(model)
		
		let urlInput = LTextInput.addOne(titleKey: "url", targetVC: self, keyboardType: UIKeyboardType.URL, validator: ValidatorFactory.uriValidator, liveInfo: model.url, inForm: form)
		let apply = UIRoundRectButton(container:contentView, placedBelow:form, effectKey: "primary_color", tintColor: "color_c", textKey: "apply", topMargin: 20, isLastInContainer: true)
		
		apply.onClick {
			urlInput.validate()
			if (model.valid()) {
				self.hideKeyBoard()
				self.showProgress()
				model.startRemoteProvisionning()
			}
		}
		
		model.configurationResult.observeAsUniqueObserver (onChange: { status in
			self.hideProgress()
			if (status == ConfiguringState.Failed) {
				DialogUtil.error("remote_configuration_failed")
			} else if (status == ConfiguringState.Skipped) {
				DialogUtil.error("remote_configuration_failed")
			}
		})
		
		model.pushReady.observeOnce(onChange: { pushready in
			self.hideProgress()
			if (pushready!) {
				DialogUtil.info("remote_configuration_success")
				NavigationManager.it.navigateTo(childClass: DevicesView.self, asRoot:true)
			} else {
				DialogUtil.error("failed_creating_pushgateway")
			}
		})
		
	}
	
}
