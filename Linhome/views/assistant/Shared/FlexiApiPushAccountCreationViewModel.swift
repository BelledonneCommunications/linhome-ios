/*
 * Copyright (c) 2010-2023 Belledonne Communications SARL.
 *
 * This file is part of linphone-android
 * (see https://www.linphone.org).
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

import linphonesw

class  FlexiApiPushAccountCreationViewModel : CreatorAssistantViewModel {
	
	let pushReady = MutableLiveData(false)

	func createPushAccount() {
		if (!CorePreferences.them.automaticallyCreatePushGatewayAccount) {
			Log.info("[Assistant] [Push Account Creation] skipping as automaticallyCreatePushGatewayAccount is set to false")
			pushReady.value = true
			return
		}
			
		if (creatorDelegate != nil) {
			accountCreator.removeDelegate(delegate: creatorDelegate!)
		}
		creatorDelegate = AccountCreatorDelegateStub(
			onCreateAccount:  { (creator:AccountCreator, status:AccountCreator.Status, response:String) -> Void in
				Log.info("[Assistant] [Push Account Creation] Account creation response \(status)")
				if (status == AccountCreator.Status.AccountCreated) {
					Config.flexiApiToken = nil
					if let pushAccount = try? creator.createAccountInCore() {
						pushAccount.params?.clone().map { clonedParams in
							clonedParams.idkey = Config.PUSH_GW_ID_KEY
							pushAccount.params = clonedParams
						}
						LinhomeAccount.it.linkProxiesWithPushAccount(pushReady: self.pushReady)
					}
				} else if (status == AccountCreator.Status.MissingArguments) {
					Log.info("[Assistant] [Push Account Creation] Creation request not authorized, requesting a new token.")
					Config.flexiApiToken = nil
					self.requestFlexiApiToken()
				} else {
					self.pushReady.value = false
					Log.error("[Assistant] [Push Account Creation] fail creating a push account \(status)")
				}
			},
			onSendToken: { (creator:AccountCreator, status:AccountCreator.Status, response:String) -> Void in
				Log.info("[Assistant] [Push Account Creation] get push token \(status) \(response)")
				if (status == AccountCreator.Status.RequestTooManyRequests) {
					self.pushReady.value = false
				}
			}
		)
		
		let token = Config.flexiApiToken
		if (token != nil) {
			accountCreator.token = token
			Log.info("[Assistant] [Push Account Creation] We already have an auth token from FlexiAPI \(String(describing: token)), continue")
			onFlexiApiTokenReceived()
		} else {
			Log.info("[Assistant] [Push Account Creation] Requesting an auth token from FlexiAPI")
			requestFlexiApiToken()
		}
		accountCreator.addDelegate(delegate:creatorDelegate!)
	}
	
	override func onFlexiApiTokenReceived() {
		Log.info("[Assistant] [Push Account Creation] Using FlexiAPI auth token \(accountCreator.token)]")
		accountCreator.domain = CorePreferences.them.loginDomain
		accountCreator.algorithm = "SHA-256"
		let status = try?accountCreator.createPushAccount()
		Log.info("[Assistant] [Push Account Creation] create Account returned \(status)")
		if (status != AccountCreator.Status.RequestOk) {
			pushReady.value = false
		}
	}
	
	override func onFlexiApiTokenRequestError() {
		Log.error("[Assistant] [Push Account Creation] Failed to get an auth token from FlexiAPI")
		pushReady.value = false
	}
	
}
