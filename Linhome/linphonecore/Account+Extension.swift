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
import linphonesw

extension Account {
	
	public func addPushToken() { // Update the registration of an Account with Push parameters, not done in SDK (yet!) as some custom parameters need to be set, and VoIP Push needs to be disabled.
		
		if (params?.domain != CorePreferences.them.loginDomain) {
			Log.info("Skipping adding push parameters as not of domain \(CorePreferences.them.loginDomain) ")
			return
		}
		
		guard let pushToken = Core.pushToken else {
			Log.warn("No push token.")
			return
		}
		
		params?.clone().map { clonedParams in
			let services = "remote"
			let token = pushToken+":"+services
	#if DEBUG
			let pushEnvironment = ".dev"
	#else
			let pushEnvironment = ""
	#endif
			clonedParams.contactUriParameters = "pn-provider=apns"+pushEnvironment+";pn-prid="+token+";pn-param="+Config.teamID+"."+Bundle.main.bundleIdentifier!+"."+services+";pn-silent=1;pn-msg-str=IM_MSG;pn-call-str=IC_MSG;"+"pn-call-remote-push-interval=\(Config.pushNotificationsInterval)"
			clonedParams.contactParameters = ""
			params = clonedParams
			refreshRegister()
		}
}
}
