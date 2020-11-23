//
//  AudioHelper.swift
//  Linhome
//
//  Created by Christophe Deschamps on 07/07/2020.
//  Copyright © 2020 Belledonne communications. All rights reserved.
//

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
