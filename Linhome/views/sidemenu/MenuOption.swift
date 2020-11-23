//
//  MenuOption.swift
//  Linhome
//
//  Created by Christophe Deschamps on 22/06/2020.
//  Copyright © 2020 Belledonne communications. All rights reserved.
//

import UIKit

class MenuOption: NSObject {
	
	var iconName: String
	var textKey: String
	var action: (() -> ())
	
	init(iconName:String,textKey:String,action: @escaping ()->Void) {
		self.iconName = iconName
		self.textKey = textKey
		self.action = action
	}
	

}
