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
import PocketSVG
import SwiftSVG

extension UIImageView {
	
	private func snapshotImage(for layer: CALayer) -> UIImage? {
		UIGraphicsBeginImageContextWithOptions(layer.bounds.size, false, UIScreen.main.scale)
		guard let context = UIGraphicsGetCurrentContext() else { return nil }
		layer.render(in: context)
		let image = UIGraphicsGetImageFromCurrentImageContext()
		UIGraphicsEndImageContext()
		return image
	}
	
	
	func prepareSwiftSVG(iconName:String, fillColor:String? = "color_c", bgColor:String? = nil) {
		var svg = FileUtil.sharedContainerUrl()
		svg.appendPathComponent("images/\(iconName).svg")
		if (FileManager().fileExists(atPath: svg.path)) {
			let svgView = UIView(SVGURL: svg) { (svgLayer) in
				if (fillColor != nil) {
					svgLayer.fillColor = Theme.getColor(fillColor!).cgColor
				}
				if (bgColor != nil) {
					svgLayer.backgroundColor = Theme.getColor(bgColor!).cgColor
				}
				svgLayer.resizeToFit(self.bounds.insetBy(dx: 2,dy: 2))
			}
			for subview in subviews {
				subview.removeFromSuperview()
			}
			addSubview(svgView)
		}
		
		
	}
	
	func prepare(iconName:String, fillColor:String?, bgColor:String?) {
		var svg = FileUtil.sharedContainerUrl()
		svg.appendPathComponent("images/\(iconName).svg")
		if (FileManager().fileExists(atPath: svg.path)) {
			let svgImageView = SVGImageView.init(contentsOf: svg)
			svgImageView.frame = bounds
			svgImageView.contentMode = .scaleAspectFit
			if (fillColor != nil) {
				svgImageView.fillColor = Theme.getColor(fillColor!)
			}
			if (bgColor != nil) {
				svgImageView.backgroundColor = Theme.getColor(bgColor!)
			}
			for subview in subviews {
				subview.removeFromSuperview()
			}
			addSubview(svgImageView)
			return
		}
		
		var png = FileUtil.sharedContainerUrl()
		png.appendPathComponent("images/\(iconName).png")
		if (FileManager().fileExists(atPath: png.path)) {
			image =  UIImage(contentsOfFile: png.path)
			image = image?.withRenderingMode(.alwaysTemplate)
			if (fillColor != nil) {
				self.tintColor = Theme.getColor(fillColor!)
			}
			if (bgColor != nil) {
				self.backgroundColor = Theme.getColor(bgColor!)
			}
			return
		}
		
		var full = FileUtil.sharedContainerUrl()
		full.appendPathComponent("images/\(iconName)")
		if (FileManager().fileExists(atPath: full.path)) {
			image =  UIImage(contentsOfFile: full.path)
			if (fillColor != nil) {
				image = image?.withRenderingMode(.alwaysTemplate)
				self.tintColor = Theme.getColor(fillColor!)
			}
			if (bgColor != nil) {
				self.backgroundColor = Theme.getColor(bgColor!)
			}
			return
		}
	}
}


