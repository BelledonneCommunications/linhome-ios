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
import linphone

class CreatorAssistantViewModel : ViewModel {
	
	let accountCreator: AccountCreator
	var creatorDelegate : AccountCreatorDelegateStub? = nil
	var coreDelegate : CoreDelegateStub? = nil
	var waitingForFlexiApiTokenViaPush = false
	
	init(defaultValuePath:String) {
		Core.get().loadConfigFromXml(xmlUri: defaultValuePath)
		accountCreator = try!Core.get().createAccountCreator(xmlrpcUrl: CorePreferences.them.xmlRpcServerUrl)
		if (CorePreferences.them.loginDomain != nil) {
			accountCreator.domain  = CorePreferences.them.loginDomain!
		}
		if (Locale.current.languageCode != nil) {
			accountCreator.language = Locale.current.languageCode!
		}
		accountCreator.algorithm = CorePreferences.them.passwordAlgo!
		super.init()
		accountCreator.token = Config.flexiApiToken
		(UIApplication.shared.delegate as! AppDelegate).flexiApiTokenReceived.observe { _ in
			self.waitingForFlexiApiTokenViaPush = false
			self.accountCreator.token = Config.flexiApiToken
			self.onFlexiApiTokenReceived()
		}
    }

	// Form field validation agains account creator rules.
	
    func setUsername(field: Pair<MutableLiveData<String>, MutableLiveData<Bool>>) ->  LinphoneAccountCreatorUsernameStatus? {
		if (TextUtils.isEmpty(field.first.value)) {
            return nil
		}
		accountCreator.username = field.first.value!
		let result = accountCreator.setUserName(field.first.value!)
        field.second.value = result == LinphoneAccountCreatorUsernameStatusOk
        return result
    }

    func setPassword(field: Pair<MutableLiveData<String>, MutableLiveData<Bool>>) ->  LinphoneAccountCreatorPasswordStatus? {
		if (TextUtils.isEmpty(field.first.value)) {
            return nil
		}
		let result = accountCreator.setPassword( field.first.value!)
        field.second.value = result == LinphoneAccountCreatorPasswordStatusOk
        return result
    }

    func setEmail(field: Pair<MutableLiveData<String>, MutableLiveData<Bool>>) ->  LinphoneAccountCreatorEmailStatus? {
		if (TextUtils.isEmpty(field.first.value)) {
            return nil
		}
        let result = accountCreator.setEmail(field.first.value!)
        field.second.value = result == LinphoneAccountCreatorEmailStatusOk
        return result
    }

    func setDomain(field: Pair<MutableLiveData<String>, MutableLiveData<Bool>>) ->  LinphoneAccountCreatorDomainStatus? {
		if (TextUtils.isEmpty(field.first.value)) {
            return nil
		}
		let result = accountCreator.setDomain(field.first.value!)
        field.second.value = result == LinphoneAccountCreatorDomainOk
        return result
    }

    func setTransport(transport: TransportType) {
        accountCreator.transport = transport
    }
	
	// Local proxy config creation
	
	func linhomeAccountCreateProxyConfig(checkRegistration:Bool, registrationOk:MutableLiveData<Bool>?) {
		let account = try!accountCreator.createAccountInCore()
		account.configurePushNotificationParameters()
		account.findAuthInfo().map { authInfo in
			authInfo.clone().map { clonedAuthInfo in
				Core.get().removeAuthInfo(info: authInfo)
				clonedAuthInfo.algorithm = CorePreferences.them.passwordAlgo!
				Core.get().addAuthInfo(info: clonedAuthInfo)
			}
		}
		if (checkRegistration) {
			coreDelegate =  CoreDelegateStub(
				onAccountRegistrationStateChanged : { (core: Core, account: Account, state: RegistrationState, message: String) -> Void in
					if (state == .Ok) {
						core.removeDelegate(delegate: self.coreDelegate!)
						registrationOk?.value = true
					}
					if (state == .Failed) {
						core.removeDelegate(delegate: self.coreDelegate!)
						registrationOk?.value = false
					}
				}
			)
			Core.get().addDelegate(delegate: coreDelegate!)
			account.refreshRegister()
		}
	}

	// FlexiApi Account Token Request
	
	func onFlexiApiTokenReceived() {}
	func onFlexiApiTokenRequestError() {}
	
	func requestFlexiApiToken() {
		if (!Core.get().isPushNotificationAvailable) {
			Log.error("[FlexiApiPushToken] Core says push notification aren't available, can't request a token from FlexiAPI")
			onFlexiApiTokenRequestError()
			return
		}
		
		if let pushConfig = Core.get().pushNotificationConfig {
			Core.get().pushNotificationConfig?.voipToken = nil
			Core.get().pushNotificationConfig?.provider = Config.pushProvider
			accountCreator.pnProvider = pushConfig.provider
			accountCreator.pnParam = "\(pushConfig.teamId!).\(Bundle.main.bundleIdentifier!).remote"
			accountCreator.pnPrid = pushConfig.remoteToken
			
			// Request an auth token that will be sent by push
			let result = accountCreator.requestAuthToken()
			if (result == AccountCreator.Status.RequestOk) {
				waitingForFlexiApiTokenViaPush = true
				let waitFor = CorePreferences.them.flexiApiTimeOutSeconds
				Log.info("[FlexiApiPushToken] Waiting push with auth token for \(waitFor) ms")
				DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(waitFor)) { [self] in
					if (waitingForFlexiApiTokenViaPush) {
						waitingForFlexiApiTokenViaPush = false
						Log.error("[FlexiApiPushToken] Auth token wasn't received by push in \(waitFor)s")
						onFlexiApiTokenRequestError()
					}
				}
			} else {
				Log.error("[FlexiApiPushToken] Failed to require a push with an auth token: \(String(describing: result))")
				onFlexiApiTokenRequestError()
			}
		} else {
			Log.error("[FlexiApiPushToken] No push configuration object in Core or empty remote token (push allowed ?)")
			onFlexiApiTokenRequestError()
		}
	}
		

}
