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
	
	var chunkVideoOrIcon:ChunkCallVideoOrIcon?
	var chunkNameAddress:ChunkNameAddress?
	var controlButtonsRow : UIStackView?
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		let hasActions = callViewModel?.device?.actions?.count ?? 0 > 0
		
		let chunkVideoOrIconContraintMaker : (ConstraintMaker) -> Void = { (make) in
			if (self.chunkNameAddress != nil) {
				make.top.equalTo(self.chunkNameAddress!.view.snp.bottom).offset(10)
			}
			if (self.actionsButtonRow != nil) {
				make.bottom.equalTo(self.actionsButtonRow!.snp.top).offset(-20)
			} else if (self.controlButtonsRow != nil) {
				make.bottom.equalTo(self.controlButtonsRow!.snp.top).offset(-20)
				make.bottom.equalToSuperview().offset(hasActions && !UIDevice.ipad() ? 10 : 20)
			}
			
			make.centerX.equalToSuperview()
		}
		
		
		chunkVideoOrIcon = ChunkCallVideoOrIcon(viewModel: callViewModel!,isIncomingView: false, reservedHeight: hasActions && !UIDevice.ipad() ? 400 : 300, owningViewContraintMaker: chunkVideoOrIconContraintMaker)
		self.view.addSubview(chunkVideoOrIcon!.view)
		chunkVideoOrIcon!.didMove(toParent: self)
		self.addChild(chunkVideoOrIcon!)
		chunkVideoOrIcon!.view.snp.makeConstraints(chunkVideoOrIconContraintMaker)

		
		chunkNameAddress = ChunkNameAddress(viewModel: callViewModel!)
		self.view.addSubview(chunkNameAddress!.view)
		chunkNameAddress!.view.snp.makeConstraints { (make) in
			make.left.right.equalToSuperview()
			make.top.equalTo(chunkTop!.view.snp.bottom).offset(10)
		}
		
		let fullScreenVideo = FullScreenVideo(viewModel: callViewModel!)
		self.view.addSubview(fullScreenVideo.view)
		fullScreenVideo.didMove(toParent: self)
		self.addChild(fullScreenVideo)
		
		
		durationLabel = UILabel()
		durationLabel!.prepare(styleKey: "view_call_device_address")
		self.view.addSubview(durationLabel!)
		durationLabel!.snp.makeConstraints { (make) in
			self.applyDurationLabelConstraints(make)
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
		
		callViewModel?.device?.actions.map { actions in
			if (actions.count > 0) {
				actionsButtonRow = UIStackView()
				actionsButtonRow!.axis = .horizontal
				actionsButtonRow!.distribution = .equalCentering
				actionsButtonRow!.alignment = .center
				actionsButtonRow!.spacing = 10
				self.view.addSubview(actionsButtonRow!)
				actionsButtonRow!.snp.makeConstraints { (make) in
					if (UIDevice.ipad()) {
						make.centerX.equalToSuperview().dividedBy(2).offset(UIScreen.main.bounds.width / 2)
						make.bottom.equalToSuperview().offset( -30)
					} else {
						make.centerX.equalToSuperview()
						make.bottom.equalToSuperview().offset( UIDevice.is5SorSEGen1() ? -100 : -100)
					}
				}
				actions.forEach { action in
					let _ = CallButton.addOne(targetVC: self, iconName: action.iconName()!, text: action.actionText(), effectKey: "incall_call_button", tintColor: "color_c",  outLine: true, action: {self.callViewModel?.performAction(action: action)}, toStackView:actionsButtonRow!)
				}
			}
		}
		
		// Call control buttons
		controlButtonsRow = UIStackView()
		controlButtonsRow!.axis = .horizontal
		controlButtonsRow!.distribution = .equalCentering
		controlButtonsRow!.alignment = .center
		controlButtonsRow!.spacing = 10
		self.view.addSubview(controlButtonsRow!)
		controlButtonsRow!.snp.makeConstraints { (make) in
			if (UIDevice.ipad()) {
				make.centerX.equalToSuperview().dividedBy(hasActions ? 2 : 1)
				make.bottom.equalToSuperview().offset( -20)
			} else {
				make.centerX.equalToSuperview()
				make.bottom.equalToSuperview().offset(hasActions ? -10 : -20)
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
		
		callViewModel?.videoContent.readCurrentAndObserve { video in
			if (video == true) {
				self.callViewModel?.videoFullScreen.value = true
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
					make.bottom.equalToSuperview().offset( -100)
				}
			}
			self.durationLabel!.snp.remakeConstraints { (make) in
				self.applyDurationLabelConstraints(make)
			}
			self.durationLabel!.forceVisible()
			self.controlButtonsRow!.forceVisible()
			self.actionsButtonRow.map { it in
				it.forceVisible()
			}
		}, completion: { context in
		})
		
	}
	
	func applyDurationLabelConstraints(_ make: ConstraintMaker) {
		make.left.right.equalToSuperview()
		if (self.actionsButtonRow != nil) {
			make.bottom.equalTo(self.actionsButtonRow!.snp.top).offset(10)
		} else if (self.controlButtonsRow != nil) {
			make.bottom.equalTo(self.controlButtonsRow!.snp.top).offset(10)
		}
		make.top.equalTo(self.chunkVideoOrIcon!.view.snp.bottom).offset(20)
	}
	
}
