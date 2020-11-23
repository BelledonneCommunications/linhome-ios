//
//  RegistrationState+Extension.swift
//  Linhome
//
//  Created by Tof on 14/09/2020.
//  Copyright © 2020 Belledonne communications. All rights reserved.
//

import Foundation
import linphonesw

extension RegistrationState {
	
	func toHumanReadable() -> String {
		switch(self) {
		case .None : return Texts.get("registration_state_none")
		case .Progress : return Texts.get("registration_state_progress")
		case .Ok : return Texts.get("registration_state_ok")
		case .Failed : return Texts.get("registration_state_failed")
		case .Cleared : return Texts.get("registration_state_cleared")
		}
	}

}
