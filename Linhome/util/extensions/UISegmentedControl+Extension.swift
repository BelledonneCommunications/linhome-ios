//
//  UISegmentedControl+Extension.swift
//  Linhome
//
//  Created by Christophe Deschamps on 26/06/2020.
//  Copyright © 2020 Belledonne communications. All rights reserved.
//

import Foundation
import UIKit

extension UISegmentedControl {
	func setSegments(segments: Array<String>) {
		self.removeAllSegments()
		for segment in segments {
			self.insertSegment(withTitle: Texts.get(segment).uppercased(), at: self.numberOfSegments, animated: false)
		}
	}

	func prepare(textColorEffectKey : String, backgroundColorEffectKey:String) {
		Theme.selectionEffectColors(effectKey: textColorEffectKey).map { colors in
			let dummyLabel = UILabel()
			dummyLabel.prepare(styleKey: "segmented_control")
			setTitleTextAttributes( [NSAttributedString.Key.font: dummyLabel.font!], for: .normal)
			setTitleTextAttributes( [NSAttributedString.Key.foregroundColor: colors[0]], for: .normal)
			setTitleTextAttributes( [NSAttributedString.Key.font: dummyLabel.font!], for: .selected)
			setTitleTextAttributes( [NSAttributedString.Key.foregroundColor: colors[1]], for: .selected)
		}
		Theme.selectionEffectColors(effectKey: backgroundColorEffectKey).map { colors in
			setBackgroundImage(imageWithColor(color: colors[0]), for: .normal, barMetrics: .default)
			setBackgroundImage(imageWithColor(color: colors[1]), for: .selected, barMetrics: .default)
			setDividerImage(imageWithColor(color: UIColor.clear), forLeftSegmentState: .normal, rightSegmentState: .normal, barMetrics: .default)
		}
		
		
	   }

	   private func imageWithColor(color: UIColor) -> UIImage {
		   let rect = CGRect(x: 0.0, y: 0.0, width:  1.0, height: 1.0)
		   UIGraphicsBeginImageContext(rect.size)
		   let context = UIGraphicsGetCurrentContext()
		   context!.setFillColor(color.cgColor);
		   context!.fill(rect);
		   let image = UIGraphicsGetImageFromCurrentImageContext();
		   UIGraphicsEndImageContext();
		   return image!
	   }
	

}
