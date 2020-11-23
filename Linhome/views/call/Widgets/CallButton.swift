//
//  CallButton.swift
//  Linhome
//
//  Created by Christophe Deschamps on 13/07/2020.
//  Copyright © 2020 Belledonne communications. All rights reserved.
//

import UIKit

class CallButton: UIViewController {

	@IBOutlet var button: UIButton!
	@IBOutlet var labelOn: UILabel!
	@IBOutlet var labelOff: UILabel!
	@IBOutlet var strikeThrough: UIView!

	var off  : MutableLiveData<Bool>?
		
	override func viewDidLoad() {
		
		button = UIButton(frame: CGRect(x: 30,y: 0,width: 60,height: 60))
		labelOn = UILabel(frame: CGRect(x: 0,y: 66,width: 120,height: 34))
		labelOff = UILabel(frame: CGRect(x: 0,y: 66,width: 120,height: 34))
		
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
		child.labelOn.text = textKey != nil ? Texts.get(textKey!) : text
		textOffKey.map{child.labelOff.text = Texts.get($0)}
		
		child.button.onClick {
			action()
		}
		
		child.view.snp.makeConstraints{ (make) in
			make.width.equalTo(120)
			make.height.equalTo(100)
		}
		
		child.labelOn.snp.makeConstraints { (make) in
			make.centerX.equalToSuperview()
			make.bottom.equalToSuperview()
		}
		child.button.snp.makeConstraints { (make) in
			make.centerX.equalToSuperview()
			make.width.height.equalTo(60)
		}
				
		return child
	}
	

}
