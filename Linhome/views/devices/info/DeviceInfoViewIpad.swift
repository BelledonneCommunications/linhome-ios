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
import DropDown

class DeviceInfoViewIpad: MainViewContent  {
	
	var device:Device?
	var actionsTitle : UILabel?
	var typeIcon:UIImageView?
	var separator:UIView?
	var actionsButtonRow : UIStackView? = nil
	var deviceIconNameCall : UIView?
	var callAudio: UIButton?
	var callVideo: UIButton?
	var deviceImage: UIImageView?
	
	override func viewDidLoad() {
		super.viewDidLoad()
		isRoot = false
		onTopOfBottomBar = true
		titleTextKey = "devices"
		
		
		let scrollView = UIScrollView()
		view.addSubview(scrollView)
		scrollView.snp.makeConstraints { make in
			make.edges.equalTo(view)
		}
		
		let contentView = UIView()
		scrollView.addSubview(contentView)
		contentView.snp.makeConstraints { make in
			make.edges.equalTo(view)
		}		
		
		deviceIconNameCall = UIView()
		deviceIconNameCall!.layer.cornerRadius = CGFloat(Customisation.it.themeConfig.getFloat(section: "arbitrary-values", key: "device_in_device_list_corner_radius", defaultValue: 0.0))
		deviceIconNameCall!.clipsToBounds = true
		contentView.addSubview(deviceIconNameCall!)
		deviceIconNameCall!.snp.makeConstraints { make in
			make.top.equalToSuperview().offset(32)
			make.centerX.equalTo(view.snp.centerX)
			make.width.equalTo(300)
			make.height.equalTo(225)
		}
		deviceIconNameCall?.backgroundColor = Theme.getColor("color_i")
		
		
		deviceImage = UIImageView()
		deviceIconNameCall!.addSubview(deviceImage!)
		deviceImage!.snp.makeConstraints { (make) in
			make.edges.equalToSuperview()
		}
		deviceImage?.alpha = 0.3

				
		
		typeIcon = UIImageView()
		deviceIconNameCall!.addSubview(typeIcon!)
		typeIcon!.snp.makeConstraints { make in
			make.centerX.centerY.equalToSuperview()
			make.width.height.equalTo(86)
		}
		
		
		callVideo = UIButton(frame: CGRect(x: 0,y: 0,width: 50,height: 50))
		callVideo?.prepareRoundIcon(effectKey: "primary_color", tintColor: "color_c", iconName: "icons/eye", padding: 12)
		deviceIconNameCall!.addSubview(callVideo!)
		callVideo!.snp.makeConstraints { (make) in
			make.width.height.equalTo(50)
			make.right.equalToSuperview().offset(-15)
			make.bottom.equalToSuperview().offset(-15)
		}
		
		
		callAudio = UIButton(frame: CGRect(x: 0,y: 0,width: 50,height: 50))
		callAudio?.prepareRoundIcon(effectKey: "primary_color", tintColor: "color_c", iconName: "icons/phone.png", padding: 12)
		deviceIconNameCall!.addSubview(callAudio!)
		callAudio!.snp.makeConstraints { (make) in
			make.width.height.equalTo(50)
			make.right.equalToSuperview().offset(-15)
			make.bottom.equalToSuperview().offset(-15)
		}
						
		actionsTitle = UILabel()
		contentView.addSubview(actionsTitle!)
		actionsTitle!.snp.makeConstraints { make in
			make.top.equalTo(deviceIconNameCall!.snp.bottom).offset(55)
			make.centerX.equalTo(view.snp.centerX)
		}
		
		separator = UIView()
		separator!.backgroundColor = Theme.getColor("color_h")
		contentView.addSubview(separator!)
		separator!.snp.makeConstraints { (make) in
			make.top.equalTo(actionsTitle!.snp.bottom).offset(5)
			make.height.equalTo(1)
			make.width.equalToSuperview().inset(20)
			make.centerX.equalToSuperview()
		}
		
	
		
	}
	
	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		
		guard let device = NavigationManager.it.nextViewArgument as! Device? else {
			NavigationManager.it.navigateUp()
			return
		}
		
