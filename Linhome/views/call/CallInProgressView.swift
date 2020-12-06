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



import Foundation
import UIKit
import SnapKit

class CallInProgressView : GenericCallView {
	
	var actionsButtonRow : UIStackView?
	var durationLabel : UILabel?
	let chunkVideoOrIconContraintMaker : (ConstraintMaker) -> Void = { (make) in // Center the Video or Icon with offset below for the actions buttons
		make.centerY.equalToSuperview().offset(UIDevice.ipad() && UIScreen.isLandscape ? 0 : -50)
		make.centerX.equalToSuperview()
	}
	var chunkVideoOrIcon:ChunkCallVideoOrIcon?
	var chunkNameAddress:ChunkNameAddress?
	var controlButtonsRow : UIStackView?
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		
		chunkVideoOrIcon = ChunkCallVideoOrIcon(viewModel: callViewModel!, owningViewContraintMaker: chunkVideoOrIconContraintMaker)
		self.view.addSubview(chunkVideoOrIcon!.view)
		chunkVideoOrIcon!.didMove(toParent: self)
		self.addChild(chunkVideoOrIcon!)
		chunkVideoOrIcon!.view.snp.makeConstraints(chunkVideoOrIconContraintMaker)

		
		chunkNameAddress = ChunkNameAddress(viewModel: callViewModel!)
		self.view.addSubview(chunkNameAddress!.view)
		chunkNameAddress!.view.snp.makeConstraints { (make) in
			make.left.right.equalToSuperview()
			make.bottom.equalTo(chunkVideoOrIcon!.view.snp.top).offset(-27)
		}
		
		let fullScreenVideo = FullScreenVideo(viewModel: callViewModel!)
		self.view.addSubview(fullScreenVideo.view)
		fullScreenVideo.didMove(toParent: self)
		self.addChild(fullScreenVideo)
		
		
		durationLabel = UILabel()
		durationLabel!.prepare(styleKey: "view_call_device_address")
		self.view.addSubview(durationLabel!)
		durationLabel!.snp.makeConstraints { (make) in
			make.left.right.equalToSuperview()
			make.top.equalTo(chunkVideoOrIcon!.view.snp.bottom).offset(UIDevice.ipad() && !UIScreen.isLandscape ? 80 : 10)
		}
			
		let formatter = DateComponentsFormatter()
		formatter.unitsStyle = .positional
		formatter.allowedUnits = [.minute, .second ]
		formatter.zeroFormattingBehavior = [ .pad ]
		
		Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { timer in
			formatter.string(from: TimeInterval(self.callViewModel!.call.duration)).map {
				self.durationLabel!.text = $0.hasPrefix("0:") ? "0" + $0 : $0
			}
		}
		
		
		// Device actions button
		
		var hasActions = false
		callViewModel?.device?.actions.map { actions in
			if (actions.count > 0) {
				actionsButtonRow = UIStackView()
				actionsButtonRow!.axis = .horizontal
				actionsButtonRow!.distribution = .equalCentering
				actionsButtonRow!.alignment = .center
				actionsButtonRow!.spacing = 20
				self.view.addSubview(actionsButtonRow!)
				actionsButtonRow!.snp.makeConstraints { (make) in
					if (UIDevice.ipad()) {
						make.centerX.equalToSuperview().dividedBy(2).offset(UIScreen.main.bounds.width / 2)
						make.bottom.equalToSuperview().offset( -30)
					} else {
						make.centerX.equalToSuperview()
						make.bottom.equalToSuperview().offset( -120)
					}
				}
				actions.forEach { action in
					let _ = CallButton.addOne(targetVC: self, iconName: action.iconName()!, text: action.actionText(), effectKey: "incall_call_button", tintColor: "color_c",  outLine: true, action: {self.callViewModel?.performAction(action: action)}, toStackView:actionsButtonRow!)
				}
				hasActions = true
			}
		}
		
		// Call control buttons
		controlButtonsRow = UIStackView()
		controlButtonsRow!.axis = .horizontal
		controlButtonsRow!.distribution = .equalCentering
		controlButtonsRow!.alignment = .center
		self.view.addSubview(controlButtonsRow!)
		controlButtonsRow!.snp.makeConstraints { (make) in
			if (UIDevice.ipad()) {
				make.centerX.equalToSuperview().dividedBy(hasActions ? 2 : 1)
				make.bottom.equalToSuperview().offset( -30)
			} else {
				make.centerX.equalToSuperview()
				make.bottom.equalToSuperview().offset(hasActions && !UIDevice.ipad() ? -10 : -30)
			}
		}
		
		let addHangUp = {
			let _ = CallButton.addOne(targetVC: self, iconName: "icons/decline", textKey: "call_button_hangup", effectKey: "decline_call_button", tintColor: "color_c", action: {
				self.callViewModel?.terminate()
			}, toStackView:self.controlButtonsRow)
		}
		
		let addMute = {
			let _ = CallButton.addOne(targetVC: self, off : self.callViewModel?.microphoneMuted, iconName: "icons/mic", textKey: "call_button_mute", textOffKey: "call_button_unmute", effectKey: "incall_call_button", tintColor: "color_c",  outLine: true, action: {
				self.callViewModel?.toggleMute()
			}, toStackView:self.controlButtonsRow)
		}
		
		if (UIDevice.ipad()) {
			addHangUp()
			addMute()
		} else {
			addMute()
			addHangUp()
			let _ = CallButton.addOne(targetVC: self, off : self.callViewModel?.speakerDisabled, iconName: "icons/speaker", textKey: "call_button_disable_speaker", textOffKey: "call_button_enable_speaker", effectKey: "incall_call_button", tintColor: "color_c",  outLine: true, action: {
				self.callViewModel?.toggleSpeaker()
			}, toStackView:controlButtonsRow)
		}
	

		// Touch on full screen video
		
		fullScreenVideo.view.onClick {
			self.durationLabel!.toggleVisible()
			self.controlButtonsRow!.toggleVisible()
			self.actionsButtonRow.map { it in
				it.toggleVisible()
			}
		}
		callViewModel!.videoFullScreen.observe { (full) in
			if (!full!) {
				self.durationLabel!.forceVisible()
				self.controlButtonsRow!.forceVisible()
				self.actionsButtonRow.map { it in
					it.forceVisible()
				}
			}
		}
		
	}

	
	override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
		super.viewWillTransition(to: size, with: coordinator)
		
		coordinator.animate(alongsideTransition: { context in
			self.actionsButtonRow?.snp.remakeConstraints { (make) in
				if (UIDevice.ipad()) {
					make.centerX.equalToSuperview().dividedBy(2).offset(UIScreen.main.bounds.width / 2)
					make.bottom.equalToSuperview().offset( -30)
				} else {
					make.centerX.equalToSuperview()
					make.bottom.equalToSuperview().offset( -120)
				}
			}
			self.durationLabel!.snp.remakeConstraints { (make) in
				make.left.right.equalToSuperview()
				make.top.equalTo(self.chunkVideoOrIcon!.view.snp.bottom).offset(UIDevice.ipad() && !UIScreen.isLandscape ? 80 : 10)
			}
			self.durationLabel!.forceVisible()
			self.controlButtonsRow!.forceVisible()
			self.actionsButtonRow.map { it in
				it.forceVisible()
			}
		}, completion: { context in
		})
		
	

	}
	
}
