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
		
		if (model.account != nil) {
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
					LinhomeAccount.it.disconnect()
					NavigationManager.it.navigateUp()
				})
			}
		}
	}
	
	
	func gotoFreeSip() {
		DialogUtil.confirm(titleTextKey: "account_manage_on_freesip_title", messageTextKey: "account_manage_on_freesip_message", confirmAction: {
			if let url = URL(string: Config.get().getString(section: "assistant", key: "freesip_url", defaultString: "https://subscribe.linhome.org/login")) {
				UIApplication.shared.open(url)
			}
		})
	}
	
}
