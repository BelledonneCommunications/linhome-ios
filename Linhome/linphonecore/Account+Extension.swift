//
//  Account+Extension.swift
//  Linhome
//
//  Created by Tof on 15/02/2023.
//  Copyright © 2023 Belledonne communications. All rights reserved.
//

import Foundation
import linphonesw

extension Account {
	
	public func addPushToken() { // Update the registration of an Account with Push parameters, not done in SDK (yet!) as some custom parameters need to be set, and VoIP Push needs to be disabled.
		
		if (params?.domain != Config.get().getString(section: "assistant", key: "domain")) {
			Log.info("Skipping adding push marapeters as not of domain \(Config.get().getString(section: "assistant", key: "domain")) ")
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
