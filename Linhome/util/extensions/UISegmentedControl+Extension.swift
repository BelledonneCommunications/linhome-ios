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
