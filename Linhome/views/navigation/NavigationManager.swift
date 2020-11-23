//
//  NavigationManager.swift
//  Linhome
//
//  Created by Christophe Deschamps on 02/07/2020.
//  Copyright © 2020 Belledonne communications. All rights reserved.
//

import Foundation
import UIKit
import linphonesw

// Inner MainView Navigation (e.g. handle all navigation except call views - similar to Android MainActivity, navigating fragments


class NavigationManager {
	
	var mainView : MainView?
	static let it  =  NavigationManager()
	
	var viewStack : [ViewWithModel] = []
	var nextViewArgument:Any?
	
	
	func hasNib(className:String) -> Bool {
		return Bundle.main.path(forResource: className, ofType: "nib") != nil
	}
	
	func navigateTo<T>(childClass: T.Type, asRoot:Bool = false, argument:Any? = nil) where T: ViewWithModel {
		self.nextViewArgument = argument
		let child = hasNib(className: String(describing: childClass)) ? childClass.init(nibName: String(describing: childClass) , bundle: nil) : childClass.init()
		child.view.frame = child.isCallView() ? UIScreen.main.bounds : mainView!.content.frame
		mainView!.addChild(child)
		if (child.isCallView()) {
			mainView!.view.addSubview(child.view)
		} else {
			mainView!.content.addSubview(child.view)
		}
		child.didMove(toParent: self.mainView!)
		viewStack.last.map {$0.viewWillDisappear(true) }
		if (asRoot) {
			viewStack.forEach {
				$0.finish()
			}
			viewStack.removeAll()
		}
		viewStack.append(child)
		updateNavigationComponents()
	}
	
	func navigateUp(completion : (()->Void)? = nil) {
		if let child = viewStack.last {
			if (type(of: child) == SideMenu.self) {
				mainView?.back.isUserInteractionEnabled = false
				mainView?.burger.isUserInteractionEnabled = false
				UIView.animate(withDuration: 0.2, animations: {
					child.view.snp.removeConstraints()
					child.view.snp.makeConstraints { make in
						make.left.equalTo(-child.view.frame.size.width)
						make.top.bottom.equalToSuperview()
					}
					child.view.superview?.layoutIfNeeded()
				}, completion: { finished in
					self.mainView?.back.isUserInteractionEnabled = true
					self.mainView?.burger.isUserInteractionEnabled = true
					self.doNavigateUp()
					completion?()
				})
			} else {
				doNavigateUp()
			}
		}
	}
	
	
	func doNavigateUp() {
		if let child = viewStack.popLast() {
			child.finish()
			updateNavigationComponents()
		}
		viewStack.last.map {$0.viewWillAppear(true) }
	}
	
	
	// set titles, menu, constraints based on the current View (last on stack)
	
	func updateNavigationComponents() {
		viewStack.last.map{ someView in
			if (someView.isCallView()) {
				return
			}
			let current = someView as! MainViewContent
			mainView!.back.isHidden = current.isRoot
			mainView!.burger.isHidden = !current.isRoot
			mainView!.navigationTitle.setText(textKey: current.titleTextKey)
			current.view.snp.makeConstraints{ (make) in
				make.edges.equalTo(mainView!.content)
			}
			
			current.view.translatesAutoresizingMaskIntoConstraints = false
			
			mainView!.content.snp.removeConstraints()
			mainView!.content.snp.makeConstraints { (make) in
				make.right.left.equalToSuperview()
				make.top.equalTo(mainView!.topBar.snp.bottom)
				make.bottom.equalTo(current.onTopOfBottomBar ? mainView!.view.snp.bottom: mainView!.bottomBar.snp.top)
				mainView!.bottomBar.isHidden = current.onTopOfBottomBar
			}
			
			if (type(of: current) == DevicesView.self || type(of: current) == HistoryView.self ) {
				enterRootFragment()
				current.viewWillAppear(false)
			} else {
				enterNonRootFragment()
			}
		}
	}
	
	func pauseNavigation() {
		mainView!.toolbarViewModel.backButtonVisible.value = false
	}
	
	func resumeNavigation() {
		mainView!.toolbarViewModel.backButtonVisible.value = true
		mainView!.toolbarViewModel.leftButtonVisible.value = false
	}
	
	
	private func enterNonRootFragment() {
		mainView!.toolbarViewModel.backButtonVisible.value = true
		mainView!.toolbarViewModel.burgerButtonVisible.value = false
	}
	
	private func enterRootFragment() {
		mainView!.toolbarViewModel.backButtonVisible.value = false
		mainView!.toolbarViewModel.burgerButtonVisible.value = true
		mainView!.toolbarViewModel.leftButtonVisible.value = false
		mainView!.toolbarViewModel.rightButtonVisible.value = false
	}
	
	
	
}
