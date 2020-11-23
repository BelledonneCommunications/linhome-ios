//
//  SplashScreen.swift
//  Linhome
//
//  Created by Christophe Deschamps on 18/06/2020.
//  Copyright © 2020 Belledonne communications. All rights reserved.
//

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
