//
//  TemplateView.swift
//  Linhome
//
//  Created by Christophe Deschamps on 18/06/2020.
//  Copyright © 2020 Belledonne communications. All rights reserved.
//

import UIKit
import SVProgressHUD
import IQKeyboardManager


class MainViewContent : ViewWithModel, ToobarButtonClickedListener {
		
	var isRoot:Bool = false
	var keepOnStack: Bool = true
	var onTopOfBottomBar:Bool = false
	var titleTextKey : String?
	var argument : Any?
	
	
	public required init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
		super.init(nibName: nibNameOrNil,bundle: nibBundleOrNil)
		self.view.backgroundColor = Theme.getColor("color_c")
	}
	
	required init?(coder: NSCoder) {
		super.init(coder: coder)
	}
	
	
	func hideKeyBoard() {
		IQKeyboardManager.shared().resignFirstResponder()
	}
	
	func showProgress() {
		SVProgressHUD.setForegroundColor(Theme.getColor("color_a"))
		SVProgressHUD.show()
	}
	
	func hideProgress() {
		SVProgressHUD.dismiss()
	}
	
	
	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		NavigationManager.it.mainView?.toobarButtonClickedListener = self
	}
	
	override func viewWillDisappear(_ animated: Bool) {
		super.viewWillDisappear(animated)
	}
	
	func onToolbarLeftButtonClicked() {}
	
	func onToolbarRightButtonClicked() {}
	
}
