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
import SnapKit

class FullScreenVideo: UIViewController {
	
	let callViewModel : CallViewModel
	
	let iconPercentageOfScreenWidth: CGFloat = 0.4
	let videoPreviewPercentageOfScreenWidth: CGFloat = 0.95
	let videoAspectRatio: CGFloat = 4/3
	var videoView : UIView?
	
	
	init(viewModel:CallViewModel) {
		self.callViewModel = viewModel
		super.init(nibName:nil, bundle:nil)
	}
	
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		self.view.snp.makeConstraints{ (make) in
			make.width.equalTo(UIScreen.main.bounds.size.width)
			make.height.equalTo(UIScreen.main.bounds.size.height)
		}
		
		
		videoView = UIView(frame:UIScreen.main.bounds)
		videoView!.backgroundColor = .black
		self.view.addSubview(videoView!)
		
		videoView!.snp.makeConstraints{ (make) in
			make.edges.equalToSuperview()
		}
		
		
		let collapseVideoButton = UIButton(frame: CGRect(x: 0,y: 0,width: 50,height: 50))
		self.view.addSubview(collapseVideoButton)
		collapseVideoButton.prepareRoundIcon(effectKey: "primary_color", tintColor: "color_c", iconName: "icons/fullscreen_stop", padding: 12)
		collapseVideoButton.snp.makeConstraints { (make) in
			make.top.equalTo(videoView!.snp.top).offset(40)
			make.right.equalTo(videoView!.snp.right).offset(-40)
		}
		
		
		collapseVideoButton.onClick {
			self.callViewModel.videoFullScreen.value = !self.callViewModel.videoFullScreen.value!
		}
		
		callViewModel.videoFullScreen.readCurrentAndObserve { (fullScreen) in
			if (fullScreen!) {
				Core.get().nativeVideoWindowId = UnsafeMutableRawPointer(Unmanaged.passRetained(self.videoView!).toOpaque())
			}
			self.view.isHidden = !fullScreen!
		}
		
	}
	
	
	override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
		super.viewWillTransition(to: size, with: coordinator)
		if (UIDevice.ipad()) {
			self.view.snp.remakeConstraints{ (make) in
				make.width.equalTo(UIScreen.main.bounds.size.width)
				make.height.equalTo(UIScreen.main.bounds.size.height)
			}
			self.videoView?.frame = UIScreen.main.bounds
			self.videoView?.setNeedsLayout()
			self.view.snp.remakeConstraints{ (make) in
				make.width.equalTo(UIScreen.main.bounds.size.width)
				make.height.equalTo(UIScreen.main.bounds.size.height)
			}
		}
	}
	
	
}
