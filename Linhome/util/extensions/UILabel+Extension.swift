//
//  UILabe+Extension.swift
//  Linhome
//
//  Created by Christophe Deschamps on 18/06/2020.
//  Copyright © 2020 Belledonne communications. All rights reserved.
//

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
		let fontSizeMultiplier: Float = (UIDevice.ipad() ? 1.25 : 1.0)
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

