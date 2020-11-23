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


import Foundation
import UIKit

class CallOutgoingView : GenericCallView {
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		let chunkNameAddress = ChunkNameAddress(viewModel: callViewModel!)
		self.view.addSubview(chunkNameAddress.view)
		chunkNameAddress.view.snp.makeConstraints { (make) in
			make.left.right.equalToSuperview()
			make.top.equalTo(chunkTop!.view.snp.bottom).offset(100)
		}
		
		let chunkVideoOrIcon = ChunkCallVideoOrIcon(viewModel: callViewModel!)
		self.view.addSubview(chunkVideoOrIcon.view)
		chunkVideoOrIcon.view.snp.makeConstraints { (make) in
			make.centerX.equalToSuperview()
			make.top.equalTo(chunkNameAddress.view.snp.bottom).offset(27)
		}
		
		
		let spinner = DotsSpinner()
		spinner.frame = CGRect(x: 0,y: 0,width: 100,height: 30)
		spinner.tintColor = Theme.getColor("color_c")
		self.view.addSubview(spinner)
		spinner.snp.makeConstraints { (make) in
			make.centerX.equalToSuperview()
			make.top.equalTo(chunkVideoOrIcon.view.snp.bottom).offset(54)
			make.height.equalTo(spinner.frame.size.height)
		}
		
		let cancel = CallButton.addOne(targetVC: self, iconName: "icons/decline", textKey: "call_button_cancel", effectKey: "decline_call_button", tintColor: "color_c", action: {self.callViewModel?.cancel()})
		cancel.view.snp.makeConstraints { (make) in
			make.centerX.equalToSuperview()
			make.bottom.equalToSuperview().offset(-30)
		}
	
	}
	
}
