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
import Foundation

class About: MainViewContent {

	@IBOutlet weak var linhomeIcon: UIImageView!
	@IBOutlet weak var linhomeText: UIImageView!
	@IBOutlet weak var linhomeTitle: UILabel!
	@IBOutlet weak var appVersion: UILabel!
	@IBOutlet weak var coreVersion: UILabel!
	@IBOutlet weak var linhomeOrg: UILabel!
	@IBOutlet weak var license: UILabel!
	@IBOutlet weak var copyRight: UILabel!
	
	
	override func viewDidLoad() {
        super.viewDidLoad()
		
		isRoot = false
		onTopOfBottomBar = true
		titleTextKey = "about"
		
		setGradientBg()

		
		linhomeIcon.prepare(iconName: "others/linhome_icon", fillColor: "color_c", bgColor: nil)
		linhomeText.prepare(iconName: "others/linhome_text", fillColor: "color_c", bgColor: nil)
		linhomeTitle.prepare(styleKey: "splash_title",textKey: "splash_title")
		
		appVersion.prepare(styleKey: "about_text",textKey:"app_version",arg1:"iOS", arg2:"\(GIT_VERSION) - \(Bundle.main.desc())")
		coreVersion.prepare(styleKey: "about_text",textKey:"sdk_version",arg1:Core.getVersion)

		linhomeOrg.prepare(styleKey: "about_link",textKey: "about_link")
		license.prepare(styleKey: "about_text",textKey: "license_text")
		copyRight.prepare(styleKey: "about_text",textKey: "copyright_text")
		
		linhomeOrg.onClick {
			self.linhomeOrg.text.map { urlString in
				if let url = URL(string: urlString.hasPrefix("http") ? urlString :  "https://\(urlString)") {
					UIApplication.shared.open(url)
				}
			}
		}
		
		license.onClick {
			if let url = URL(string:Texts.get("license_link")) {
				UIApplication.shared.open(url)
			}
		}
		
    }
	
	
}
