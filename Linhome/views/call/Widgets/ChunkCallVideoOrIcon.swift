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

class ChunkCallVideoOrIcon: UIViewController {
	
	let callViewModel : CallViewModel
	
	let iconPercentageOfScreenWidth: CGFloat = 0.4
	var videoPreviewPercentageOfScreenWidth: CGFloat = UIDevice.ipad() ? UIScreen.isLandscape ? 0.5 : 0.9 : 0.95
	var videoPreviewPercentageOfScreenWidthRotated: CGFloat = UIDevice.ipad() ? UIScreen.isLandscape ? 0.9 : 0.5 : 0.95
	var videoAspectRatio: CGFloat = 4/3
	
	let owningViewContraintMaker : ((ConstraintMaker) -> Void)?
	
	var iconView : UIImageView?
	let isIncomingView : Bool
	let reservedHeight : CGFloat

	var videoView, videoViewRotated : UIView?
	var fullSizeVideoButton : UIButton?
	var rotated = false
	
	init(viewModel:CallViewModel, isIncomingView : Bool, reservedHeight:CGFloat, owningViewContraintMaker: ((ConstraintMaker) -> Void)? = nil) {
		self.callViewModel = viewModel
		self.owningViewContraintMaker = owningViewContraintMaker
		self.isIncomingView = isIncomingView
		self.reservedHeight = reservedHeight
		super.init(nibName:nil, bundle:nil)
	}
	
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		iconView = UIImageView()
		let iconSize = UIScreen.main.bounds.size.width * iconPercentageOfScreenWidth * ( UIDevice.ipad() ? 0.5 : 1)
		iconView!.frame = CGRect(x: 0,y: 0,width: iconSize ,height: iconSize)
		iconView!.prepare(iconName: DeviceTypes.it.iconNameForDeviceType(typeKey:  (callViewModel.device != nil && callViewModel.device!.type != nil ? callViewModel.device!.type! : callViewModel.defaultDeviceType)!, circle: true)!, fillColor: "color_c", bgColor: nil)
		self.view.addSubview(iconView!)
		iconView?.snp.makeConstraints { make in
			make.centerX.centerY.equalToSuperview()
			make.width.height.equalTo(iconSize)
		}
		
		var someText: UILabel?
		if (isIncomingView) {
			someText = UILabel()
			someText!.prepare(styleKey: "view_call_device_address", textKey: "incoming_someone_at_your_door")
			self.view.addSubview(someText!)
			someText!.snp.makeConstraints { (make) in
				make.left.right.equalToSuperview()
				make.top.equalTo(iconView!.snp.bottom).offset(10)
			}
		}
		
		videoView = UIView()
		videoView!.backgroundColor = .black
		self.view.addSubview(videoView!)
		Core.get().nativeVideoWindowId = UnsafeMutableRawPointer(Unmanaged.passRetained(videoView!).toOpaque())
		self.videoView!.snp.remakeConstraints{ (make) in
			make.width.height.equalToSuperview()
		}
		videoView?.layer.cornerRadius = CGFloat(Customisation.it.themeConfig.getFloat(section: "arbitrary-values", key: "video_view_corner_radius", defaultValue: 20.0))
		videoView?.clipsToBounds = true
		
		if (UIDevice.ipad()) {
			videoViewRotated = UIView()
			videoViewRotated!.backgroundColor = .black
			let videoRotatedPreviewWidth = UIScreen.main.bounds.size.height * videoPreviewPercentageOfScreenWidthRotated
			videoViewRotated!.frame = CGRect(x: 0,y: 0,width: videoRotatedPreviewWidth  ,height: videoRotatedPreviewWidth / videoAspectRatio)
			self.view.addSubview(videoViewRotated!)
			videoViewRotated?.isHidden = true
		}
		
		fullSizeVideoButton = UIButton(frame: CGRect(x: 0,y: 0,width: 50,height: 50))
		self.view.addSubview(fullSizeVideoButton!)
		fullSizeVideoButton!.prepareRoundIcon(effectKey: "primary_color", tintColor: "color_c", iconName: "icons/fullscreen_start", padding: 12)
		fullSizeVideoButton!.snp.makeConstraints { (make) in
			make.top.equalTo(videoView!.snp.top).offset(13)
			make.right.equalTo(videoView!.snp.right).offset(-13)
		}
		fullSizeVideoButton!.isHidden = true
		
