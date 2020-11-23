//
//  UIViewControllerWithViewModelViewController.swift
//  Lindoor
//
//  Created by Christophe Deschamps on 26/06/2020.
//  Copyright © 2020 Belledonne communications. All rights reserved.
//

import UIKit

class MVVMUIViewController: UIViewController {

	private var managedModel: ManagedViewModel? = nil

	public override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
		super.init(nibName: nibNameOrNil,bundle: nibBundleOrNil)
	}
	
	required init?(coder: NSCoder) {
		super.init(coder: coder)
	}
	
	override func viewWillDisappear(_ animated: Bool) {
		managedModel.map{$0.onPause()}
		super .viewWillDisappear(animated)
	}
	
	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		managedModel.map{$0.onResume()}
	}
	
	func manageModel(_ model:ManagedViewModel) {
		managedModel = model
	}
	
}
