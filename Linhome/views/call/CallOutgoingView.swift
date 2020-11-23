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
