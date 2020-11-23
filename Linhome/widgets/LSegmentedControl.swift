//
//  LtextInput.swift
//  Linhome
//
//  Created by Christophe Deschamps on 23/06/2020.
//  Copyright © 2020 Belledonne communications. All rights reserved.
//

import UIKit
import SnapKit


class LSegmentedControl: UIViewController {
	@IBOutlet weak var inputTitle: UILabel!
	@IBOutlet weak var inputSegment: UISegmentedControl!
	@IBOutlet weak var inputError: UILabel!
	
	var liveValue:MutableLiveData<Int>?

	
	override func viewDidLoad() {
		super.viewDidLoad()
		inputTitle.prepare(styleKey: "form_input_title")
		inputError.prepare(styleKey: "text_input_error")
		inputSegment.prepare(textColorEffectKey: "segmented_control_text",backgroundColorEffectKey: "segmented_control_background")
		inputSegment.layer.cornerRadius = 10.0
		inputSegment.layer.masksToBounds = true
	}
	
	class func addOne(titleKey:String, targetVC:UIViewController, liveValue:MutableLiveData<Int>, inForm form:UIStackView, itemKeys:[String]) -> LSegmentedControl {
		let child = LSegmentedControl()
		targetVC.addChild(child)
		form.addArrangedSubview(child.view)
		child.inputTitle.setText(text:Texts.get(titleKey))
		child.liveValue = liveValue
		child.inputSegment.addTarget(child, action: #selector(LSegmentedControl.selectOne(_:)), for: .valueChanged)
		child.inputSegment.selectedSegmentIndex = liveValue.value!
		child.inputSegment.setSegments(segments: itemKeys)
		child.inputSegment.selectedSegmentIndex = liveValue.value!
		if (UIDevice.ipad()) {
			child.view.snp.makeConstraints { (make) in
				make.width.equalTo(320)
			}
		}
		return child
	}
	
	@objc func selectOne(_ segmentControl: UISegmentedControl) {
		liveValue?.value = segmentControl.selectedSegmentIndex
	}

	func setError(_ message: String) {
		inputError.text = message
	}
	
	func clearError() {
		inputError.text = nil
	}
	
}

