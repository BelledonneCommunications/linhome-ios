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


extension UIView {
	
	func setGradientColor(_ gradientColorKey: String, opacity: Float = 1) {
		let entireKey = "gradient-color.\(gradientColorKey)"
		guard let fromColor = Customisation.it.themeConfig.getString(section: entireKey, key: "from") else {
			Theme.themeError("[Theme] Failed retrieving gradient color:\(gradientColorKey)")
			return
		}
		
		guard let toColor = Customisation.it.themeConfig.getString(section: entireKey, key: "to") else {
			Theme.themeError("[Theme] Failed retrieving gradient color:\(gradientColorKey)")
			return
		}
		
		guard let orientation = Customisation.it.themeConfig.getString(section: entireKey, key: "orientation") else {
			Theme.themeError("[Theme] Failed retrieving gradient color:\(gradientColorKey)")
			return
		}
		
		let colors = [Theme.getColor(fromColor),Theme.getColor(toColor)]
		
		let gradientLayer = CAGradientLayer()
		gradientLayer.opacity = opacity
		gradientLayer.colors = colors.map { $0.cgColor }
		
		if case "left_right" = orientation {
			gradientLayer.startPoint = CGPoint(x: 0.0, y: 0.0)
			gradientLayer.endPoint = CGPoint(x: 1.0, y: 0.0)
		} else if case "right_left" = orientation {
			gradientLayer.startPoint = CGPoint(x: 0.0, y: 0.0)
			gradientLayer.endPoint = CGPoint(x: 0.0, y: 1.0)
		} else if case "bottom_top" = orientation {
			gradientLayer.startPoint = CGPoint(x: 0.0, y: 1.0)
			gradientLayer.endPoint = CGPoint(x: 0.0, y: 0.0)
		} else {
			gradientLayer.startPoint = CGPoint(x: 0.0, y: 0.0)
			gradientLayer.endPoint = CGPoint(x: 0.0, y: 1.0)
		}
		gradientLayer.bounds = self.bounds
		gradientLayer.anchorPoint = CGPoint.zero
		self.layer.addSublayer(gradientLayer)
	}
	
	func onClick(action : @escaping ()->Void ){
		let tap = TapGestureRecognizer(target: self , action: #selector(self.handleTap(_:)))
		tap.action = action
		tap.numberOfTapsRequired = 1
		
		self.addGestureRecognizer(tap)
		self.isUserInteractionEnabled = true
		
	}
	@objc func handleTap(_ sender: TapGestureRecognizer) {
		sender.action!()
	}
	
	
	func setFrameHeight(_ height:CGFloat) {
		var r = self.frame
		r.size.height = height
		self.frame = r
	}
	
	func clickEffect(effectKey:String) {
		Theme.selectionEffectColors(effectKey: effectKey).map { colors in
			backgroundColor = colors[1]
			DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(100)) {
				self.backgroundColor = colors[0]
			}
		}
	}
	
	func stopAnimations() {
		self.layer.removeAllAnimations()
	}
	
	func startBouncing(offset:CGFloat) {
		var r = self.frame
		r.origin.y = -6
		self.frame = r
		UIView.setAnimationsEnabled(true)
		UIView.animate(withDuration:0.4, delay:0 ,
					   options: [.autoreverse, .repeat, .curveEaseIn],
					   animations: {
						var r = self.frame
						r.origin.y += offset
						self.frame = r
		}, completion:nil)

	}
	
}

