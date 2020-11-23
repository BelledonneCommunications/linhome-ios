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

