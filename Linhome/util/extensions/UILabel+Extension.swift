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


extension UILabel {
	
	
	private func setStyle(_ textViewKey:String) {
		let section = "textview-style.\(textViewKey)"
		let config = Customisation.it.themeConfig
		
		if let color = config?.getString(section: section, key: "text-color") {
			self.textColor = Theme.getColor(color)
		}
		
		if let color = config?.getString(section: section, key: "background-color") {
			self.backgroundColor = Theme.getColor(color)
		}
		
		if let caps = config?.getBool(section: section, key: "allcaps", defaultValue : false) {
			if (caps) {
				self.text = self.text?.uppercased()
				tag = 1
			}
		}
		
		if let align = config?.getString(section: section, key: "align") {
			if case "start" = align {
				self.textAlignment = .natural
			}
			if case "center" = align {
				self.textAlignment = .center
			}
			if case "end" = align {
				self.textAlignment = .right
			}
		}
		let fontSizeMultiplier: Float = (UIDevice.ipad() ? 1.25 : UIDevice.is5SorSEGen1() ? 0.9 : 1.0)
		if let fontName = config?.getString(section: section, key: "font"), let fontSize = config?.getFloat(section: section, key: "size", defaultValue: 12.0), let font = Theme.getFont(fontName, fontSize*fontSizeMultiplier) {
			self.font = font
		}
	}
	
	func prepare(styleKey:String, text:String?) {
		self.text = text
		self.prepare(styleKey: styleKey)
	}
	
	func prepare(styleKey:String, textKey:String, backgroundColorKey: String? = nil) {
		self.text = Texts.get(textKey)
		self.prepare(styleKey: styleKey)
		backgroundColorKey.map{backgroundColor = Theme.getColor($0)}
	}
	

	
	func prepare(styleKey:String, textKey:String, arg1:String) {
		self.text = Texts.get(textKey,oneArg: arg1)
		self.prepare(styleKey: styleKey)
	}
	
	func prepare(styleKey:String, textKey:String, arg1:String, arg2:String) {
		self.text = Texts.get(textKey,arg1: arg1,arg2: arg2)
		self.prepare(styleKey: styleKey)
	}
	
	func prepare(styleKey:String) {
		self.setStyle(styleKey)
	}
	
	func setText(text:String) {
		self.text = text
		if (tag == 1) {
			self.text = self.text?.uppercased()
		}
	}
	
	func setText(textKey:String?) {
		if (textKey != nil ) {
			self.text = Texts.get(textKey!)
			if (tag == 1) {
				self.text = self.text?.uppercased()
			}
		} else {
			self.text = nil
		}
	}
	
}

