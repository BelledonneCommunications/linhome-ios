//
//  UIImageView+Extension.swift
//  Linhome
//
//  Created by Christophe Deschamps on 18/06/2020.
//  Copyright © 2020 Belledonne communications. All rights reserved.
//

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


