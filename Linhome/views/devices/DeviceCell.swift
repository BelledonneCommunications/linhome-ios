//
//  DeviceCell.swift
//  Linhome
//
//  Created by Christophe Deschamps on 02/07/2020.
//  Copyright © 2020 Belledonne communications. All rights reserved.
//

import UIKit

class DeviceCell: UITableViewCell {
	
	static let spaceBetweenCells  = UIDevice.ipad() ? 0 : 10
	
	@IBOutlet weak var deviceImage: UIImageView?
	@IBOutlet weak var name: UILabel!
	@IBOutlet weak var address: UILabel!
	@IBOutlet weak var typeIcon: UIImageView!
	@IBOutlet weak var callAudio: UIButton?
	@IBOutlet weak var callVideo: UIButton?
	@IBOutlet weak var ipadSeparator: UIView!
	
	override func awakeFromNib() {
		super.awakeFromNib()
		contentView.backgroundColor = UIDevice.ipad() ? .clear : Theme.getColor("color_i")
		name.prepare(styleKey: "device_list_device_name")
		address.prepare(styleKey: "device_list_device_address")
		
		if (!UIDevice.ipad()) {
			callVideo?.prepareRoundIcon(effectKey: "primary_color", tintColor: "color_c", iconName: "icons/eye", padding: 12)
			callAudio?.prepareRoundIcon(effectKey: "primary_color", tintColor: "color_c", iconName: "icons/phone.png", padding: 12) // Fall back, unhandled svg
			contentView.layer.cornerRadius = CGFloat(Customisation.it.themeConfig.getFloat(section: "arbitrary-values", key: "device_in_device_list_corner_radius", defaultValue: 0.0))
			contentView.clipsToBounds = true
		}
		deviceImage?.isHidden = true
		
		contentView.snp.makeConstraints { (make) in
			make.height.greaterThanOrEqualTo(120)
			make.centerX.equalToSuperview()
			make.left.equalToSuperview().offset(UIDevice.ipad()  ? 0 : 50)
		}
		
		if (!UIDevice.ipad()) {
			name.snp.makeConstraints { (make) in
				make.left.equalToSuperview().offset(20)
				make.bottom.equalTo(address.snp.top).offset(-1)
			}
			address.snp.makeConstraints { (make) in
				make.left.equalToSuperview().offset(20)
				make.bottom.equalToSuperview().offset(-17)
			}
		} else {
			name.snp.makeConstraints { (make) in
				make.left.equalTo(typeIcon.snp.right).offset(20)
				make.top.equalTo(typeIcon.snp.top).offset(1)
			}
			
			address.snp.makeConstraints { (make) in
				make.left.equalTo(typeIcon.snp.right).offset(20)
				make.bottom.equalTo(typeIcon.snp.bottom).offset(-1)
			}
			ipadSeparator?.backgroundColor = Theme.getColor("color_h")
		}
		
	}
	
	func setDevice(device:Device) {
		name.setText(text: device.name)
		address.setText(text: device.address)
		callVideo?.isHidden = UIDevice.ipad() || !device.supportsVideo()
		callAudio?.isHidden = UIDevice.ipad() || !(callVideo?.isHidden ?? true)
		device.type.map { type in
			DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(5)) {
				self.typeIcon.prepareSwiftSVG(iconName: DeviceTypes.it.iconNameForDeviceType(typeKey:type)!, fillColor: nil, bgColor: nil)
			}
		}
		callAudio?.onClick {
			device.call()
		}
		callVideo?.onClick {
			device.call()
		}
		
		if (device.hasThumbNail() && !UIDevice.ipad()) {
			deviceImage?.image = UIImage(contentsOfFile: device.thumbNail)
			deviceImage?.isHidden = false
			if let thumb = UIImage(contentsOfFile: device.thumbNail) {
				let ratio = thumb.size.height / thumb.size.width
				contentView.snp.updateConstraints { (make) in
					make.height.greaterThanOrEqualTo(contentView.frame.size.width * ratio)
				}
			}
		} else {
			deviceImage?.isHidden = true
			contentView.snp.updateConstraints { (make) in
				make.height.greaterThanOrEqualTo(120)
			}
		}
	}
	
	override func layoutSubviews() {
		super.layoutSubviews()
		if (!UIDevice.ipad()) {
			contentView.frame = contentView.frame.inset(by: UIEdgeInsets(top: 5, left: 0, bottom: 5, right: 0))
		}
	}
	
}
