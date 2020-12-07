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
import MarqueeLabel

class CallButton: UIViewController {

	@IBOutlet var button: UIButton!
	@IBOutlet var labelOn: MarqueeLabel!
	@IBOutlet var labelOff: MarqueeLabel!
	@IBOutlet var strikeThrough: UIView!

	var off  : MutableLiveData<Bool>?
		
	override func viewDidLoad() {
		
		button = UIButton(frame: CGRect(x: 30,y: 0,width: 60,height: 60))
		labelOn = MarqueeLabel(frame: CGRect(x: 0,y: 66,width: 120,height: 34))
		labelOff = MarqueeLabel(frame: CGRect(x: 0,y: 66,width: 120,height: 34))
		
		self.view.addSubview(button)
		self.view.addSubview(labelOn)
		self.view.addSubview(labelOff)

		labelOn.prepare(styleKey: "call_action_button")
		labelOff.prepare(styleKey: "call_action_button")

        super.viewDidLoad()
    }
	
	class func addOne(targetVC:UIViewController,off:MutableLiveData<Bool>? = nil, iconName:String, textKey:String? = nil, text:String? = nil, textOffKey:String? = nil, effectKey: String, tintColor:String, outLine:Bool = false, action : @escaping ()->Void, toStackView:UIStackView? = nil, outLineColorKey: String = "color_c") -> CallButton {
		
		let child = CallButton()
		targetVC.addChild(child)
		if (toStackView != nil) {
			toStackView!.addArrangedSubview(child.view)
		} else {
			targetVC.view.addSubview(child.view)
		}
		child.didMove(toParent: targetVC)
		
		child.off = off
		child.off.map{ (off) in
			
			// oblique strike through
			let path = UIBezierPath()
			path.move(to: CGPoint(x: 5, y: 55))
			path.addLine(to: CGPoint(x: 55, y: 5))

			let shapeLayer = CAShapeLayer()
			shapeLayer.path = path.cgPath
			shapeLayer.strokeColor = Theme.getColor("color_c").cgColor
			shapeLayer.lineWidth = 1.0

			// State change observe
			child.off?.readCurrentAndObserve { (off) in
				child.labelOn.isHidden = off!
				child.labelOff.isHidden = !off!
				if (!off!) {
					shapeLayer.removeFromSuperlayer()
				} else {
					child.button.layer.addSublayer(shapeLayer)
				}
			}
		}
		
		child.button.prepareRoundIcon(effectKey: effectKey, tintColor: tintColor, iconName: iconName, padding: 12, outLine:outLine, outLineColorKey: outLineColorKey)
		child.labelOn.text = " " + (textKey != nil ? Texts.get(textKey!) : text!) + " " // Spaces for Marquee
		textOffKey.map{child.labelOff.text = " " + Texts.get($0) + " "}
		
		child.button.onClick {
			action()
		}
		
		child.view.snp.makeConstraints{ (make) in
			make.width.equalTo(120)
			make.height.equalTo(UIDevice.is5SorSEGen1() ? 80 : 100)
		}
		
		child.labelOn.snp.makeConstraints { (make) in
			make.centerX.equalToSuperview()
			make.bottom.equalToSuperview()
			make.width.equalTo(120)
		}
		
		child.labelOff.snp.makeConstraints { (make) in
			make.centerX.equalToSuperview()
			make.bottom.equalToSuperview()
			make.width.equalTo(120)
		}
		
		child.button.snp.makeConstraints { (make) in
			make.centerX.equalToSuperview()
			make.width.height.equalTo(60)
		}
				
		return child
	}
	

}
