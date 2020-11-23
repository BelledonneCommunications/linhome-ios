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
import linphonesw
import DropDown

class DeviceInfoView: MainViewContent, UITableViewDataSource, UITableViewDelegate  {
	
	
	var device:Device?
	var name, address, typeName, actionsTitle : UILabel?
	var typeIcon:UIImageView?
	var actions:UITableView?
	
	override func viewDidLoad() {
		super.viewDidLoad()
		isRoot = false
		onTopOfBottomBar = true
		titleTextKey = "devices"
		
		
		let scrollView = UIScrollView()
		view.addSubview(scrollView)
		scrollView.snp.makeConstraints { make in
			make.edges.equalTo(view)
		}
		
		let contentView = UIView()
		scrollView.addSubview(contentView)
		contentView.snp.makeConstraints { make in
			make.top.equalTo(scrollView)
			make.bottom.equalTo(scrollView)
			make.left.right.equalTo(view)
		}		
		
		name = UILabel()
		contentView.addSubview(name!)
		name!.snp.makeConstraints { make in
			make.top.equalTo(contentView).offset(40)
			make.centerX.equalTo(view.snp.centerX)
		}
		
		address = UILabel()
		contentView.addSubview(address!)
		address!.snp.makeConstraints { make in
			make.top.equalTo(name!.snp.bottom).offset(5)
			make.centerX.equalTo(view.snp.centerX)
		}
		
		typeIcon = UIImageView()
		contentView.addSubview(typeIcon!)
		typeIcon!.snp.makeConstraints { make in
			make.top.equalTo(address!.snp.bottom).offset(32)
			make.centerX.equalTo(view.snp.centerX)
			make.width.height.equalTo(86)
		}
		
		typeName = UILabel()
		contentView.addSubview(typeName!)
		typeName!.snp.makeConstraints { make in
			make.top.equalTo(typeIcon!.snp.bottom).offset(32)
			make.centerX.equalTo(view.snp.centerX)
		}
				
		actionsTitle = UILabel()
		contentView.addSubview(actionsTitle!)
		actionsTitle!.snp.makeConstraints { make in
			make.top.equalTo(typeName!.snp.bottom).offset(55)
			make.centerX.equalTo(view.snp.centerX)
		}
				
		actions = UITableView()
		contentView.addSubview(actions!)
		actions!.register(UINib(nibName: "ActionInfoCell", bundle: nil), forCellReuseIdentifier: "ActionInfoCell")
		actions!.delegate = self
		actions!.dataSource = self
		actions?.rowHeight = 44
		actions?.insetsLayoutMarginsFromSafeArea = false
		actions?.insetsContentViewsToSafeArea = false
		actions?.separatorStyle = .none
		actions!.snp.makeConstraints { make in
			make.top.equalTo(actionsTitle!.snp.bottom).offset(14)
			make.centerX.equalTo(view.snp.centerX)
			make.height.equalTo(3*actions!.rowHeight)
			make.width.equalTo(contentView.snp.width)
		}
	
	}
	
	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		
		guard let device = NavigationManager.it.nextViewArgument as! Device? else {
			NavigationManager.it.navigateUp()
			return
		}
		
		self.device = device
		
		NavigationManager.it.mainView!.right.prepare(iconName: "icons/edit",effectKey: "primary_color",tintColor: "color_c", textStyleKey: "toolbar_action", text: Texts.get("edit"))
		NavigationManager.it.mainView?.toolbarViewModel.rightButtonVisible.value = true
		NavigationManager.it.mainView?.toolbarViewModel.leftButtonVisible.value = false
		

		name!.prepare(styleKey: "view_device_info_name",text: device.name)
		address!.prepare(styleKey: "view_device_info_address",text: device.address)
		device.type.map { type in
			DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(20)) {
				self.typeIcon!.prepare(iconName: DeviceTypes.it.iconNameForDeviceType(typeKey:type)!, fillColor: nil, bgColor: nil)
			}
			typeName!.prepare(styleKey: "view_device_info_type_name",text: device.typeName())
		}
		actionsTitle!.prepare(styleKey: "view_device_info_actions_title",text: device.actions != nil && device.actions!.count > 0 ? Texts.get("device_info_actions_title") : Texts.get("device_info_no_actions_title"))
		actions!.reloadData()
		
	}
	
	override func onToolbarRightButtonClicked() {
		NavigationManager.it.navigateTo(childClass: DeviceEditorView.self, asRoot: false, argument: device)
	}
		
		
	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return device?.actions?.count ?? 0
	}
	
	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let action = device!.actions![indexPath.row]
		let cell:ActionInfoCell = tableView.dequeueReusableCell(withIdentifier: "ActionInfoCell") as! ActionInfoCell
		cell.actionType.prepare(iconName: ActionTypes.it.iconNameForActionType(typeKey: action.type!), fillColor: nil, bgColor: nil)
		cell.actionName.text = action.typeName()
		cell.actionCode.text = action.code
		cell.topSep.isHidden = indexPath.row != 0
		cell.botSep.isHidden = false
		return cell
	}
	
	
}
