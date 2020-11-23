//
//  LtextInput.swift
//  Linhome
//
//  Created by Christophe Deschamps on 23/06/2020.
//  Copyright © 2020 Belledonne communications. All rights reserved.
//

import UIKit
import DropDown


class SettingSpinner: UIViewController {

	
	@IBOutlet weak var settingTitle: UILabel!
	@IBOutlet weak var settingSubtitle: UILabel!
	@IBOutlet weak var chevron: UIImageView!
	@IBOutlet weak var separator: UIView!
	
	var liveIndex:MutableLiveData<Int>?
	
	
	override func viewDidLoad() {
		super.viewDidLoad()
		settingTitle.prepare(styleKey: "settings_title")
		settingSubtitle.prepare(styleKey: "settings_subtitle")
		chevron.prepare(iconName: "icons/chevron_down", fillColor: nil, bgColor: nil)
		separator.backgroundColor = Theme.getColor("color_h")

	}
	
	class func addOne(titleKey:String,  targetVC:UIViewController, liveIndex:MutableLiveData<Int>, options:[String], form:UIStackView) -> SettingSpinner {
		let previousSibbling = form.arrangedSubviews.last

		let child = SettingSpinner()
		targetVC.addChild(child)
		form.addArrangedSubview(child.view)
		child.didMove(toParent: targetVC)
		
		child.settingTitle.setText(text:Texts.get(titleKey))
		child.settingSubtitle.setText(text: options[liveIndex.value!])
		child.liveIndex = liveIndex
		
		let dropDown = DropDown()
		dropDown.anchorView = child.view
		dropDown.bottomOffset = CGPoint(x: 0, y:(dropDown.anchorView?.plainView.bounds.height)!)
		dropDown.dataSource = options
		dropDown.selectRow(liveIndex.value!)
		dropDown.backgroundColor = Theme.getColor("color_d")
		
		dropDown.selectionAction = { [unowned child] (index: Int, item: String) in
			child.liveIndex!.value = index
			dropDown.selectRow(at: index)
			child.settingSubtitle.setText(text: options[liveIndex.value!])
			dropDown.hide()
		}
	
		child.view.onClick {
			dropDown.show()
		}
		
		
		// Layout
		previousSibbling.map{ previous in
			child.view.snp.makeConstraints { (make) -> Void in
				make.top.equalTo(previous.snp.bottom)
			}
		}
	
		
		return child
	}
	

	
}

