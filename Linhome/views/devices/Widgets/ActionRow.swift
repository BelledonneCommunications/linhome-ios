//
//  LtextInput.swift
//  Linhome
//
//  Created by Christophe Deschamps on 23/06/2020.
//  Copyright © 2020 Belledonne communications. All rights reserved.
//

import UIKit
import DropDown


class ActionRow: UIViewController {
	
	
	@IBOutlet weak var actionForm: UIStackView!

	var actionViewModel:DeviceEditorActionViewModel?
	var code: LTextInput?
	
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
	}
	
	class func addOne(targetVC:UIViewController, actionViewModel:DeviceEditorActionViewModel, form:UIStackView) -> ActionRow {
		let previousSibbling = form.arrangedSubviews.last
		let child = ActionRow()
		targetVC.addChild(child)
		form.addArrangedSubview(child.view)
		child.didMove(toParent: targetVC)
		
		child.actionViewModel = actionViewModel

		let spinner = LSpinner.addOne(titleText: "\(Texts.get("action")) \(actionViewModel.displayIndex)", targetVC: child, options: actionViewModel.owningViewModel.availableActionTypes, liveIndex: actionViewModel.type, form: child.actionForm)
		child.code = LTextInput.addOne(titleKey: "action_code", targetVC: child, keyboardType: UIKeyboardType.numberPad, validator: ValidatorFactory.actionCode, liveInfo: actionViewModel.code, inForm: child.actionForm)
		let delete = UIButton()
		delete.frame = CGRect(x: 0,y: 0,width: 20,height: 20)
		delete.prepare(iconName:"icons/delete",effectKey:"primary_color", effectIsFg: true, tintColor:"color_c", padding: 0)
		child.actionForm.addArrangedSubview(delete)
		
		delete.onClick {
			actionViewModel.owningViewModel.removeActionViewModel(viewModel: actionViewModel)
			form.removeArrangedSubview(child.view)
			child.view.removeFromSuperview()
		}
	
		// Layout constraints
		
		previousSibbling.map{ previous in
			child.view.snp.makeConstraints { (make) -> Void in
				make.top.equalTo(previous.snp.bottom)
			}
		}
		
		spinner.view.snp.makeConstraints { (make) -> Void in
			make.leading.equalTo(0)
			make.rightMargin.equalTo(10)
		}
		
		child.code?.view.snp.makeConstraints { (make) -> Void in
			make.left.equalTo(spinner.view.snp.right).offset(10)
			make.width.equalTo(54)
		}
		
		delete.snp.makeConstraints { (make) -> Void in
			make.left.equalTo(child.code!.view.snp.right).offset(10)
			make.width.height.equalTo(20)
			make.right.equalTo(child.actionForm.snp.right)
		}
		
		
		
		child.code?.liveString?.observe(onChange: { (string) in
			if (actionViewModel.type.value! == 0 && !child.code!.inputText!.isEmptyOrNull()) {
				spinner.setError(Texts.get("action_type_missing"))
			} else {
				spinner.clearError()
			}
		})
		
		return child
	}
	

		
	
}

