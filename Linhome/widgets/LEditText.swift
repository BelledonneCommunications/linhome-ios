//
//  UILabe+Extension.swift
//  Linhome
//
//  Created by Christophe Deschamps on 18/06/2020.
//  Copyright © 2020 Belledonne communications. All rights reserved.
//

import Foundation
import UIKit


class LEditText: UITextField {
	
	var normalBackgroundColor : UIColor?
	var errorBackgroundColor : UIColor?
	
	var normalTextColor:UIColor?
	var errorTextColor:UIColor?
	
	var hintColor:UIColor?
	
	var virgin:Bool = true
	
	func errorMode()  {
		backgroundColor = errorBackgroundColor
		tintColor = errorTextColor
	}
	
	func inputMode() {
		backgroundColor = normalBackgroundColor
		tintColor = normalTextColor
	}
	
	func setHint(text:String) {
		attributedPlaceholder = NSAttributedString(string: text, attributes: [NSAttributedString.Key.foregroundColor:  (hintColor ?? UIColor.gray)])
	}
	
	override func textRect(forBounds bounds: CGRect) -> CGRect {
		return bounds.insetBy(dx: 13.0, dy: 0)
	  }

	override func editingRect(forBounds bounds: CGRect) -> CGRect {
		return self.textRect(forBounds: bounds)
	  }
		
}


extension LEditText {

	func isEmptyOrNull() -> Bool {
		return text == nil || text!.isEmpty
	}
	
	private func setStyle(_ textViewKey:String) {
		
		let section = "textedit-style.\(textViewKey)"
		let config = Customisation.it.themeConfig
		
		if let color = config?.getString(section: section, key: "text-color") {
			normalTextColor = Theme.getColor(color)
		}
		if let color = config?.getString(section: section, key: "error-text-color") {
			normalTextColor = Theme.getColor(color)
		}
		if let color = config?.getString(section: section, key: "background-color") {
			normalBackgroundColor = Theme.getColor(color)
		}
		if let color = config?.getString(section: section, key: "error-background-color") {
			errorBackgroundColor = Theme.getColor(color)
		}
		if let color = config?.getString(section: section, key: "hint-text-color") {
			hintColor  = Theme.getColor(color)
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
		let fontSizeMultiplier: Float = 1.0
		if let fontName = config?.getString(section: section, key: "font"), let fontSize = config?.getFloat(section: section, key: "size", defaultValue: 12.0), let font = Theme.getFont(fontName, fontSize*fontSizeMultiplier) {
			self.font = font
		}
		
		layer.cornerRadius = CGFloat(Customisation.it.themeConfig.getFloat(section: "arbitrary-values", key: "user_input_corner_radius", defaultValue: 0.0))
		
		inputMode()
		autocorrectionType = .no

	}
	
	func prepare(styleKey:String, text:String?) {
		self.text = text
		self.prepare(styleKey: styleKey)
	}
	
	func prepare(styleKey:String, textKey:String) {
		self.text = Texts.get(textKey)
		self.prepare(styleKey: styleKey)
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
	
	func setTextViaTextKey(textKey:String?) {
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

