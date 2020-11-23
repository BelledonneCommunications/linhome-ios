
import Foundation
import linphonesw
import linphone

class CreatorAssistantViewModel : ViewModel {
	
	let accountCreator: AccountCreator

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
    }

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


}
