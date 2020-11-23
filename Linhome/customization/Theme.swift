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
import linphonesw
import PocketSVG

class Theme {
	
	static var themeHasError = false
	
	class func getColor(_ key: String) -> UIColor {
		if (key == "transparent") {
			return UIColor.clear
		}
		if let colorhex = Customisation.it.themeConfig.getString(section: "colors", key: key) {
			return UIColor(hexString: colorhex)
		}
		return UIColor.red
	}
	
	
	class  func getFont(_ name:String, _ size:Float) -> UIFont? {
		
		if let existingFont = UIFont.init(name: name, size: CGFloat(size)) {
			return existingFont
		}
		
		var fontUrl = FileUtil.sharedContainerUrl()
		fontUrl.appendPathComponent("fonts/\(name).ttf")
		guard let fontDataProvider = CGDataProvider(url: fontUrl as CFURL) else {
			themeError("Could not create font data provider for \(fontUrl).")
			return nil
		}
		
		guard let font = CGFont(fontDataProvider) else {
			themeError("Failed creating CGFont \(fontUrl).")
			return nil
			
		}
		
		var error: Unmanaged<CFError>?
		guard CTFontManagerRegisterGraphicsFont(font, &error) else {
			let message = error.debugDescription
			error?.release()
			themeError(message)
			return nil
		}
		return UIFont.init(name: name, size: CGFloat(size))
	}
	
	
	class func themeError(_ message:String = "[Theme] there is an error in the theme. Check the stack trace below") {
		themeHasError = true
		Log.error(message)
		Thread.callStackSymbols.forEach{print($0)}
	}
	
	
	class func selectionEffectColors(effectKey:String) -> [UIColor]? {
		if let idle = Customisation.it.themeConfig.getString(section: "selection-effect.\(effectKey)", key: "default"),
			let selected = Customisation.it.themeConfig.getString(section: "selection-effect.\(effectKey)", key: "selected") {
			return [getColor(idle),getColor(selected)]
		} else {
			return nil
		}
	}
	
	
	class func svgToUiImage(_ svgMane: String, _ size:CGSize , _ backgroundColor:UIColor, _ tintColor:UIColor) -> UIImage? {
		var svg = FileUtil.sharedContainerUrl()
		svg.appendPathComponent("images/\(svgMane).svg")
		if (!FileManager().fileExists(atPath: svg.path)) {
			return UIImage(contentsOfFile: svg.path)
		}
		let svgImageView = SVGImageView.init(contentsOf: svg)
		svgImageView.frame =  CGRect(x: 0, y: 0, width: size.width, height: size.height)
		svgImageView.contentMode = .scaleAspectFit
		
		svgImageView.backgroundColor = backgroundColor
		svgImageView.fillColor = tintColor
	
		UIGraphicsBeginImageContextWithOptions(size, false, UIScreen.main.scale)
		guard let context = UIGraphicsGetCurrentContext() else { return nil }
		svgImageView.layer.render(in: context)
		let image = UIGraphicsGetImageFromCurrentImageContext()
		UIGraphicsEndImageContext()
		return image
		
	}
	
	class func svgToUiImage(_ svgMane: String, _ size:CGSize) -> UIImage? {
		var svg = FileUtil.sharedContainerUrl()
		svg.appendPathComponent("images/\(svgMane).svg")
		if (!FileManager().fileExists(atPath: svg.path)) {
			return UIImage(contentsOfFile: svg.path)
		}
		let svgImageView = SVGImageView.init(contentsOf: svg)
		svgImageView.frame =  CGRect(x: 0, y: 0, width: size.width, height: size.height)
		svgImageView.contentMode = .scaleAspectFit
		
		UIGraphicsBeginImageContextWithOptions(size, false, UIScreen.main.scale)
		guard let context = UIGraphicsGetCurrentContext() else { return nil }
		svgImageView.layer.render(in: context)
		let image = UIGraphicsGetImageFromCurrentImageContext()
		UIGraphicsEndImageContext()
		return image
		
	}

	
	
}
