//
//  Array+Extension.swift
//  Linhome
//
//  Created by Christophe Deschamps on 30/06/2020.
//  Copyright © 2020 Belledonne communications. All rights reserved.
//

import Foundation
import UIKit

extension UIView {
	func toggleVisible() {
		let hidden = !self.isHidden
		if self.isHidden && !hidden {
			self.alpha = 0.0
			self.isHidden = false
		}
		UIView.animate(withDuration: 0.25, animations: {
			self.alpha = hidden ? 0.0 : 1.0
		}) { (complete) in
			self.isHidden = hidden
		}
	}
	
	func forceVisible() {
		self.alpha = 1.0
		self.isHidden = false
	}
}
