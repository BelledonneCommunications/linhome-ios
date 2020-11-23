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


class DotsSpinner : UIView {
    private var dotLayers = [CAShapeLayer]()
    private var dotsScale = 1.4
    
    
	var dotsCount :Int = 3 {
        didSet {
            self.layer.sublayers?.forEach { $0.removeFromSuperlayer() }
            self.dotLayers.removeAll()
            self.setupLayers()
        }
    }
    
    var dotsRadius :CGFloat = 7 {
        didSet {
            for layer in dotLayers {
                layer.bounds = CGRect(origin: CGPoint.zero, size: CGSize(width: dotsRadius*2.0, height: dotsRadius*2.0))
                layer.path = UIBezierPath(roundedRect: layer.bounds, cornerRadius: dotsRadius).cgPath
            }
            self.setNeedsLayout()
        }
    }
    
    var dotsSpacing :CGFloat = 7 {
        didSet {
            self.setNeedsLayout()
        }
    }
    
    override var tintColor: UIColor! {
        didSet {
            for layer in dotLayers {
                layer.fillColor = tintColor.cgColor
            }
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.setupLayers()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        self.setupLayers()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        let center = CGPoint(x: self.frame.size.width/2.0, y: self.frame.size.height/2.0)
        let even = (dotsCount % 2 == 0)
        let middle :Int = dotsCount/2
        for (index, layer) in dotLayers.enumerated() {
            let x = center.x+CGFloat(index-middle)*((dotsRadius*2)+dotsSpacing)+(even ? (dotsRadius+(dotsSpacing/2)) : 0)
            layer.position = CGPoint(x: x, y: center.y)
        }
        startAnimating()
    }
    
    func startAnimating() {
        var offset :TimeInterval = 0.0
        dotLayers.forEach {
            $0.removeAllAnimations()
            $0.add(scaleAnimation(offset), forKey: "scaleAnim")
            offset = offset+0.25
        }
    }
    
    func stopAnimating() {
        dotLayers.forEach { $0.removeAllAnimations() }
    }
    
    private func dotLayer() -> CAShapeLayer {
        let layer = CAShapeLayer()
        layer.bounds = CGRect(origin: CGPoint.zero, size: CGSize(width: dotsRadius*2.0, height: dotsRadius*2.0))
        layer.path = UIBezierPath(roundedRect: layer.bounds, cornerRadius: dotsRadius).cgPath
        layer.fillColor = tintColor.cgColor
        return layer
    }
    
    private func setupLayers() {
        for _ in 0..<dotsCount {
            let layer = dotLayer()
            self.dotLayers.append(layer)
            self.layer.addSublayer(layer)
        }
    }
    
    private func scaleAnimation(_ after: TimeInterval = 0) -> CAAnimationGroup {
        let scaleUp = CABasicAnimation(keyPath: "transform.scale")
        scaleUp.beginTime = after
        scaleUp.fromValue = 1
        scaleUp.toValue = dotsScale
        scaleUp.duration = 0.2
		scaleUp.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeOut)
        
        let scaleDown = CABasicAnimation(keyPath: "transform.scale")
        scaleDown.beginTime = after+scaleUp.duration
        scaleDown.fromValue = dotsScale
        scaleDown.toValue = 1.0
        scaleDown.duration = 0.1
		scaleDown.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeOut)
        
        let group = CAAnimationGroup()
        group.animations = [scaleUp, scaleDown]
        group.repeatCount = Float.infinity
        
        let sum = CGFloat(dotsCount)*0.3+CGFloat(0.4)
        group.duration = CFTimeInterval(sum)
        
        return group
    }
}
