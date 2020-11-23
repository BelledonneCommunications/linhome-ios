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


class UIRoundRectButton : UIButton {
	
	convenience init(container: UIView, placedBelow:UIView, effectKey:String, tintColor:String, textKey:String, topMargin:CGFloat, isLastInContainer:Bool = false) {
		self.init()
		container.addSubview(self)
		self.snp.makeConstraints { make in
			make.top.equalTo(placedBelow.snp.bottom).offset(topMargin)
			make.centerX.equalTo(container.snp.centerX)
			make.height.equalTo(40)
			make.leftMargin.rightMargin.equalTo(20)
			make.width.lessThanOrEqualTo(320)
			if (isLastInContainer) {
				make.bottom.equalTo(container.snp.bottom).offset(-20)
			}
		}
		self.prepareRoundRect(effectKey : effectKey, tintColor: tintColor, textKey: textKey)
	}

	
}
