//
//  UIAlertController+extension.swift
//  Linhome
//
//  Created by Christophe Deschamps on 22/06/2020.
//  Copyright © 2020 Belledonne communications. All rights reserved.
//

import Foundation
import UIKit


extension UIAlertController {
	override open func viewWillLayoutSubviews() {
		super.viewWillLayoutSubviews()
		self.view.tintColor = Theme.getColor("color_a")
	}
}
