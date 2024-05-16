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
			(UIApplication.shared.delegate as! AppDelegate).preventEnterinBackground = true
			AVCaptureDevice.requestAccess(for: AVMediaType.video) { granted in
				DispatchQueue.main.async {
					(UIApplication.shared.delegate as! AppDelegate).preventEnterinBackground = false
					if granted {
						NavigationManager.it.navigateTo(childClass: RemoteQr.self)
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
