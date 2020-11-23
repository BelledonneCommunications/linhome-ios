//
//  LtextInput.swift
//  Linhome
//
//  Created by Christophe Deschamps on 23/06/2020.
//  Copyright © 2020 Belledonne communications. All rights reserved.
//

import UIKit


class SettingSwitch: UIViewController {
	
	
	@IBOutlet weak var settingTitle: UILabel!
	@IBOutlet weak var settingSubtitle: UILabel?
	@IBOutlet weak var settingSwitch: UISwitch!
	var liveValue:MutableLiveData<Bool>?
	@IBOutlet weak var separator: UIView!
	
	
	override func viewDidLoad() {
		super.viewDidLoad()
		settingTitle.prepare(styleKey: "settings_title")
		settingSubtitle?.prepare(styleKey: "settings_subtitle")
		settingSwitch.tintColor = Theme.getColor("color_a")
		settingSwitch.onTintColor = Theme.getColor("color_a")
		separator.backgroundColor = Theme.getColor("color_h")
		
	}
	
	class func addOne(titleText:String, subtitleText:String?,  targetVC:UIViewController, liveValue:MutableLiveData<Bool>, form:UIStackView, liveCollapsed: MutableLiveData<Bool>? = nil, pad:Bool = false) -> SettingSwitch {
		let previousSibbling = form.arrangedSubviews.last
		let child = SettingSwitch(nibName: "SettingSwitch"+(subtitleText != nil ? "WithSubtitles" : ""), bundle: nil)
		targetVC.addChild(child)
		form.addArrangedSubview(child.view)
		child.didMove(toParent: targetVC)
		child.settingTitle.setText(text:titleText)
		subtitleText.map{child.settingSubtitle?.setText(text: $0)}
		child.settingSwitch.isOn = liveValue.value!
		child.settingSwitch.addTarget(child, action: #selector(switchChanged), for: UIControl.Event.valueChanged)
		child.liveValue = liveValue
		
		
		// Layout constraints
		
		if (pad) {
			child.view.snp.makeConstraints { (make) -> Void in
				make.leading.equalTo(40)
			}
		}
		
		previousSibbling.map{ previous in
			child.view.snp.makeConstraints { (make) -> Void in
				make.top.equalTo(previous.snp.bottom)
			}
		}
		
		if (liveCollapsed != nil) {
			child.view.snp.makeConstraints { (make) -> Void in
				make.height.equalTo(liveCollapsed!.value! ? 0 : 60)
			}
			child.view.isHidden = liveCollapsed!.value!
			liveCollapsed?.observe(onChange: { (collapsed) in
				child.view.isHidden = liveCollapsed!.value!
				child.view.snp.updateConstraints {(make) -> Void in
					make.height.equalTo(liveCollapsed!.value! ? 0 : 60)
				}
			})
		}
		
		return child
	}
	
	
	@objc func switchChanged(mySwitch: UISwitch) {
		liveValue!.value = mySwitch.isOn
	}
	
	
}

