//
//  SideMenuViewViewController.swift
//  Linhome
//
//  Created by Christophe Deschamps on 22/06/2020.
//  Copyright © 2020 Belledonne communications. All rights reserved.
//

import UIKit
import linphonesw

class HistoryView: MainViewContent, UITableViewDataSource, UITableViewDelegate {
	
	@IBOutlet weak var noHistory: UILabel!
	@IBOutlet weak var eventsTable: UITableView!
	
	var model = HistoryViewModel()
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		isRoot = true
		onTopOfBottomBar = false
		titleTextKey = "history"
		
		manageModel(model)
		
		noHistory.prepare(styleKey: "view_sub_title",textKey: "history_empty_list_title")
		noHistory.isHidden = model.history.value!.count != 0
		
		let selectAll = UIButton()
		selectAll.prepareRoundRect(effectKey : "secondary_color", tintColor: "color_c", textKey: "history_select_all")
		self.view.addSubview(selectAll)
		selectAll.snp.makeConstraints { (make) in
			make.bottom.equalToSuperview().offset(-20)
			make.centerX.equalToSuperview()
			make.height.equalTo(40)
			make.leftMargin.rightMargin.equalTo(20)
			make.width.lessThanOrEqualTo(320)
		}
		
		selectAll.onClick {
			self.model.toggleSelectAllForDeletion()
		}
		
		model.selectedForDeletion.observe { (items) in
			selectAll.setTitle(items!.count == self.model.history.value!.count ? Texts.get("history_deselect_all") : Texts.get("history_select_all"), for: .normal)
			if (self.model.editing.value! && items!.count == 0) {
				NavigationManager.it.mainView?.right.isEnabled = false
				NavigationManager.it.mainView?.right.alpha = 0.5
			} else {
				NavigationManager.it.mainView?.right.isEnabled = true
				NavigationManager.it.mainView?.right.alpha = 1.0
			}
		}
		
		model.history.observe { (list) in
			self.noHistory.isHidden = list!.count != 0
			NavigationManager.it.mainView?.toolbarViewModel.rightButtonVisible.value = list!.count != 0
			self.eventsTable.reloadData()
		}
		
		model.editing.readCurrentAndObserve { (editing) in
			selectAll.isHidden = !editing!
		}
		
		eventsTable.register(UINib(nibName: "HistoryCell", bundle: nil), forCellReuseIdentifier: "HistoryCell")
		eventsTable.register(UINib(nibName: "HistoryCellLand", bundle: nil), forCellReuseIdentifier: "HistoryCellLand")
		
		NavigationManager.it.mainView!.tabbarViewModel.unreadCount.observe { _ in
			self.eventsTable.reloadData()
		}
		
	}
	
	override func onToolbarRightButtonClicked() {
		if (model.editing.value!) {
			DialogUtil.confirm(messageTextKey: "delete_history_confirm_message",oneArg: "\(model.selectedForDeletion.value!.count)", confirmAction: {
				self.model.deleteSelection()
				self.eventsTable.reloadData()
				NavigationManager.it.mainView!.tabbarViewModel.updateUnreadCount()
				self.exitEdition()
			})
		} else {
			enterEdition()
		}
	}
	
	override func onToolbarLeftButtonClicked() {
		exitEdition()
	}
	
	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		NavigationManager.it.mainView!.right.prepare(iconName: "icons/delete",effectKey: "primary_color",tintColor: "color_c", textStyleKey: "toolbar_action", text: Texts.get("delete"))
		NavigationManager.it.mainView!.left.prepare(iconName: "icons/cancel",effectKey: "primary_color",tintColor: "color_c", textStyleKey: "toolbar_action", text: Texts.get("cancel"))
		NavigationManager.it.mainView?.toolbarViewModel.rightButtonVisible.value = model.history.value!.count > 0
		NotificationCenter.default.addObserver(self,
											   selector: #selector(applicationDidBecomeActive),
											   name: UIApplication.didBecomeActiveNotification,
											   object: nil)
	}
	
	func enterEdition() {
		NavigationManager.it.mainView?.toolbarViewModel.leftButtonVisible.value = true
		model.editing.value = true
		model.notifyDeleteSelectionListUpdated()
	}
	
	func exitEdition() {
		NavigationManager.it.mainView?.toolbarViewModel.leftButtonVisible.value = false
		model.editing.value = false
		model.selectedForDeletion.value!.removeAll()
		model.notifyDeleteSelectionListUpdated()
	}
	
	
	override func viewWillDisappear(_ animated: Bool) {
		HistoryEventStore.it.markAllAsRead()
		NavigationManager.it.mainView!.tabbarViewModel.updateUnreadCount()
		NavigationManager.it.mainView?.toolbarViewModel.rightButtonVisible.value = false
		NotificationCenter.default.removeObserver(self,
												  name: UIApplication.didBecomeActiveNotification,
												  object: nil)
		super.viewWillDisappear(animated)
	}
	
	
	
	// UITableView delegates & data
	
	
	func numberOfSections(in tableView: UITableView) -> Int {
		return model.historySplit.value!.count
	}
	
	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return model.historySplit.value![Array(model.historySplit.value!.keys.sorted().reversed())[section]]!.count
	}
	
	func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
		if let headerView = view as? UITableViewHeaderFooterView {
			headerView.contentView.backgroundColor = .clear
			headerView.backgroundView?.backgroundColor = .clear
			headerView.textLabel?.prepare(styleKey: "history_list_day_name")
			model.editing.readCurrentAndObserve { (editing) in
				headerView.alpha = editing! ? 0.3 : 1.0
			}
		}
	}
	
	func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
		return todayYesterdayRealDay(epochTimeDayUnit: Int(Array(model.historySplit.value!.keys.sorted().reversed())[section]))
	}
	
	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cell:HistoryCell = tableView.dequeueReusableCell(withIdentifier: UIDevice.ipad() && UIScreen.isLandscape ? "HistoryCellLand" : "HistoryCell") as! HistoryCell
		cell.set( model: HistoryEventViewModel(callLog: model.historySplit.value![Array(model.historySplit.value!.keys.sorted().reversed())[indexPath.section]]![indexPath.row], historyViewModel: model))
		cell.selectionStyle = .none
		return cell
	}
	
	func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		if (!model.editing.value! ) {
			//NavigationManager.it.navigateTo(childClass: Viewer.self, asRoot: false, argument: DeviceStore.it.devices[indexPath.row])
		}
	}
	
	func todayYesterdayRealDay(epochTimeDayUnit: Int) -> String {
		
		let formatter = DateFormatter()
		formatter.dateFormat = "yyyy-MM-dd"
		
		if (epochTimeDayUnit == Int(Date().timeIntervalSince1970 / 86400)) {
			return Texts.get("today")
		} else if (epochTimeDayUnit == Int(Date().timeIntervalSince1970 / 86400 - 1)) {
			return Texts.get("yesterday")
		} else {
			return formatter.string(from: Date(timeIntervalSince1970:Double(epochTimeDayUnit) * 86400))
		}
	}
	
	
	override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
		super.viewWillTransition(to: size, with: coordinator)
		if (UIDevice.ipad()) {
			coordinator.animate(alongsideTransition: { context in
				self.eventsTable.reloadData()
				NavigationManager.it.mainView?.toolbarViewModel.rightButtonVisible.value = self.model.history.value!.count > 0
			}, completion: { context in
			})
			
		}
	}
	
	@objc func applicationDidBecomeActive() {
		DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(250)) {
			self.model.refresh()
		}
	}
	
	
}
