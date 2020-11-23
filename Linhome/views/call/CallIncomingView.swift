

//
//  CallViewViewController.swift
//  Linhome
//
//  Created by Christophe Deschamps on 06/07/2020.
//  Copyright © 2020 Belledonne communications. All rights reserved.
//

import UIKit
import Foundation
import SnapKit

class CallIncomingView: GenericCallView {
	
	
	var chunkVideoOrIcon: ChunkCallVideoOrIcon?
	
	override func viewDidLoad() {
		super.viewDidLoad()
				
		let chunkVideoOrIconContraintMaker : (ConstraintMaker) -> Void = { (make) in // Center the Video or Icon
						make.center.equalToSuperview()
		}
		chunkVideoOrIcon = ChunkCallVideoOrIcon(viewModel: callViewModel!, owningViewContraintMaker: chunkVideoOrIconContraintMaker)
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
			make.bottom.equalTo(chunkVideoOrIcon!.view.snp.top).offset(-27)
		}
		
		let someText = UILabel()
		someText.prepare(styleKey: "view_call_device_address", textKey: "incoming_someone_at_your_door")
		self.view.addSubview(someText)
		someText.snp.makeConstraints { (make) in
			make.left.right.equalToSuperview()
			make.top.equalTo(chunkVideoOrIcon!.view.snp.bottom).offset(27)
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
			make.bottom.equalToSuperview().offset(-30)
		}
		
		let accept = CallButton.addOne(targetVC: self, iconName: "icons/phone.png", textKey: "call_button_accept", effectKey: "accept_call_button", tintColor: "color_c", action: {
			self.callViewModel?.extendedAccept()
		})
		accept.view.snp.makeConstraints { (make) in
			make.centerX.equalToSuperview().offset(100)
			make.bottom.equalToSuperview().offset(-30)
		}
		
	}
	
	override func viewWillAppear(_ animated: Bool) {
		VibratorHelper.vibrate(true)
	}

	override func viewWillDisappear(_ animated: Bool) {
		VibratorHelper.vibrate(false)
	}
	
	override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
		super.viewWillTransition(to: size, with: coordinator)
	}
	
}
