//
//  ChunkCallTop.swift
//  Linhome
//
//  Created by Christophe Deschamps on 10/07/2020.
//  Copyright © 2020 Belledonne communications. All rights reserved.
//

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

}