		fullSizeVideoButton!.onClick {
			self.callViewModel.videoFullScreen.value = !self.callViewModel.videoFullScreen.value!
		}
		
		
		callViewModel.videoFullScreen.observe { (fullScreen) in
			self.view.isHidden = fullScreen!
			if (!fullScreen!) {
				Core.get().nativeVideoWindowId = UnsafeMutableRawPointer(Unmanaged.passRetained(self.rotated ? self.videoViewRotated! : self.videoView!).toOpaque())
			}
		}
		
		var initialReading = true
		
		callViewModel.videoSize.readCurrentAndObserve { size in
			guard let size = size else {
				return
			}
			self.videoPreviewPercentageOfScreenWidth = self.computePercentageWidth(videoSize: size)
			self.videoAspectRatio = CGFloat(size.width / size.height)
			if (self.callViewModel.videoContent.value == true) {
				self.callViewModel.videoContent.notifyValue()
			}
		}
		
		callViewModel.videoContent.readCurrentAndObserve { (hasVideo) in
			someText?.isHidden = hasVideo == true
			let videoPreviewWidth = UIScreen.main.bounds.size.width * self.videoPreviewPercentageOfScreenWidth
			self.view.snp.remakeConstraints{ (make) in
				if (hasVideo == true) {
					make.width.equalTo(videoPreviewWidth)
				} else if (self.view.superview != nil) {
					make.width.equalTo(self.view.superview!.snp.width)
				}
				make.height.equalTo(hasVideo! ? videoPreviewWidth / self.videoAspectRatio : iconSize)
			}

			if (!initialReading && self.owningViewContraintMaker != nil) {
				self.view.snp.makeConstraints(self.owningViewContraintMaker!)
			}
			initialReading = false
			
			self.iconView!.isHidden = hasVideo!
			self.videoView!.isHidden = !hasVideo! || self.rotated
			self.videoViewRotated?.isHidden = !hasVideo! || !self.rotated
			
			self.fullSizeVideoButton!.isHidden = !hasVideo!
		}
		
				
	}
	
	
	
	override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
		super.viewWillTransition(to: size, with: coordinator)
		if (UIDevice.ipad()) {
			rotated = !rotated
			callViewModel.videoContent.notifyValue()
			coordinator.animate(alongsideTransition: { context in
				let iconSize = UIScreen.main.bounds.size.width * self.iconPercentageOfScreenWidth * ( UIDevice.ipad() ? 0.5 : 1)
				self.iconView!.frame = CGRect(x: 0,y: 0,width: iconSize ,height: iconSize)
				self.videoPreviewPercentageOfScreenWidth  = UIDevice.ipad() ? UIScreen.isLandscape ? 0.5 : 0.9 : 0.95
				self.videoView!.isHidden = !self.callViewModel.videoContent.value! || self.rotated
				self.videoViewRotated!.isHidden = !self.callViewModel.videoContent.value! || !self.rotated
				if (!self.callViewModel.videoFullScreen.value!) {
					Core.get().nativeVideoWindowId = UnsafeMutableRawPointer(Unmanaged.passRetained(!self.rotated ? self.videoView! : self.videoViewRotated!).toOpaque())
				}
				self.callViewModel.videoContent.notifyValue()
				self.fullSizeVideoButton!.snp.remakeConstraints { (make) in
					make.top.equalTo(self.rotated ? self.videoViewRotated!.snp.top : self.videoView!.snp.top).offset(13)
					make.right.equalTo(self.rotated ? self.videoViewRotated!.snp.right : self.videoView!.snp.right).offset(-13)
				}
			}, completion: { context in
			})
		}
	}
	
	func computePercentageWidth(videoSize : CGSize) -> CGFloat {
		let screenHeight = UIScreen.main.bounds.size.height
		let screenWidth = UIScreen.main.bounds.size.width
		let availableHeightPx = screenHeight - reservedHeight
		let videoRatio: CGFloat = CGFloat(videoSize.width / videoSize.height)
		let availableWidthPx = availableHeightPx * videoRatio
		let result =  availableWidthPx / screenWidth
		Log.info("Computing video metrics : screen=\(screenWidth)/\(screenHeight) videoSize=\(videoSize.width)/\(videoSize.height) reservedpxheight=\(reservedHeight) computed withpct=\(result)")
		Log.info("Computing video metrics : video height should not exceed : \(availableHeightPx) and is \(result*screenWidth)")
		return  result > 0.95 ? 0.95 : result
	}
	
}
