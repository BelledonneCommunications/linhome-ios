//
//  LtextInput.swift
//  Linhome
//
//  Created by Christophe Deschamps on 23/06/2020.
//  Copyright © 2020 Belledonne communications. All rights reserved.
//

import UIKit


class SettingExpandable: UIViewController {

	
	@IBOutlet weak var settingTitle: UILabel!
	@IBOutlet weak var settingSubtitle: UILabel?
	@IBOutlet weak var chevron: UIImageView!
	@IBOutlet weak var separator: UIView!
	
	var collapsed = MutableLiveData(true)
	
	override func viewDidLoad() {
		super.viewDidLoad()
		settingTitle.prepare(styleKey: "settings_title")
		settingSubtitle?.prepare(styleKey: "settings_subtitle")
		chevron.prepare(iconName: "icons/chevron_down", fillColor: nil, bgColor: nil)
		separator.backgroundColor = Theme.getColor("color_h")
	}
	
	class func addOne(titleKey:String, subtitleKey:String?,  targetVC:UIViewController, form:UIStackView) -> SettingExpandable {
		let child = SettingExpandable(nibName: "SettingExpandable"+(subtitleKey != nil ? "WithSubtitles" : ""), bundle: nil)
		targetVC.addChild(child)
		form.addArrangedSubview(child.view)
		child.didMove(toParent: targetVC)
		
		child.settingTitle.setText(text:Texts.get(titleKey))
		subtitleKey.map{child.settingSubtitle?.setText(text:Texts.get($0))}
		
		child.view.snp.makeConstraints { (make) -> Void in
			make.leading.equalTo(0)
		}

		child.view.onClick {
			child.collapsed.value = !child.collapsed.value!
			let radians: CGFloat = child.collapsed.value! ?  0 : 180  * (.pi / 180)
			child.chevron.transform = CGAffineTransform(rotationAngle: radians)
			child.separator.isHidden = !child.collapsed.value!
		}
		
		return child
	}
	
	
}

