//
//  VibratorHelper.swift
//  Linhome
//
//  Created by Tof on 11/11/2020.
//  Copyright © 2020 Belledonne communications. All rights reserved.
//

import Foundation
import AVFoundation
import UIKit

class VibratorHelper {
	
	static var vibrating = false
	
	static func vibrate(_ force:Bool? = nil) {
		if (force != nil) {
			vibrating = force!
		}
		if (!vibrating) {
			return
		}
		
		try? AVAudioSession.sharedInstance().setCategory(AVAudioSession.Category.playAndRecord, options: .mixWithOthers)
		try? AVAudioSession.sharedInstance().setActive(true, options: .notifyOthersOnDeactivation)
		
		AudioServicesPlaySystemSoundWithCompletion(kSystemSoundID_Vibrate) {
			DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(2)) {
				if (vibrating) {
					vibrate()
				}
			}
		}
	}
	
	
	
}
