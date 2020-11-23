//
//  ChunkCallVideoOrIcon.swift
//  Linhome
//
//  Created by Christophe Deschamps on 10/07/2020.
//  Copyright © 2020 Belledonne communications. All rights reserved.
//

import UIKit
import linphonesw
import SnapKit

class ChunkCallVideoOrIcon: UIViewController {
	
	let callViewModel : CallViewModel
	
	let iconPercentageOfScreenWidth: CGFloat = 0.4
	var videoPreviewPercentageOfScreenWidth: CGFloat = UIDevice.ipad() ? UIScreen.isLandscape ? 0.5 : 0.9 : 0.95
	var videoPreviewPercentageOfScreenWidthRotated: CGFloat = UIDevice.ipad() ? UIScreen.isLandscape ? 0.9 : 0.5 : 0.95
	let videoAspectRatio: CGFloat = 4/3
	
	let owningViewContraintMaker : ((ConstraintMaker) -> Void)?
	
	var iconView : UIImageView?
	
	var videoView, videoViewRotated : UIView?
	var fullSizeVideoButton : UIButton?
	var rotated = false
	
	init(viewModel:CallViewModel, owningViewContraintMaker: ((ConstraintMaker) -> Void)? = nil) {
		self.callViewModel = viewModel
		self.owningViewContraintMaker = owningViewContraintMaker
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
		
		videoView = UIView()
		videoView!.backgroundColor = .black
		let videoPreviewWidth = UIScreen.main.bounds.size.width * videoPreviewPercentageOfScreenWidth
		videoView!.frame = CGRect(x: 0,y: 0,width: videoPreviewWidth ,height: videoPreviewWidth / videoAspectRatio)
		self.view.addSubview(videoView!)
		Core.get().nativeVideoWindowId = UnsafeMutableRawPointer(Unmanaged.passRetained(videoView!).toOpaque())
		
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
		
		callViewModel.videoContent.readCurrentAndObserve { (hasVideo) in
			let videoPreviewWidth = UIScreen.main.bounds.size.width * self.videoPreviewPercentageOfScreenWidth
			self.view.snp.remakeConstraints{ (make) in
				make.width.equalTo(hasVideo! ? videoPreviewWidth : iconSize)
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
	
	
}
