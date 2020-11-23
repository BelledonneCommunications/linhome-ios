//
//  UIButton+topBar.swift
//  Linhome
//
//  Created by Christophe Deschamps on 19/06/2020.
//  Copyright © 2020 Belledonne communications. All rights reserved.
//

import Foundation
import UIKit

extension UIButton {
	
	func setText(text:String) {
		setTitle(titleLabel?.tag == 1 ? text.uppercased() : text, for: .normal)
	}
	
	func setTextKey(textKey:String) {
		setTitle(titleLabel?.tag == 1 ? Texts.get(textKey).uppercased() :  Texts.get(textKey), for: .normal)
	}
	
	func prepare( iconName:String,  tintColor:String) { // ! only works with buttonType = custom (set in nib)
		self.tintColor = UIColor.clear
		let tintColor = Theme.getColor(tintColor)
		setTitle(nil, for: .normal)
		imageView!.contentMode = .scaleAspectFit
		Theme.svgToUiImage(iconName,frame.size,UIColor.clear,tintColor).map { setImage($0,for: .normal)}
	}
	
	func prepare( iconName:String, effectKey:String, effectIsFg:Bool = false, tintColor:String, textStyleKey:String?=nil, text:String? = nil, padding:CGFloat = 25) { // ! only works with buttonType = custom (set in nib)
		
		self.tintColor = UIColor.clear
		
		let tintColor = Theme.getColor(tintColor)
		
		let hasText = text != nil && textStyleKey != nil
		var titleSize:CGSize? = nil
		
		if (hasText) {
			setTitleColor(tintColor, for: .normal)
			titleLabel?.prepare(styleKey: textStyleKey!)
			setTitle(titleLabel?.tag == 1 ? text?.uppercased() : text, for: .normal)
			titleSize = titleLabel!.text!.size(withAttributes: [
				NSAttributedString.Key.font: titleLabel!.font ?? UIFont.systemFont(ofSize: 12.0)
			])
			var imageViewFrame = imageView!.frame
			imageViewFrame.size.height -= titleSize!.height + padding
			imageView!.frame = imageViewFrame
		} else {
			setTitle(nil, for: .normal)
		}
		
		var size = frame.size
		if (hasText) {
			size.height -= titleSize!.height + padding
		}
		
		imageView!.contentMode = .scaleAspectFit
		
		if (!effectIsFg) {
			Theme.svgToUiImage(iconName,size,UIColor.clear,tintColor).map { setImage($0,for: .normal)}
			Theme.selectionEffectColors(effectKey: effectKey).map { colors in
				setBackgroundColor(color: colors[0],forState: .normal)
				setBackgroundColor(color: colors[1],forState: .highlighted)
			}
		} else {
			Theme.selectionEffectColors(effectKey: effectKey).map { colors in
				Theme.svgToUiImage(iconName,size,UIColor.clear,colors[0]).map { setImage($0,for: .normal)}
				Theme.svgToUiImage(iconName,size,UIColor.clear,colors[1]).map { setImage($0,for: .highlighted)}
			}
		}
		
		if (hasText) {
			alignTextBelow(titleSize:titleSize!)
		}
		
	}
	
	func prepareRoundRect(effectKey:String, tintColor:String, textKey:String) {
		let tintColor = Theme.getColor(tintColor)
		setTitleColor(tintColor, for: .normal)
		titleLabel?.prepare(styleKey: "round_rect_button")
		setTitle(Texts.get(textKey), for: .normal)
		layer.cornerRadius = CGFloat(Customisation.it.themeConfig.getFloat(section: "arbitrary-values", key: "round_rect_button_corner_radius", defaultValue: 0.0))
		clipsToBounds = true
		Theme.selectionEffectColors(effectKey: effectKey).map { colors in
			setBackgroundColor(color: colors[0],forState: .normal)
			setBackgroundColor(color: colors[1],forState: .highlighted)
		}
		titleLabel?.snp.makeConstraints({ (make) in
			make.width.equalToSuperview()
		})
	}
	
	func prepareRoundRectWihIcon(effectKey:String, tintColor:String, textKey:String, iconName:String) {
		let tintColor = Theme.getColor(tintColor)
		self.tintColor = tintColor
		setTitleColor(tintColor, for: .normal)
		titleLabel?.prepare(styleKey: "round_rect_button")
		setTitle(Texts.get(textKey), for: .normal)
		layer.cornerRadius = CGFloat(Customisation.it.themeConfig.getFloat(section: "arbitrary-values", key: "round_rect_button_corner_radius", defaultValue: 0.0))
		clipsToBounds = true
		imageView!.contentMode = .scaleAspectFit
		Theme.svgToUiImage(iconName,CGSize(width: 20,height: 20),UIColor.clear,tintColor).map { setImage($0,for: .normal)}
		Theme.selectionEffectColors(effectKey: effectKey).map { colors in
			setBackgroundColor(color: colors[0],forState: .normal)
			setBackgroundColor(color: colors[1],forState: .highlighted)
		}
		imageEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 15)
		
	}
	
	func prepareRoundIcon(effectKey:String, tintColor:String, iconName:String, padding:CGFloat = 3.0, outLine:Bool = false, outLineColorKey:String? = nil) {
		let tintColor = Theme.getColor(tintColor)
		setTitle(nil, for: .normal)
		layer.cornerRadius = frame.size.width/2
		clipsToBounds = true
		Theme.selectionEffectColors(effectKey: effectKey).map { colors in
			setBackgroundColor(color: colors[0],forState: .normal)
			setBackgroundColor(color: colors[1],forState: .highlighted)
		}
		imageView!.contentMode = .scaleAspectFit
		Theme.svgToUiImage(iconName,frame.size,UIColor.clear,tintColor).map { setImage($0.withRenderingMode(.alwaysTemplate),for: .normal)}
		imageEdgeInsets = UIEdgeInsets(top: padding, left: padding, bottom: padding, right: padding)
		self.tintColor = tintColor
		
		if (outLine) {
			layer.borderWidth = 1
			layer.borderColor = (Theme.getColor(outLineColorKey!)).cgColor
		}
		
	}
		
	
	func alignTextBelow(spacing: CGFloat = 5.0, titleSize:CGSize) {
		guard let image = self.imageView?.image else {
			return
		}
		titleEdgeInsets = UIEdgeInsets(top: spacing, left: -image.size.width, bottom: -image.size.height, right: 0)
		imageEdgeInsets = UIEdgeInsets(top: -(titleSize.height + spacing), left: 0, bottom: 0, right: -titleSize.width)
	}
	
	
	func setBackgroundColor(color: UIColor, forState: UIControl.State) {
		UIGraphicsBeginImageContext(CGSize(width: 1, height: 1))
		UIGraphicsGetCurrentContext()!.setFillColor(color.cgColor)
		UIGraphicsGetCurrentContext()!.fill(CGRect(x: 0, y: 0, width: 1, height: 1))
		let colorImage = UIGraphicsGetImageFromCurrentImageContext()
		UIGraphicsEndImageContext()
		self.setBackgroundImage(colorImage, for: forState)
	}
	
	func makeCheckBox() {
		setImageForState(image: "checkbox_unticked",state: .normal)
		setImageForState(image: "checkbox_ticked",state: .selected)
	}
	
	func setImageForState(image:String, state:UIControl.State) {
		var url = FileUtil.sharedContainerUrl()
		url.appendPathComponent("images/icons/\(image).png")
		if (FileManager().fileExists(atPath: url.path)) {
			let image =  UIImage(contentsOfFile: url.path)
			setBackgroundImage(image,for: state)
		}
	}
	
}
