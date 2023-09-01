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

class ChunkCallTop: UIViewController {
	
	@IBOutlet weak var topLettLine: UIView!
	@IBOutlet weak var topRightLine: UIView!
	@IBOutlet weak var linhomeLogo: UIImageView!
	@IBOutlet weak var linhomeText: UIImageView!
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		topLettLine.backgroundColor = Theme.getColor("color_c")
		topRightLine.backgroundColor = Theme.getColor("color_c")
		linhomeLogo.prepare(iconName: "others/linhome_icon", fillColor: "color_c", bgColor: nil)
		linhomeText.prepare(iconName: "others/linhome_text", fillColor: "color_c", bgColor: nil)

	}
	
	override func viewWillAppear(_ animated: Bool) {
		self.view.snp.makeConstraints { make in
			make.height.equalTo(self.view.frame.height)
		}
	}
}
