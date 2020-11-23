//
//  SideMenuViewViewController.swift
//  Linhome
//
//  Created by Christophe Deschamps on 22/06/2020.
//  Copyright © 2020 Belledonne communications. All rights reserved.
//

import UIKit
import AVFoundation

class RemoteRoot: MainViewContentWithScrollableForm {
	
		
	override func viewDidLoad() {
		
		super.viewDidLoad()
		isRoot = false
		onTopOfBottomBar = true
		titleTextKey = "assistant"
		
		viewTitle.setText(textKey: "assistant_remote_prov")
		hideSubtitle()
		
		let infoText = UILabel(frame:CGRect(x: 0,y: 0,width: 200,height: 100))
		infoText.numberOfLines = 6
		infoText.prepare(styleKey: "info_bubble", textKey: "assistant_remote_prov_infobubble", backgroundColorKey: "color_n")
		infoText.isHidden = true
		self.view.addSubview(infoText)
		
		let  infoButton = UIButton(frame:CGRect(x: 0,y: 0,width: 20,height: 20))
		infoButton.prepareRoundIcon(effectKey: "info_bubble", tintColor: "color_c", iconName: "icons/informations")
		infoButton.onClick {
			infoText.isHidden = !infoText.isHidden
		}
		self.view.addSubview(infoButton)

		
		infoButton.snp.makeConstraints { (make) in
			make.left.equalTo(viewTitle.snp.right).offset(-20)
			make.bottom.equalTo(viewTitle.snp.top)
		}
		
		infoText.snp.makeConstraints { (make) in
			make.right.equalTo(infoButton.snp.left)
			make.top.equalTo(infoButton.snp.bottom)
			make.height.equalTo(100)
			make.width.equalTo(200)

		}
		
		
		let url = UIRoundRectButton(container:contentView, placedBelow:form, effectKey: "secondary_color", tintColor: "color_c", textKey: "assistant_remote_url", topMargin: 0)
		let qrCode = UIRoundRectButton(container:contentView, placedBelow:url, effectKey: "secondary_color", tintColor: "color_c", textKey: "assistant_remote_qr", topMargin: 23, isLastInContainer: true)
			
		
		url.prepareRoundRect(effectKey: "secondary_color", tintColor: "color_c", textKey: "assistant_remote_url")
		qrCode.prepareRoundRect(effectKey: "secondary_color", tintColor: "color_c", textKey: "assistant_remote_qr")
		
		url.onClick {
			NavigationManager.it.navigateTo(childClass: RemoteUrlView.self)
		}
		
		qrCode.onClick {
			AVCaptureDevice.requestAccess(for: AVMediaType.video) { granted in
				DispatchQueue.main.async {
					if granted {
						DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(1)) {
							NavigationManager.it.navigateTo(childClass: RemoteQr.self)
						}
					} else {
						DialogUtil.error("camera_permission_denied")
					}
				}
			}
		}
		
		view.onClick {
			infoText.isHidden = true
		}
		
	}
	
}
