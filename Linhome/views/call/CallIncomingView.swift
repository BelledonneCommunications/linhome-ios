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
import SnapKit
import AVFoundation


class CallIncomingView: GenericCallView {
	
	
	var chunkVideoOrIcon: ChunkCallVideoOrIcon?
	var currentAudioRoute: AVAudioSessionRouteDescription?
	
	override func viewDidLoad() {
		super.viewDidLoad()
				
		let chunkVideoOrIconContraintMaker : (ConstraintMaker) -> Void = { (make) in // Center the Video or Icon
						make.center.equalToSuperview()
		}
		chunkVideoOrIcon = ChunkCallVideoOrIcon(viewModel: callViewModel!, isIncomingView: true, reservedHeight: 290.0, owningViewContraintMaker: chunkVideoOrIconContraintMaker)
		self.view.addSubview(chunkVideoOrIcon!.view)
		chunkVideoOrIcon!.didMove(toParent: self)
		self.addChild(chunkVideoOrIcon!)
		chunkVideoOrIcon!.view.snp.makeConstraints(chunkVideoOrIconContraintMaker)
		
		let chunkNameAddress = ChunkNameAddress(viewModel: callViewModel!)
		self.view.addSubview(chunkNameAddress.view)
		chunkNameAddress.didMove(toParent: self)
		self.addChild(chunkNameAddress)
		chunkNameAddress.view.snp.makeConstraints { (make) in
			make.left.right.equalToSuperview()
			make.top.equalTo(chunkTop!.view.snp.bottom).offset(10)
		}
		
		let fullScreenVideo = FullScreenVideo(viewModel: callViewModel!)
		self.view.addSubview(fullScreenVideo.view)
		fullScreenVideo.didMove(toParent: self)
		self.addChild(fullScreenVideo)

		let decline = CallButton.addOne(targetVC: self, iconName: "icons/decline", textKey: "call_button_decline", effectKey: "decline_call_button", tintColor: "color_c", action: {
			self.callViewModel?.decline()
		})
		decline.view.snp.makeConstraints { (make) in
			make.centerX.equalToSuperview().offset(-100)
			make.bottom.equalToSuperview().offset(-20)
		}
		
		let accept = CallButton.addOne(targetVC: self, iconName: "icons/phone.png", textKey: "call_button_accept", effectKey: "accept_call_button", tintColor: "color_c", action: {
			self.callViewModel?.extendedAccept()
		})
		accept.view.snp.makeConstraints { (make) in
			make.centerX.equalToSuperview().offset(100)
			make.bottom.equalToSuperview().offset(-20)
		}
		
	}
	
	override func viewWillAppear(_ animated: Bool) {
		VibratorHelper.vibrate(true)
		if (AudioHelper.speakerAllowed()){
			try?AVAudioSession.sharedInstance().overrideOutputAudioPort(.speaker)
			UIDevice.current.isProximityMonitoringEnabled = false
		}
	}

	override func viewWillDisappear(_ animated: Bool) {
		VibratorHelper.vibrate(false)
	}
	
	override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
		super.viewWillTransition(to: size, with: coordinator)
	}
	
}
