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

class PlayerControls: UIViewController {
	@IBOutlet weak var reload: UIButton!
	@IBOutlet weak var play: UIButton!
	@IBOutlet weak var slider: UISlider!
	@IBOutlet weak var timerText: UILabel!
	
	var timer:Timer?
	let playerViewModel : PlayerViewModel
	let formatter = DateComponentsFormatter()
	
	
	init(viewModel:PlayerViewModel) {
		self.playerViewModel = viewModel
		super.init(nibName:nil, bundle:nil)
	}
	
	var userTracking = false
	
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		reload.prepareRoundIcon(effectKey: "primary_color", tintColor: "color_c", iconName: "icons/reload.png", padding: 8)
		reload.onClick {
			self.playerViewModel.playFromStart()
		}
		
		playerViewModel.playing.readCurrentAndObserve(onChange: { (playing) in
			self.play.prepareRoundIcon(effectKey: "primary_color", tintColor: "color_c", iconName: playing! ? "icons/pause" : "icons/play.png", padding: 12)
		})
		play.onClick {
			self.playerViewModel.togglePlay()
		}
		
		
		slider.minimumTrackTintColor = Theme.getColor("color_g")
		slider.maximumTrackTintColor = Theme.getColor("color_c")
		slider.thumbTintColor = playerViewModel.trackingAllowed.value == true ?  Theme.getColor("color_a") : .clear
		slider.isUserInteractionEnabled = true // playerViewModel.trackingAllowed.value == true
		slider.setThumbImage(self.circle(diameter: 10, color: Theme.getColor("color_a")), for: .normal)
		slider.maximumValue = Float(playerViewModel.duration)
		playerViewModel.position.observe(onChange: { (pos) in
			self.slider.value = Float(pos!)
		})
		
		slider.addTarget(self, action: #selector(onSeek(slider:event:)), for: UIControl.Event.valueChanged)
		
		
		
		timerText.prepare(styleKey: "player_time")
		timerText.text = "00:00"
		
		formatter.unitsStyle = .positional
		formatter.allowedUnits = [.minute, .second ]
		formatter.zeroFormattingBehavior = [ .pad ]
		
		
		timer = Timer.scheduledTimer(withTimeInterval: 0.02, repeats: true) { _ in
			if (self.userTracking) {
				return
			}
			self.playerViewModel.updatePosition()
			self.formatter.string(from: TimeInterval(self.playerViewModel.position.value!/1000)).map {
				self.timerText.text = $0.hasPrefix("0:") ? "0" + $0 : $0
			}
		}
		
	}
	
	@objc func onSeek(slider: UISlider, event: UIEvent) {
		if let touchEvent = event.allTouches?.first {
			switch touchEvent.phase {
			case .began:
				self.userTracking = true
				self.playerViewModel.pausePlay()
			case .moved:
				formatter.string(from: TimeInterval(slider.value/1000)).map {
					self.timerText.text = $0.hasPrefix("0:") ? "0" + $0 : $0
				}
				self.userTracking = true
			case .ended:
				self.userTracking = false
				self.playerViewModel.seek(targetSeek: Int(slider.value))
			default:
				break
			}
		}
	}
	
	
	func circle(diameter: CGFloat, color: UIColor) -> UIImage {
		UIGraphicsBeginImageContextWithOptions(CGSize(width: diameter, height: diameter), false, 0)
		let ctx = UIGraphicsGetCurrentContext()!
		ctx.saveGState()
		
		let rect = CGRect(x: 0, y: 0, width: diameter, height: diameter)
		ctx.setFillColor(color.cgColor)
		ctx.fillEllipse(in: rect)
		
		ctx.restoreGState()
		let img = UIGraphicsGetImageFromCurrentImageContext()!
		UIGraphicsEndImageContext()
		
		return img
	}
	
	
	override func viewWillDisappear(_ animated: Bool) {
		timer?.invalidate()
		super.viewWillDisappear(animated)
	}
	
}
