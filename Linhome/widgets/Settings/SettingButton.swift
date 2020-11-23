//
//  LtextInput.swift
//  Linhome
//
//  Created by Christophe Deschamps on 23/06/2020.
//  Copyright © 2020 Belledonne communications. All rights reserved.
//

import UIKit


class SettingButton: UIViewController {
	
	
	@IBOutlet weak var settingTitle: UILabel!
	@IBOutlet weak var separator: UIView!
	
	
	override func viewDidLoad() {
		super.viewDidLoad()
		settingTitle.prepare(styleKey: "settings_title")
		separator.backgroundColor = Theme.getColor("color_h")
	}
	
	class func addOne(titleText:String, targetVC:UIViewController, form:UIStackView, liveCollapsed: MutableLiveData<Bool>? = nil, pad:Bool = false, onClick : @escaping ()->Void ) -> SettingButton {
		let previousSibbling = form.arrangedSubviews.last
		let child = SettingButton()
		targetVC.addChild(child)
		form.addArrangedSubview(child.view)
		child.didMove(toParent: targetVC)
		child.settingTitle.setText(text:titleText)
				
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
		
		child.view.onClick {
			child.view.clickEffect(effectKey: "settings_item")
			onClick()
		}
		
		return child
	}
	
	
	
}

