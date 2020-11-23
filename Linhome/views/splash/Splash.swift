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
