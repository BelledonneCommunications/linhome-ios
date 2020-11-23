//
//  Device+Extension.swift
//  Linhome
//
//  Created by Tof on 14/09/2020.
//  Copyright © 2020 Belledonne communications. All rights reserved.
//

import Foundation
import UIKit
import AVFoundation

extension UIDevice {
	static func ipad() -> Bool {
		return UIDevice.current.userInterfaceIdiom == .pad
	}
	static func vibrate() {
		if (!ipad()) {
			AudioServicesPlaySystemSound(kSystemSoundID_Vibrate)
		}
	}
	static func hasNotch() -> Bool {
		if (UserDefaults.standard.bool(forKey: "hasNotch")) {
			return true
		}
		guard #available(iOS 11.0, *), let topPadding = UIApplication.shared.keyWindow?.safeAreaInsets.top, topPadding > 24 else {
			return false
		}
		UserDefaults.standard.setValue(true, forKey: "hasNotch")
		return true
	}
}
