//
//  SideMenuViewViewController.swift
//  Linhome
//
//  Created by Christophe Deschamps on 22/06/2020.
//  Copyright © 2020 Belledonne communications. All rights reserved.
//

import UIKit
import linphonesw

class AccountView: MainViewContentWithScrollableForm {
	
	
	override func viewDidLoad() {
		
		super.viewDidLoad()
		
		isRoot = false
		onTopOfBottomBar = true
		titleTextKey = "menu_account"
		hideSubtitle()
		
		let model = AccountViewModel()
		manageModel(model)
		
		viewTitle.prepare(styleKey: "account_info")
		model.accountDesc.readCurrentAndObserve { (text) in
			self.viewTitle.text = text
		}
				
		
		let refresh = UIRoundRectButton(container:contentView, placedBelow:form, effectKey: "secondary_color", tintColor: "color_c", textKey: "refresh_registers", topMargin: 0)
		let changepass = UIRoundRectButton(container:contentView, placedBelow:refresh, effectKey: "secondary_color", tintColor: "color_c", textKey: "change_password", topMargin: 23)
		let deleteaccount = UIRoundRectButton(container:contentView, placedBelow:changepass, effectKey: "secondary_color", tintColor: "color_c", textKey: "delete_account", topMargin: 23)
		let disconnect = UIRoundRectButton(container:contentView, placedBelow:deleteaccount, effectKey: "secondary_color", tintColor: "color_c", textKey: "menu_disconnect", topMargin: 23, isLastInContainer : true)
		
		
		refresh.onClick {
			model.refreshRegisters()
		}
		
		changepass.onClick {
			self.gotoFreeSip()
		}
		
		deleteaccount.onClick {
			self.gotoFreeSip()
		}
		
		disconnect.onClick {
			DialogUtil.confirm(titleTextKey: "menu_disconnect", messageTextKey: "disconnect_confirm_message", confirmAction: {
				Account.it.disconnect()
				NavigationManager.it.navigateUp()
			})
		}
		
	}
	
	
	func gotoFreeSip() {
		  DialogUtil.confirm(titleTextKey: "account_manage_on_freesip_title", messageTextKey: "account_manage_on_freesip_message", confirmAction: {
			if let url = URL(string: Config.get().getString(section: "assistant", key: "freesip_url", defaultString: "https://subscribe.linhome.org")) {
				   UIApplication.shared.open(url)
			   }
		   })
	   }
	
}
