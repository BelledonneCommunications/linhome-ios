//
//  ChunkNameAddress.swift
//  Linhome
//
//  Created by Christophe Deschamps on 11/07/2020.
//  Copyright © 2020 Belledonne communications. All rights reserved.
//

import UIKit

class ChunkNameAddress: UIViewController {
	
	let callViewModel : CallViewModel
	
	init(viewModel:CallViewModel) {
		self.callViewModel = viewModel
		super.init(nibName:nil, bundle:nil)
	}
	
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
    override func viewDidLoad() {
        super.viewDidLoad()
		let name = UILabel()
		self.view.addSubview(name)
		name.snp.makeConstraints { (make) in
			make.left.right.equalToSuperview()
		}
		name.prepare(styleKey: "view_call_device_name")
		name.text = callViewModel.device != nil ? callViewModel.device?.name : callViewModel.call.remoteAddress?.username
		
		let address = UILabel()
		self.view.addSubview(address)
		address.snp.makeConstraints { (make) in
			make.left.right.equalToSuperview()
			make.top.equalTo(name.snp.bottom).offset(5)
		}
		address.prepare(styleKey: "view_call_device_address")
		address.text = callViewModel.call.remoteAddress?.asString()
		
		self.view.snp.makeConstraints { (make) in
			make.height.equalTo(address.intrinsicContentSize.height + name.intrinsicContentSize.height + 5)
		}
	
		
    }
    
}
