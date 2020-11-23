//
//  DeviceEditorView.swift
//  Linhome
//
//  Created by Christophe Deschamps on 22/06/2020.
//  Copyright © 2020 Belledonne communications. All rights reserved.
//

import UIKit
import linphonesw
import DropDown

class DeviceEditorView: MainViewContentWithScrollableForm {
	
	var nameInput : LTextInput?
	var addressInput : LTextInput?
	var model = DeviceEditorViewModel()

	
	override func viewDidLoad() {
		super.viewDidLoad()
		isRoot = false
		onTopOfBottomBar = true
		titleTextKey = "devices"
		hideSubtitle()

		
		manageModel(model)
		model.device = NavigationManager.it.nextViewArgument as! Device?
			
		nameInput = LTextInput.addOne(titleKey: "device_name", targetVC: self, keyboardType: UIKeyboardType.default, validator: ValidatorFactory.nonEmptyStringValidator, liveInfo: model.name, inForm: form)
		addressInput = LTextInput.addOne(titleKey: "device_address", targetVC: self, keyboardType: UIKeyboardType.default, validator: ValidatorFactory.sipUri, liveInfo: model.address, inForm: form, hintKey: "device_address_hint")
		
		// device type
		let deviceTypeTitle = UILabel()
		form.addArrangedSubview(deviceTypeTitle)
		deviceTypeTitle.snp.makeConstraints { (make) -> Void in
			make.top.equalTo(addressInput!.view.snp.bottom)
		}
		deviceTypeTitle.prepare(styleKey: "section_title",textKey:"device_type_select")
		let deviceSpinner = LSpinner.addOne(titleKey: nil, targetVC: self, options:model.availableDeviceTypes, liveIndex: model.deviceType, form:form)
		
		
		let landScapeIpad = UIDevice.ipad() && UIScreen.isLandscape
		
		if (landScapeIpad) {
			addSecondColumn()
			nameInput?.view.snp.makeConstraints({ (make) in
				make.top.equalToSuperview().offset(80)
			})
		}
		
		// Method type
		let actionsTitle = UILabel()
		(landScapeIpad ? formSecondColumn : form).addArrangedSubview(actionsTitle)
		actionsTitle.snp.makeConstraints { (make) -> Void in
			make.top.equalTo(landScapeIpad ? viewSubtitle.snp.bottom : deviceSpinner.view.snp.bottom)
			make.height.equalTo(landScapeIpad ? 80 : 30)
		}
		actionsTitle.prepare(styleKey: "section_title",textKey:"method_type_select")
		let _ = LSpinner.addOne(titleKey: "action_method", targetVC: self, options:model.availableMethodTypes, liveIndex: model.actionsMethod, form:landScapeIpad ? formSecondColumn : form)
		
		let newAction = UIRoundRectButtonWithIcon(container:contentView, placedBelow: landScapeIpad ? formSecondColumn : form, effectKey: "secondary_color", tintColor: "color_c", textKey: "device_action_add", topMargin: 27,  iconName: "icons/more")
		newAction.onClick {
			self.doAddAction(action: nil, model: self.model, form: landScapeIpad ? self.formSecondColumn : self.form)
		}
		
		if (landScapeIpad) {
			newAction.snp.makeConstraints { (make) in
				make.left.equalTo(self.formSecondColumn.snp.left)
			}
		}
		
		let delete = UIRoundRectButton(container:contentView, placedBelow:newAction, effectKey: "primary_color", tintColor: "color_c", textKey: "delete_device", topMargin: 40, isLastInContainer: true)
		delete.isHidden = model.device == nil
		
		if (landScapeIpad) {
			delete.snp.makeConstraints { (make) in
				make.top.greaterThanOrEqualTo(deviceSpinner.view.snp.bottom).offset(40)
			}
		}
		
		if (model.device != nil) {
			viewTitle.setText(text: model.device!.name)
			model.device!.actions?.forEach { it in
				self.doAddAction(action: it,model: model, form:landScapeIpad ? formSecondColumn : form)
			}
		} else {
			viewTitle.setText(textKey:"new_device")
			self.doAddAction(action: nil, model: model, form:landScapeIpad ? formSecondColumn : form)
		}
		
		delete.onClick {
			DialogUtil.confirm(messageTextKey: "delete_device_confirm_message",oneArg: self.model.device?.name, confirmAction: {
				DeviceStore.it.removeDevice(device:self.model.device!)
				NavigationManager.it.navigateTo(childClass: DevicesView.self,asRoot: true)
			})
		}
		
		newAction.isEnabled = self.model.actionsViewModels.count <= 2
		model.refreshActions.observe { (_) in
			newAction.isEnabled = self.model.actionsViewModels.count <= 2
		}
				
				
	}
	
	private func doAddAction(action: Action?, model: DeviceEditorViewModel, form:UIStackView) {
		let actionViewModel = DeviceEditorActionViewModel(owningViewModel: model, displayIndex: model.actionsViewModels.count + 1)
		if (action != nil) {
			actionViewModel.code.first.value = action!.code
			actionViewModel.type.value = model.availableActionTypes.firstIndex{$0.backingKey == action!.type}
		}
		model.actionsViewModels.append(actionViewModel)
		actionViewModel.actionRow = ActionRow.addOne(targetVC: self, actionViewModel:actionViewModel, form:form)
		model.refreshActions.value = true
		
		
	}
	
	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		
		NavigationManager.it.mainView!.right.prepare(iconName: "icons/save",effectKey: "primary_color",tintColor: "color_c", textStyleKey: "toolbar_action", text: Texts.get("save"))
		NavigationManager.it.mainView!.left.prepare(iconName: "icons/cancel",effectKey: "primary_color",tintColor: "color_c", textStyleKey: "toolbar_action", text: Texts.get("cancel"))
		
		NavigationManager.it.pauseNavigation()
		
		NavigationManager.it.mainView?.toolbarViewModel.rightButtonVisible.value = true
		NavigationManager.it.mainView?.toolbarViewModel.leftButtonVisible.value = true
	}
	
	override func onToolbarRightButtonClicked() {
		nameInput?.validate()
		addressInput?.validate()
		model.actionsViewModels.forEach { it in
			if (it.type.value != 0) {
				it.actionRow?.code?.validate()
			}
		}
		DeviceStore.it.findDeviceByAddress(address: model.address.first.value).map { it in
			if (model.device?.id != it.id) {
				addressInput?.setError(
					Texts.get(
						"device_address_already_exists",
						oneArg: "\(it.name)"
					)
				)
				return
			}
		}
		if (model.saveDevice()) {
			NavigationManager.it.nextViewArgument = model.device
			NavigationManager.it.navigateUp()
		}
	}
	
	override func onToolbarLeftButtonClicked() {
		NavigationManager.it.navigateUp()
	}
	
	
	
	
	override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
		super.viewWillTransition(to: size, with: coordinator)
		NavigationManager.it.mainView?.toolbarViewModel.rightButtonVisible.value = true
	}
}
