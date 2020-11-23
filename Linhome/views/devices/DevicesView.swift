//
//  SideMenuViewViewController.swift
//  Linhome
//
//  Created by Christophe Deschamps on 22/06/2020.
//  Copyright © 2020 Belledonne communications. All rights reserved.
//

import UIKit
import Firebase

class DevicesView: MainViewContent, UITableViewDataSource, UITableViewDelegate  {
	
	@IBOutlet weak var noDevices: UILabel!
	@IBOutlet weak var newDevice: UIButton!
	@IBOutlet weak var devices: UITableView!
	@IBOutlet weak var ipadSelectedItemView: UIView!
	@IBOutlet var ipadEditDevice: UIButton!
	@IBOutlet weak var ipadLeftColumn: UIView!
	var deviceInfoViewIpad:DeviceInfoViewIpad? = nil
	
	var model = DevicesViewModel()
	
	override func viewDidLoad() {
		super.viewDidLoad()
		noDevices.prepare(styleKey: "view_sub_title",textKey: "devices_empty_list_title")
		isRoot = true
		onTopOfBottomBar = false
		titleTextKey = "devices"
		
		manageModel(model)
		
		newDevice.prepareRoundIcon(effectKey: "primary_color", tintColor: "color_c", iconName: "icons/more", padding: 16)
		newDevice.onClick {
			NavigationManager.it.navigateTo(childClass: DeviceEditorView.self)
		}
		
		if (UIDevice.ipad()) {
		
		}
		
		devices.register(UINib(nibName: "DeviceCell", bundle: nil), forCellReuseIdentifier: "DeviceCell")
		
		if (UIDevice.ipad()) {
			placeNewDeviceButtonOnIpad()
			ipadEditDevice.prepareRoundIcon(effectKey: "primary_color", tintColor: "color_c", iconName: "icons/edit", padding: 16)
			ipadEditDevice.snp.makeConstraints { (make) in
				make.right.equalTo(self.view.snp.right).offset(-40)
				make.bottom.equalTo(self.view.snp.bottom).offset(-30)
			}
			ipadEditDevice.onClick {
				guard let device = self.model.selectedDevice.value else {
					return
				}
				NavigationManager.it.navigateTo(childClass: DeviceEditorView.self, asRoot: false, argument: device)
			}
			
			devices.backgroundColor = Theme.getColor("color_d")
			model.selectedDevice.readCurrentAndObserve { (device) in
				self.ipadSelectedItemView.isHidden = device == nil
				self.ipadEditDevice.isHidden = device == nil
				if (device != nil) {
					NavigationManager.it.nextViewArgument = device
					let child = DeviceInfoViewIpad.init()
					child.view.frame = self.ipadSelectedItemView.frame
					self.addChild(child)
					self.ipadSelectedItemView.addSubview(child.view)
					child.didMove(toParent: self)
					child.view.snp.makeConstraints { (make) in
						make.edges.equalToSuperview()
					}
					self.deviceInfoViewIpad = child
				}
			}
		} else {
			model.selectedDevice.observe { (device) in
				NavigationManager.it.navigateTo(childClass: DeviceInfoView.self, asRoot: false, argument: device)
			}
		}
		
	}
	
	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		noDevices.isHidden = DeviceStore.it.devices.count > 0
		devices.reloadData()
		
		DeviceStore.it.updatedSnapshotDeviceId.observe { (deviceId) in
			DeviceStore.it.devices.forEach {
				var i = 0
				if (deviceId == $0.id) {
					self.devices.reloadData()
					self.devices.beginUpdates()
					self.devices.reloadRows(at: [IndexPath(item: i, section: 0)], with: .fade)
					self.devices.endUpdates()
				}
				i += 1
			}			
		}
		if (UIDevice.ipad()) {
			ipadLeftColumn.isHidden = DeviceStore.it.devices.count ==  0
			self.model.selectedDevice.notifyValue()
			ipadLeftColumn.snp.makeConstraints { (make) in
				make.width.equalToSuperview().multipliedBy(0.4)
				make.top.bottom.equalToSuperview()
			}
			ipadSelectedItemView.snp.makeConstraints { (make) in
				make.width.equalToSuperview().multipliedBy(0.6)
				make.top.bottom.equalToSuperview()
				make.right.equalToSuperview()
			}
			placeNewDeviceButtonOnIpad(remake: true)
		}
	}
	
	
	
	// UITableView delegates
	
	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return DeviceStore.it.devices.count
	}
	
	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cell:DeviceCell = tableView.dequeueReusableCell(withIdentifier: "DeviceCell") as! DeviceCell
		cell.setDevice(device: DeviceStore.it.devices[indexPath.row])
		if (UIDevice.ipad()) {
			let customColorView = UIView()
			customColorView.backgroundColor = Theme.getColor("color_i")
			cell.selectedBackgroundView = customColorView
		}
		
		if (UIDevice.ipad() && indexPath.row == 0 && model.selectedDevice.value == nil) {
			model.selectedDevice.value = DeviceStore.it.devices[indexPath.row]
			tableView.selectRow(at: indexPath, animated: false, scrollPosition: .none)
		} else if (UIDevice.ipad() && model.selectedDevice.value != nil && DeviceStore.it.devices[indexPath.row].id == model.selectedDevice.value?.id) {
			tableView.selectRow(at: indexPath, animated: false, scrollPosition: .none)
		}
		
		
		return cell
	}
	
	func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		self.model.selectedDevice.value = DeviceStore.it.devices[indexPath.row]
	}
	
	func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
		return true
	}
	
	func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
		let deleteAction = UIContextualAction(style: .normal, title: nil) { (action, view, completion) in
			DialogUtil.confirm(messageTextKey: "delete_device_confirm_message",oneArg: DeviceStore.it.devices[indexPath.row].name, confirmAction: {
				tableView.beginUpdates()
				DeviceStore.it.removeDevice(device: DeviceStore.it.devices[indexPath.row])
				tableView.deleteRows(at: [indexPath], with: .middle)
				tableView.endUpdates()
				if (UIDevice.ipad()) {
					self.ipadLeftColumn.isHidden = DeviceStore.it.devices.count ==  0
					self.noDevices.isHidden = DeviceStore.it.devices.count > 0
					self.model.selectedDevice.value = DeviceStore.it.devices.count > 0 ? DeviceStore.it.devices[0] : nil
					self.placeNewDeviceButtonOnIpad(remake: true)
				}
			})
			completion(true)
		}
		
		deleteAction.image = Theme.svgToUiImage("icons/delete", CGSize(width: 20,height: 20),UIColor.clear,  Theme.getColor("color_c"))
		deleteAction.backgroundColor = Theme.getColor("color_e")
		return UISwipeActionsConfiguration(actions: [deleteAction])
	}
	
	override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
		super.viewWillTransition(to: size, with: coordinator)
		if (UIDevice.ipad()) {
			self.model.selectedDevice.notifyValue()
		}
	}
	
	func placeNewDeviceButtonOnIpad(remake:Bool = false) {
		if (remake) {
			newDevice.snp.removeConstraints()
		}
		newDevice.snp.makeConstraints { (make) in
			if (DeviceStore.it.devices.count == 0) {
				make.centerX.equalToSuperview()
			} else {
				make.left.equalTo(self.view.snp.left).offset(40)
			}
			make.bottom.equalTo(self.view.snp.bottom).offset(-30)
		}
	}
	
}
