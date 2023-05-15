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
import linphonesw

class VibratorHelper {
	
	static var shouldVibrate = false
	
	static func vibrate(_ force:Bool? = nil) {
		if (force != nil) {
			shouldVibrate = force!
		}
		if (!shouldVibrate) {
			return
		}
				
		AudioServicesPlaySystemSoundWithCompletion(kSystemSoundID_Vibrate) {
			DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(2)) {
				if (shouldVibrate && Core.get().currentCall?.state == .IncomingReceived || Core.get().currentCall?.state == .IncomingEarlyMedia) {
					vibrate()
				}
			}
		}
	}
	
	
	
}
