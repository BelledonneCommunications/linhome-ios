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
