//
//  UIRoundRectButton.swift
//  Linhome
//
//  Created by Christophe Deschamps on 03/07/2020.
//  Copyright © 2020 Belledonne communications. All rights reserved.
//

import Foundation
import UIKit


class UIRoundRectButtonWithIcon : UIButton {
	
	convenience init(container: UIView, placedBelow:UIView, effectKey:String, tintColor:String, textKey:String, topMargin:CGFloat, iconName:String, isLastInContainer:Bool = false) {
		self.init()
		container.addSubview(self)
		self.snp.makeConstraints { make in
			make.top.equalTo(placedBelow.snp.bottom).offset(topMargin)
			make.centerX.equalTo(container.snp.centerX)
			make.height.equalTo(40)
			if (isLastInContainer) {
				make.bottom.equalTo(container.snp.bottom).offset(-20)
			}
			make.width.greaterThanOrEqualTo(UIDevice.ipad() ? 220 : 180)
		}
		prepareRoundRectWihIcon(effectKey:effectKey, tintColor:tintColor, textKey:textKey, iconName:iconName)
	}
	
}
