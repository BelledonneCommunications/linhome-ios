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

class ViewWithModel: UIViewController {
	
	private var managedModel: ViewModel? = nil
	var background, backgroundRotated  : UIView?
	var rotated = false
	
	public required override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
		super.init(nibName: nibNameOrNil,bundle: nibBundleOrNil)
	}
	
	required init?(coder: NSCoder) {
		super.init(coder: coder)
	}
	
	override func viewDidLoad() {
		super.viewDidLoad()
	}
	
	override func viewWillDisappear(_ animated: Bool) {
		managedModel.map{$0.onEnd()}
		super.viewWillDisappear(animated)
	}
	
	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		managedModel.map{$0.onStart()}
	}
	
	func manageModel(_ model:ViewModel) {
		managedModel = model
	}
	
	func finish() {
		willMove(toParent: nil)
		view.removeFromSuperview()
		removeFromParent()
	}
	
	func isCallView() -> Bool {
		return false
	}
	
	func setGradientBg() {
		background = UIView(frame: UIScreen.main.bounds)
		background!.setGradientColor("dark_light_vertical_gradient")
		self.view.addSubview(background!)
		self.view.sendSubviewToBack(background!)
		
		if (UIDevice.ipad()) {
			backgroundRotated =  UIView(frame: CGRect(x: 0,y: 0,width: UIScreen.main.bounds.size.height, height: UIScreen.main.bounds.size.width))
			backgroundRotated!.setGradientColor("dark_light_vertical_gradient")
			self.view.addSubview(backgroundRotated!)
			self.view.sendSubviewToBack(backgroundRotated!)
			backgroundRotated?.isHidden = true
		}
	}
	
	
	
	override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
		super.viewWillTransition(to: size, with: coordinator)
		if (UIDevice.ipad()) {
			rotated = !rotated
			coordinator.animate(alongsideTransition: { context in
				self.background?.isHidden = self.rotated
				self.backgroundRotated?.isHidden = !self.rotated
			}, completion: { context in
			})
		}
	}
			
	
}
