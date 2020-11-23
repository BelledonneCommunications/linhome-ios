//
//  DeviceCell.swift
//  Linhome
//
//  Created by Christophe Deschamps on 02/07/2020.
//  Copyright © 2020 Belledonne communications. All rights reserved.
//

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
