//
//  SideMenuOption.swift
//  Linhome
//
//  Created by Christophe Deschamps on 22/06/2020.
//  Copyright © 2020 Belledonne communications. All rights reserved.
//

import UIKit

class SideMenuCell: UITableViewCell {
	@IBOutlet weak var icon: UIImageView!
	@IBOutlet weak var title: UILabel!
	@IBOutlet weak var bottomSeparator: UIView!
	@IBOutlet weak var topSeparator: UIView!
	
    override func awakeFromNib() {
        super.awakeFromNib()
		title.prepare(styleKey: "sidemenu_option")
		Theme.selectionEffectColors(effectKey: "sidemenu_option").map { colors in
			backgroundColor = colors[0]
			let bgColorView = UIView()
			bgColorView.backgroundColor = colors[1]
			selectedBackgroundView = bgColorView
		}
		
		topSeparator.backgroundColor = Theme.getColor("color_h")
		bottomSeparator.backgroundColor = Theme.getColor("color_h")
    }
	
	func brand() {
		
	}
	
	func prepare(option:MenuOption, hideTopSeparator:Bool, hideBottomSeparator:Bool) -> UITableViewCell {
		icon.prepare(iconName: option.iconName, fillColor: "color_c", bgColor: nil)
		title.setText(textKey: option.textKey)
		topSeparator.isHidden = hideTopSeparator
		bottomSeparator.isHidden = hideBottomSeparator
		self.onClick {
			option.action()
		}
		
		return self
	}
    
}