		self.device = device
		
		NavigationManager.it.mainView?.toolbarViewModel.rightButtonVisible.value = false
		NavigationManager.it.mainView?.toolbarViewModel.leftButtonVisible.value = false
		

		device.type.map { type in
			DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(20)) {
				self.typeIcon!.prepare(iconName: DeviceTypes.it.iconNameForDeviceType(typeKey:type)!, fillColor: nil, bgColor: nil)
			}
		}
		actionsTitle!.prepare(styleKey: "view_device_info_actions_title",text: device.actions != nil && device.actions!.count > 0 ? Texts.get("device_info_actions_title") : Texts.get("device_info_no_actions_title"))
		
		// Device actions button
		if (actionsButtonRow != nil) {
			actionsButtonRow?.removeFromSuperview()
		}
		device.actions.map { actions in
			if (actions.count > 0) {
				actionsButtonRow = UIStackView()
				actionsButtonRow?.spacing = 10
				actionsButtonRow!.axis = .horizontal
				actionsButtonRow!.distribution = .fillEqually
				actionsButtonRow?.alignment = .center
				self.view.addSubview(actionsButtonRow!)
				actionsButtonRow!.snp.makeConstraints { (make) in
					make.top.equalTo(separator!.snp.bottom).offset(50)
					make.width.equalToSuperview()
					make.centerX.equalToSuperview()
				}
				actions.forEach { action in
					let actionButton = CallButton.addOne(targetVC: self, iconName: action.iconName()!, text: "\(action.actionText()!) - \(action.code!)", effectKey: "incall_call_button", tintColor: "color_b",  outLine: false, action: {}, toStackView:actionsButtonRow!, outLineColorKey: "color_b")
					actionButton.view.isUserInteractionEnabled = false
					actionButton.labelOn.textColor = Theme.getColor("color_b")
				}
			}
		}
		
		callVideo?.isHidden = !device.supportsVideo()
		callAudio?.isHidden = !(callVideo?.isHidden ?? true)
		device.type.map { type in
			DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(5)) {
				self.typeIcon!.prepareSwiftSVG(iconName: DeviceTypes.it.iconNameForDeviceType(typeKey:type)!, fillColor: nil, bgColor: nil)
			}
		}
		callAudio?.onClick {
			device.call()
		}
		callVideo?.onClick {
			device.call()
		}
		
		self.setThumpNail(device: device)
		
		DeviceStore.it.updatedSnapshotDeviceId.observe { (deviceId) in
			DeviceStore.it.devices.forEach {
				var i = 0
				if (self.device?.id == $0.id) {
					self.setThumpNail(device: $0)
				}
				i += 1
			}
		}
		
	}
	
	func setThumpNail(device:Device) {
		if (device.hasThumbNail()) {
			deviceImage?.image = UIImage(contentsOfFile: device.thumbNail)
			deviceImage?.isHidden = false
			typeIcon?.isHidden = true
			if let thumb = UIImage(contentsOfFile: device.thumbNail) {
				let ratio = thumb.size.height / thumb.size.width
				deviceIconNameCall!.snp.remakeConstraints { make in
					make.top.equalToSuperview().offset(32)
					make.centerX.equalTo(view.snp.centerX)
					make.width.equalTo(UIScreen.isLandscape && thumb.size.height > thumb.size.width ? 180 : 300)
					make.height.equalTo(deviceIconNameCall!.snp.width).multipliedBy(ratio)
				}
			}
		}
	}
	
	override func onToolbarRightButtonClicked() {
		NavigationManager.it.navigateTo(childClass: DeviceEditorView.self, asRoot: false, argument: device)
	}
	
	
}
