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
