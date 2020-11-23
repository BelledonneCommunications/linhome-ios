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
