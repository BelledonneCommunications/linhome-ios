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

class MainView: ViewWithModel, UIDynamicAnimatorDelegate {
	
	@IBOutlet weak var topBar: UIView!
	@IBOutlet weak var bottomBar: UIView!
	@IBOutlet weak var content: UIView!
	@IBOutlet weak var burger: UIButton!
	@IBOutlet weak var back: UIButton!
	@IBOutlet weak var left: UIButton!
	@IBOutlet weak var right: UIButton!
	@IBOutlet weak var devicesTab: UIView!
	@IBOutlet weak var devicesLabel: UILabel!
	@IBOutlet weak var devicesIcon: UIImageView!
	@IBOutlet weak var historyTab: UIView!
	@IBOutlet weak var historyLabel: UILabel!
	@IBOutlet weak var historyIcon: UIImageView!
	@IBOutlet weak var navigationTitle: UILabel!
	@IBOutlet weak var unreadCount: UILabel!
	
	var toolbarViewModel = ToolbarViewModel()
	var tabbarViewModel = TabbarViewModel()
	var toobarButtonClickedListener: ToobarButtonClickedListener? = nil
	private var observer: MutableLiveDataOnChangeClosure<GlobalState>? = nil
	
	
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		NavigationManager.it.mainView  = self
		
		topBar.snp.makeConstraints { (make) in
			make.size.height.equalTo(UIDevice.hasNotch() ? 104 : 70)
			make.left.right.top.equalToSuperview()
			
		}
		
		bottomBar.snp.makeConstraints { (make) in
			make.size.height.equalTo(UIDevice.hasNotch() ? 94 : 60)
			make.left.right.bottom.equalToSuperview()
		}
		
		content.snp.makeConstraints { (make) in
			make.top.equalTo(topBar.snp.bottom)
			make.bottom.equalTo(bottomBar.snp.top)
			make.left.right.equalToSuperview()
		}
		
		// Top / Status bar
		
		topBar.backgroundColor = Theme.getColor("color_a")
		
		burger.prepare(iconName: "icons/burger_menu",effectKey: "primary_color",tintColor: "color_c")
		back.prepare(iconName: "icons/back",effectKey: "primary_color",tintColor: "color_c")
		
		burger.onClick {
			NavigationManager.it.navigateTo(childClass: SideMenu.self)
		}
		
		back.onClick {
			NavigationManager.it.navigateUp()
		}
		
		toolbarViewModel.burgerButtonVisible.observe { (visible) in
			self.burger.isHidden = !visible!
		}
		toolbarViewModel.leftButtonVisible.observe { (visible) in
			self.left.isHidden = !visible!
			self.burger.isHidden = !self.left.isHidden
		}
		toolbarViewModel.backButtonVisible.observe { (visible) in
			self.back.isHidden = !visible!
		}
		toolbarViewModel.rightButtonVisible.observe { (visible) in
			self.right.isHidden = !visible!
		}
		
		left.onClick {
			self.toobarButtonClickedListener.map{$0.onToolbarLeftButtonClicked()}
		}
		
		right.onClick {
			self.toobarButtonClickedListener.map{$0.onToolbarRightButtonClicked()}
		}
		
		
		navigationTitle.prepare(styleKey: "toolbar_title")
		
		
		// Bottom/Tab bar
		
		bottomBar.backgroundColor = Theme.getColor("color_j")
		
		devicesLabel.prepare(styleKey: "tabbar_option",textKey: "devices")
		devicesIcon.prepare(iconName: "icons/footer_devices.png",fillColor: "color_c",bgColor: "color_j") //  the Linhome stock SVG does not render well, added png fallback
		
		historyLabel.prepare(styleKey: "tabbar_option",textKey: "history")
		historyIcon.prepare(iconName: "icons/footer_history",fillColor: "color_c",bgColor: "color_j")
		unreadCount.prepare(styleKey: "tabbar_unread_count")
		
		unreadCount.backgroundColor = Theme.getColor("color_a")
		unreadCount.layer.masksToBounds = true
		unreadCount.layer.cornerRadius = 10.0
		
		
		manageModel(tabbarViewModel)
		tabbarViewModel.unreadCount.readCurrentAndObserve{ (unread) in
			if (unread! > 0) {
				self.unreadCount.isHidden = false
				self.unreadCount.text = unread! < 100 ? String(unread!) : "99+"
				self.unreadCount.startBouncing(offset: 7)
				
			} else {
				self.unreadCount.isHidden = true
				self.unreadCount.stopAnimations()
			}
		}
		
		
		devicesTab.onClick {
			self.bottomBarButtonClicked(self.devicesTab,self.historyTab)
			NavigationManager.it.navigateTo(childClass: DevicesView.self)
		}
		historyTab.onClick {
			self.bottomBarButtonClicked(self.historyTab,self.devicesTab)
			NavigationManager.it.navigateTo(childClass: HistoryView.self)
		}
		
		bottomBarButtonClicked(devicesTab,historyTab)
		
		
		// Content
		
		self.content.backgroundColor = Theme.getColor("color_c")
		
		observer = MutableLiveDataOnChangeClosure<GlobalState> { state in
			if (state == .On) {
				if ((UIApplication.shared.delegate as! AppDelegate).historyNotifTapped) {
					self.historyTab.performTap()
					(UIApplication.shared.delegate as! AppDelegate).historyNotifTapped = false
				}
			}
		}
		
	}
	
	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		(UIApplication.shared.delegate as! AppDelegate).coreState.addObserver(observer: observer!)
		if ((UIApplication.shared.delegate as! AppDelegate).historyNotifTapped) {
			self.historyTab.performTap()
			(UIApplication.shared.delegate as! AppDelegate).historyNotifTapped = false
		} else {
			devicesTab.performTap()
		}
		
		if (!LinhomeAccount.it.configured()) {
			DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(20)) {
				NavigationManager.it.navigateTo(childClass: AssistantRoot.self)
			}
		}
	}
	
	override func viewWillDisappear(_ animated: Bool) {
		(UIApplication.shared.delegate as! AppDelegate).coreState.removeObserver(observer: observer!)
		super.viewWillDisappear(animated)
	}
	
	func bottomBarButtonClicked(_ clicked: UIView, _ unClicked:UIView) {
		if (unClicked.alpha == 0.3) {
			return
		}
		UIView.animate(withDuration: 0.2) {
			clicked.alpha = 1.0
			unClicked.alpha = 0.3
		}
	}
	
	override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
		super.viewWillTransition(to: size, with: coordinator)
	}
	
	
}
