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
import DropDown

class LSpinnerCell: DropDownCell {
	
	@IBOutlet weak var icon: UIImageView!
	@IBOutlet weak var separator: UIView!
	
	func setContent(item:SpinnerItem) {
		optionLabel.prepare(styleKey: "text_input_text")
		separator.backgroundColor = Theme.getColor("color_h")
		optionLabel.text = Texts.get(item.textKey)
		if (item.iconFile != nil) {
			icon.prepareSwiftSVG(iconName:item.iconFile!, fillColor: nil, bgColor: "nil")
			icon.isHidden = false
			optionLabel.snp.updateConstraints { (make) in
				make.left.equalTo(contentView.snp.left).offset(UIDevice.is5SorSEGen1() ? 45 :  60)
				make.centerY.equalTo(contentView.snp.centerY)
				make.right.equalToSuperview().offset(-35)
			}
		} else {
			icon.isHidden = true
			optionLabel.snp.updateConstraints { (make) in
				make.left.equalTo(contentView.snp.left).offset(UIDevice.is5SorSEGen1() ? 10 :20)
				make.centerY.equalTo(contentView.snp.centerY)
				make.right.equalToSuperview().offset(-35)
			}
		}
		
	}
}
