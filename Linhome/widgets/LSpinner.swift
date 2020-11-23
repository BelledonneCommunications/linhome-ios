//
//  LtextInput.swift
//  Linhome
//
//  Created by Christophe Deschamps on 23/06/2020.
//  Copyright © 2020 Belledonne communications. All rights reserved.
//

import Foundation
import UIKit
import DropDown


class LSpinner : UIViewController, UITableViewDataSource, UITableViewDelegate {
	
	@IBOutlet weak var inputTitle: UILabel!
	@IBOutlet weak var inputError: UILabel!
	@IBOutlet weak var chevron: UIImageView!
	@IBOutlet weak var selectedValue: UITableView!
	
	var liveIndex:MutableLiveData<Int>?
	var options = [SpinnerItem]()
	var optionsWithoutHint = [SpinnerItem]()

	var dropDown :  DropDown?
	
	
	override func viewDidLoad() {
		super.viewDidLoad()
		inputTitle.prepare(styleKey: "form_input_title")
		inputError.prepare(styleKey: "text_input_error")

		chevron.prepare(iconName: "icons/chevron_down", fillColor: nil, bgColor: nil)
		selectedValue.delegate = self
		selectedValue.dataSource = self
		selectedValue.register(UINib(nibName: "LSpinnerCell", bundle: nil), forCellReuseIdentifier: "LSpinnerCell")
		selectedValue.backgroundColor = Theme.getColor("color_i")
		selectedValue.layer.cornerRadius = CGFloat(Customisation.it.themeConfig.getFloat(section: "arbitrary-values", key: "user_input_corner_radius", defaultValue: 0.0))

	}
	
	class func addOne(titleKey:String?, targetVC:UIViewController, options:[SpinnerItem], liveIndex:MutableLiveData<Int>, form:UIStackView) -> LSpinner {
		addOne(titleText: titleKey != nil ? Texts.get(titleKey!) : nil, targetVC: targetVC, options: options, liveIndex: liveIndex, form: form)
	}
	
	class func addOne(titleText:String?, targetVC:UIViewController, options:[SpinnerItem], liveIndex:MutableLiveData<Int>, form:UIStackView) -> LSpinner {
		
		let previousSibbling = form.arrangedSubviews.last
		let child = LSpinner()
		targetVC.addChild(child)
		form.addArrangedSubview(child.view)
		child.didMove(toParent: targetVC)
		
		if (titleText != nil) {
			child.inputTitle.setText(text:titleText!)
		} else {
			child.inputTitle.isHidden = true
		}
		
		child.options = options
		child.optionsWithoutHint = options
		child.optionsWithoutHint.removeFirst()
		
		child.liveIndex = liveIndex
		
		child.dropDown = DropDown()
		child.dropDown?.cornerRadius = 7.0
		child.dropDown?.anchorView = child.selectedValue

		child.dropDown?.dataSource = child.optionsWithoutHint.map({ (item: SpinnerItem) -> String in ""})
		
		
		child.dropDown?.cellNib = UINib(nibName: "LSpinnerCell", bundle: nil)
		child.dropDown?.customCellConfiguration = { (index: Index, item: String, cell: DropDownCell) -> Void in
		   guard let cell = cell as? LSpinnerCell else { return }
			cell.setContent(item: child.optionsWithoutHint[index])
		}
		
		child.dropDown?.selectRow(liveIndex.value!)
		child.dropDown?.backgroundColor = Theme.getColor("color_d")
		child.dropDown?.selectionBackgroundColor = Theme.getColor("color_i")

		child.dropDown?.selectionAction = { [unowned child] (index: Int, item: String) in
			liveIndex.value = index+1
			child.dropDown?.selectRow(at: index)
			child.selectedValue.reloadData()
			child.dropDown?.hide()
		}
		
		previousSibbling.map{ previous in
			child.view.snp.makeConstraints { (make) -> Void in
				make.top.equalTo(previous.snp.bottom)
			}
		}
		
		
		child.selectedValue.reloadData()
		
		if (UIDevice.ipad()) {
			child.view.snp.makeConstraints { (make) in
				make.width.equalTo(320)
			}
		}
		
		return child
	}
	
	
	// Chosen elements
	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return liveIndex != nil ? 1 : 0
	}
	
	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cell:LSpinnerCell = tableView.dequeueReusableCell(withIdentifier: "LSpinnerCell") as! LSpinnerCell
		cell.setContent(item: options[liveIndex!.value!])
		cell.separator.isHidden = tableView == selectedValue
		return cell
	}
	
	func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		self.dropDown?.show()
	}
	
	func setError(_ message: String) {
		inputError.text = message
	}
	
	func clearError() {
		inputError.text = nil
	}
	
	
	
}

