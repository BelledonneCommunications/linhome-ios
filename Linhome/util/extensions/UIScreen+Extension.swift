//
//  UIScreen+Extension.swift
//  Linhome
//
//  Created by Tof on 14/09/2020.
//  Copyright © 2020 Belledonne communications. All rights reserved.
//

import Foundation
import UIKit

 extension UIScreen {
	
	static var rotated = MutableLiveData(false)
	
    public class var isPortrait: Bool {
		if #available(iOS 13.0, *) {
			return UIApplication.shared.windows.first?.windowScene?.interfaceOrientation.isPortrait ?? true
			} else {
				return UIApplication.shared.statusBarOrientation.isPortrait
			}
    }
    public class var isLandscape: Bool { !isPortrait }
}
