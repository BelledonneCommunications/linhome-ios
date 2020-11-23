//
//  SplashScreen.swift
//  Linhome
//
//  Created by Christophe Deschamps on 18/06/2020.
//  Copyright © 2020 Belledonne communications. All rights reserved.
//

import UIKit

class Splash: UIViewController {

	@IBOutlet weak var linhomeIcon: UIImageView!
	@IBOutlet weak var linhomeText: UIImageView!
	@IBOutlet weak var linhomeTitle: UILabel!
	@IBOutlet weak var background: UIView!
	
	override func viewDidLoad() {
        super.viewDidLoad()
		linhomeIcon.prepare(iconName: "others/linhome_icon", fillColor: "color_c", bgColor: nil)
		linhomeText.prepare(iconName: "others/linhome_text", fillColor: "color_c", bgColor: nil)
		linhomeTitle.prepare(styleKey: "splash_title",textKey: "splash_title")
		DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(Customisation.it.themeConfig.getInt(section: "arbitrary-values", key: "splash_display_duration_ms", defaultValue: 2000))) {
			let newViewController = MainView()
			newViewController.modalPresentationStyle = .fullScreen
			self.present(newViewController, animated: true, completion: nil)
		}
    }
	
	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		self.background.setGradientColor("dark_light_vertical_gradient")
	}
}
