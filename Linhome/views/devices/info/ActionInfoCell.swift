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

class ActionInfoCell: UITableViewCell {
	@IBOutlet weak var title: UILabel!
	@IBOutlet var actionType: UIImageView!
	@IBOutlet var actionName: UILabel!
	@IBOutlet var actionCode: UILabel!
	@IBOutlet weak var topSep: UIView!
	@IBOutlet weak var botSep: UIView!
	
    override func awakeFromNib() {
        super.awakeFromNib()
		actionName.prepare(styleKey: "dropdown_list")
		actionCode.prepare(styleKey: "dropdown_list")
		topSep.backgroundColor = Theme.getColor("color_h")
		botSep.backgroundColor = Theme.getColor("color_h")
	}
    
}
