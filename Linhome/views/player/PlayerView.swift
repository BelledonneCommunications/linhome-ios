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

class PlayerView : ViewWithModel {
	
	var videoPreviewPercentageOfScreenWidth: CGFloat = UIDevice.ipad() && UIScreen.isLandscape ? 0.75 : 0.95
	var videoAspectRatio: CGFloat = 4/3
	let iconPercentageOfScreenWidth: CGFloat = 0.4
	var playerViewModel : PlayerViewModel?
	var event: HistoryEvent? = nil
	var videoView: UIView? = nil
	
	public required init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
		super.init(nibName: nibNameOrNil,bundle: nibBundleOrNil)
	}
	
	required init?(coder: NSCoder) {
		super.init(coder: coder)
	}
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		guard
			let callId = NavigationManager.it.nextViewArgument as? String,
			let event = Core.get().workAroundFindCallLogFromCallId(callId: callId)?.getHistoryEvent(),
			let player = try?Core.get().createLocalPlayer(soundCardName: getSoundCard(), videoDisplayName: "IOSDisplay", windowId: nil) else {
				NavigationManager.it.navigateUp()
				return
		}
		
		self.event = event
		
		HistoryEventStore.it.markAsRead(historyEventId: event.id)
		
		self.view.backgroundColor = Theme.getColor("color_j")
		
		playerViewModel = PlayerViewModel(callId: callId, player: player)
		manageModel(playerViewModel!)
		
		// Close button
		
		let close = UIButton(frame: CGRect(x: 0,y: 0,width: 40,height: 40))
		close.imageEdgeInsets = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
		close.prepare(iconName: "icons/cancel", tintColor: "color_c")
		self.view.addSubview(close)
		close.snp.makeConstraints { (make) in
			make.right.equalToSuperview().offset(-20)
			make.top.equalToSuperview().offset(20+UIDevice.notchHeight())
		}
		close.onClick {
			close.alpha = 0.3
			NavigationManager.it.navigateUp()
		}
		
		// Controls
		
		let controls = PlayerControls(viewModel: playerViewModel!)
		addChild(controls)
		self.view.addSubview(controls.view)
		controls.view.snp.makeConstraints { (make) in
			make.bottom.equalToSuperview().offset(-50)
			make.left.equalToSuperview().offset(20)
			make.right.equalToSuperview().offset(-20)
			make.height.equalTo(40)
		}
		controls.didMove(toParent: self)
		
		// Video/Audio view
		
		if (event.hasVideo) {
			let videoView = UIView()
			videoView.backgroundColor = .black
			var videoPreviewWidth = UIScreen.main.bounds.size.width * videoPreviewPercentageOfScreenWidth
			self.view.addSubview(videoView)
			player.windowId = UnsafeMutableRawPointer(Unmanaged.passRetained(videoView).toOpaque())
			
			videoView.layer.cornerRadius = CGFloat(Customisation.it.themeConfig.getFloat(section: "arbitrary-values", key: "video_view_corner_radius", defaultValue: 20.0))
			videoView.clipsToBounds = true
			if (event.hasMediaThumbnail()) {
				if let image = UIImage(contentsOfFile: event.mediaThumbnailFileName) {
					let size = image.size
					self.videoPreviewPercentageOfScreenWidth = ChunkCallVideoOrIcon.computePercentageWidth(videoSize: size, reservedHeight: 200)
					self.videoAspectRatio = CGFloat(size.width / size.height)
					videoPreviewWidth = UIScreen.main.bounds.size.width * videoPreviewPercentageOfScreenWidth
				}
			}
			videoView.snp.makeConstraints { (make) in
				make.center.equalToSuperview()
				make.width.equalTo(videoPreviewWidth)
				make.height.equalTo(videoPreviewWidth / videoAspectRatio)
			}
			self.videoView = videoView
		} else {
			let iconSize = UIScreen.main.bounds.size.width * iconPercentageOfScreenWidth
			let audio = UIImageView(frame: CGRect(x: 0,y: 0,width: iconSize ,height: iconSize))
			audio.prepareSwiftSVG(iconName: "icons/audio_media", fillColor: "color_c", bgColor: nil)
			self.view.addSubview(audio)
			audio.snp.makeConstraints { (make) in
				make.center.equalToSuperview()
				make.width.height.equalTo(iconSize)
			}
		}
	}
	
	override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
		super.viewWillTransition(to: size, with: coordinator)
		if (UIDevice.ipad()) {
			if let event = event, event.hasMediaThumbnail() {
				if let image = UIImage(contentsOfFile: event.mediaThumbnailFileName) {
					let size = image.size
					self.videoPreviewPercentageOfScreenWidth = ChunkCallVideoOrIcon.computePercentageWidth(videoSize: size, reservedHeight: 200)
					self.videoAspectRatio = CGFloat(size.width / size.height)
					let videoPreviewWidth = UIScreen.main.bounds.size.width * videoPreviewPercentageOfScreenWidth
					videoView?.snp.remakeConstraints { (make) in
						make.center.equalToSuperview()
						make.width.equalTo(videoPreviewWidth)
						make.height.equalTo(videoPreviewWidth / videoAspectRatio)
					}
				}
			}
		}
	}
	
	override func viewDidAppear(_ animated: Bool) {
		super.viewDidAppear(animated)
		playerViewModel?.playFromStart()
	}
	
	override func isCallView() -> Bool {
		return true
	}
	
	func getSoundCard() -> String? {
		var speakerCard: String? = nil
		var earpieceCard: String? = nil
		Core.get().audioDevices.forEach { device in
			if (device.hasCapability(capability: .CapabilityPlay)) {
				if (device.type == .Speaker) {
					speakerCard = device.id
				} else if (device.type == .Earpiece) {
					earpieceCard = device.id
				}
			}
		}
		return speakerCard != nil ? speakerCard : earpieceCard
	}
	
	override func viewWillDisappear(_ animated: Bool) {
		playerViewModel?.pausePlay()
		playerViewModel?.end()
		super.viewWillDisappear(animated)
	}
	
}
