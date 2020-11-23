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
