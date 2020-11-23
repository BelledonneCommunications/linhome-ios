//
//  SideMenuViewViewController.swift
//  Linhome
//
//  Created by Christophe Deschamps on 22/06/2020.
//  Copyright © 2020 Belledonne communications. All rights reserved.
//

import UIKit

class AssistantRoot: MainViewContentWithScrollableForm {
	
	
	override func viewDidLoad() {
		
		super.viewDidLoad()
		
		isRoot = false
		onTopOfBottomBar = true
		titleTextKey = "assistant"
		
		viewTitle.setText(textKey: "assistant_welcome_title")
		viewSubtitle.setText(textKey: "assistant_welcome_subtitle")
		
		let createLinhomeAccount = UIRoundRectButton(container:contentView, placedBelow:form, effectKey: "secondary_color", tintColor: "color_c", textKey: "assistant_create_linhome_account", topMargin: 0)
		let loginLinhome = UIRoundRectButton(container:contentView, placedBelow:createLinhomeAccount, effectKey: "secondary_color", tintColor: "color_c", textKey: "assistant_use_linhome_account", topMargin: 23)
		let loginSip = UIRoundRectButton(container:contentView, placedBelow:loginLinhome, effectKey: "secondary_color", tintColor: "color_c", textKey: "assistant_use_sip_account", topMargin: 23)
		let remoteConfig = UIRoundRectButton(container:contentView, placedBelow:loginSip, effectKey: "secondary_color", tintColor: "color_c", textKey: "assistant_remote_prov", topMargin: 23, isLastInContainer : true)
		
		
		createLinhomeAccount.onClick {
			self.navigateToComponent(childClass: CreateLinhomeAccountView.self)
		}
		
		loginLinhome.onClick {
			self.navigateToComponent(childClass: LoginLinhomeAccountView.self)
		}
		
		loginSip.onClick {
			self.navigateToComponent(childClass: LoginSipAccountView.self)
		}
		
		remoteConfig.onClick {
			self.navigateToComponent(childClass: RemoteRoot.self)
		}
		
	}
	
	private func navigateToComponent(childClass: ViewWithModel.Type) {
		if (Account.it.configured()) {
			DialogUtil.confirm(titleTextKey: "assistant_using_will_disconnect_title", messageTextKey: "assistant_using_will_disconnect_message", confirmAction: {
				Account.it.disconnect()
				NavigationManager.it.navigateTo(childClass: childClass)
			})
		} else {
			NavigationManager.it.navigateTo(childClass: childClass)
		}
	}
	
}
