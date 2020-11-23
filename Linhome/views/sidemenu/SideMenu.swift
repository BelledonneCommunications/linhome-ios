//
//  SideMenuViewViewController.swift
//  Linhome
//
//  Created by Christophe Deschamps on 22/06/2020.
//  Copyright © 2020 Belledonne communications. All rights reserved.
//

import UIKit
import linphonesw

class SideMenu: MainViewContent, UITableViewDataSource, UITableViewDelegate {
	
	@IBOutlet weak var optionsTableView: UITableView!
	@IBOutlet weak var disconnectTableView: UITableView!
	
	var options: [MenuOption] = []
	let captureTaps = UITapGestureRecognizer()
	
	
	let cellReuseIdentifier = "SideMenuCell"
	var disconnectOption : MenuOption?
	
	override func viewDidLoad() {
		
		let transition = CATransition()
		transition.type = CATransitionType.push
		transition.subtype = CATransitionSubtype.fromLeft
		transition.duration = 0.2
		self.view.layer.add(transition, forKey: nil)
		
		super.viewDidLoad()
		
		isRoot = false
		onTopOfBottomBar = true
		self.view.backgroundColor = Theme.getColor("color_b")
		optionsTableView.backgroundColor = Theme.getColor("color_b")
		
		optionsTableView.register(UINib(nibName: "SideMenuCell", bundle: nil), forCellReuseIdentifier: cellReuseIdentifier)
		disconnectTableView.register(UINib(nibName: "SideMenuCell", bundle: nil), forCellReuseIdentifier: cellReuseIdentifier)
		
		disconnectOption = MenuOption(iconName: "icons/disconnect",textKey: "menu_disconnect",action: {
			DialogUtil.confirm(titleTextKey: "menu_disconnect", messageTextKey: "disconnect_confirm_message", confirmAction: {
				Account.it.disconnect()
				NavigationManager.it.navigateUp()
			})
		})
		
		options = [
			MenuOption(iconName: "icons/assistant",textKey: "menu_assistant",action: {
				NavigationManager.it.navigateUp(completion: {
					NavigationManager.it.navigateTo(childClass: AssistantRoot.self)
				})
			}),
			MenuOption(iconName: "icons/account",textKey: "menu_account",action: {
				NavigationManager.it.navigateUp(completion: {
					NavigationManager.it.navigateTo(childClass: AccountView.self)
				})
			}),
			MenuOption(iconName: "icons/settings",textKey: "menu_settings",action: {
				NavigationManager.it.navigateUp(completion: {
					NavigationManager.it.navigateTo(childClass: SettingsView.self)
				})
			}),
			MenuOption(iconName: "icons/about",textKey: "menu_about",action: {
				NavigationManager.it.navigateUp(completion: {
					NavigationManager.it.navigateTo(childClass: About.self)
				})
			}),
		]
		
		
	}
	
	override func viewDidAppear(_ animated: Bool) {
		let leftRatio:Double  = UIDevice.ipad() ? (UIScreen.isLandscape ? 0.3 : 0.5) : 0.75
		self.view.snp.makeConstraints { (make) in
			make.width.equalToSuperview().multipliedBy(leftRatio)
			make.top.bottom.equalToSuperview()
		}
		captureTaps.cancelsTouchesInView = true
		captureTaps.addTarget(self, action: #selector(hideIt))
		self.view.superview!.addGestureRecognizer(captureTaps)
	}
	
	override func viewWillDisappear(_ animated: Bool) {
		self.view.superview!.removeGestureRecognizer(captureTaps)
	}
	
	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return tableView == optionsTableView ?  options.count : 1
	}
	
	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let isOption = tableView == optionsTableView
		let cell:SideMenuCell = tableView.dequeueReusableCell(withIdentifier: cellReuseIdentifier) as! SideMenuCell
		return cell.prepare(option: isOption ? options[indexPath.row] : disconnectOption!, hideTopSeparator: isOption, hideBottomSeparator: !isOption)
	}
	
	@objc func hideIt() {
		NavigationManager.it.navigateUp()
	}
	
}
