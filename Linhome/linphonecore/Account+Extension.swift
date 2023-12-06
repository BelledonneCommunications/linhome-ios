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
	
	public func configurePushNotificationParameters() {
		params?.clone().map {newParams in
			newParams.pushNotificationConfig?.provider = Config.pushProvider
			newParams.pushNotificationConfig?.remotePushInterval = "\(Config.pushNotificationsInterval)"
			newParams.pushNotificationAllowed = false // Disable PushKit (CallKit notifications)
			newParams.remotePushNotificationAllowed = true // Enable Remote notifications
			newParams.pushNotificationConfig?.voipToken = nil // Forces removal of voip notification service in SDK.
			params = newParams
		}
		refreshRegister()
	}
}
