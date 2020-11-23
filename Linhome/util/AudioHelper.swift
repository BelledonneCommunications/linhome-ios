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

class AudioHelper {
	
	static var bluetoothRoutes: [AVAudioSession.Port] = [.bluetoothHFP, .carAudio, .bluetoothA2DP, .bluetoothLE]
	
	class func bluetoothAudioDevice() -> AVAudioSessionPortDescription? {
		return AudioHelper.audioDevice(fromTypes: AudioHelper.bluetoothRoutes)
	}
	
	class func builtinAudioDevice() -> AVAudioSessionPortDescription? {
		return AudioHelper.audioDevice(fromTypes: [.builtInMic])
	}
	
	class func speakerAudioDevice() -> AVAudioSessionPortDescription? {
		return AudioHelper.audioDevice(fromTypes: [.builtInSpeaker])
	}
	
	class func audioDevice(fromTypes types: [AVAudioSession.Port]?) -> AVAudioSessionPortDescription? {
		let routes = AVAudioSession.sharedInstance().availableInputs
		for route in routes ?? [] {
			if types?.contains(route.portType) ?? false {
				return route
			}
		}
		return nil
	}
	
	class func speakerAllowed() -> Bool {
		if (UIDevice.current.userInterfaceIdiom == .pad) {
			return true
		}
		
		var allowed = true
		let newRoute = AVAudioSession.sharedInstance().currentRoute
		if (newRoute.outputs.count > 0) {
			let route = newRoute.outputs[0].portType
			allowed = !( route == .lineOut || route == .headphones || (AudioHelper.bluetoothRoutes.contains(where: {$0 == route})))
		}
		return allowed
	}
	
	
	func speakerOn() -> Bool {
		return AVAudioSession.sharedInstance().currentRoute.outputs.count > 0 && AVAudioSession.sharedInstance().currentRoute.outputs[0].portType == .builtInSpeaker
	}
	
	
}
