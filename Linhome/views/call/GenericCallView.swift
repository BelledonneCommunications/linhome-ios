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
import Foundation
import linphonesw
import SVProgressHUD

class GenericCallView : ViewWithModel {
	
	
	var callViewModel:CallViewModel?
	var chunkTop:ChunkCallTop?
	var callStateObserver :  MutableLiveDataOnChangeClosure<Call.State>?
	
	
	public required init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
		super.init(nibName: nibNameOrNil,bundle: nibBundleOrNil)
	}
	
	required init?(coder: NSCoder) {
		super.init(coder: coder)
	}
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		let parameters = NavigationManager.it.nextViewArgument as! Pair<Call,[Call.State]> // The call to handle, and a list of call states handled by that view, if call state if moving out of this set, the view will be dismissed.
		
		callViewModel = CallViewModel(call: parameters.first)
		manageModel(callViewModel!)
		
		
		callStateObserver = MutableLiveDataOnChangeClosure<Call.State>({ state in
			if (!parameters.second.contains(state!)) {
				self.dismiss()
			}
		}, onlyOnce: false)
		
		callViewModel!.callState.addObserver(observer: callStateObserver!)
				
		setGradientBg()

		
		chunkTop = ChunkCallTop()
		self.view.addSubview(chunkTop!.view)
		chunkTop!.view.snp.makeConstraints { (make) in
			make.topMargin.equalTo(20)
			make.left.right.equalToSuperview()
		}
		
		
	}
	
	override func isCallView() -> Bool {
		return true
	}

	override func viewWillAppear(_ animated: Bool) {
		SVProgressHUD.dismiss()
		super.viewWillAppear(animated)
	}
	
	func dismiss() {
		self.callViewModel!.callState.removeObserver(observer: self.callStateObserver!)
		self.callViewModel!.end()
		NavigationManager.it.navigateUp()
	}
	
	override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
		super.viewWillTransition(to: size, with: coordinator)
	}
	
	
}
