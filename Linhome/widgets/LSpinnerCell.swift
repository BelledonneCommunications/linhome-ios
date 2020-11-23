//
//  ActionPickerCell.swift
//  Linhome
//
//  Created by Christophe Deschamps on 30/06/2020.
//  Copyright © 2020 Belledonne communications. All rights reserved.
//

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
				make.left.equalTo(contentView.snp.left).offset(60)
				make.centerY.equalTo(contentView.snp.centerY)
			}
		} else {
			icon.isHidden = true
			optionLabel.snp.updateConstraints { (make) in
				make.left.equalTo(contentView.snp.left).offset(20)
				make.centerY.equalTo(contentView.snp.centerY)
			}
		}
		
	}
}
