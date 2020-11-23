
import Foundation
import linphonesw
import linphone


class LoginLinhomeAccountViewModel : CreatorAssistantViewModel {
	
	var username: Pair<MutableLiveData<String>, MutableLiveData<Bool>> = Pair(MutableLiveData<String>(), MutableLiveData<Bool>(false))
	var pass1: Pair<MutableLiveData<String>, MutableLiveData<Bool>> = Pair(MutableLiveData<String>(), MutableLiveData<Bool>(false))
	let xmlRpcSession = try!Core.get().createXmlRpcSession(url: CorePreferences.them.xmlRpcServerUrl)
	var loginResult = MutableLiveData<String>()
	var xmlRpcRequest : XmlRpcRequest?
	
	var xmlRpcRequestDelegateStub : XmlRpcRequestDelegateStub? = nil
	
	init() {
		super.init(defaultValuePath: CorePreferences.them.linhomeAccountDefaultValuesPath)
	}
	
	func valid() -> Bool {
		return username.second.value! && pass1.second.value!
	}
	
	func fireLogin() {
		xmlRpcRequest = try!xmlRpcSession.createRequest(returnType: XmlRpcArgType.String, method: "check_authentication")
		xmlRpcRequestDelegateStub = XmlRpcRequestDelegateStub(onResponse:  { (request:XmlRpcRequest) -> Void in
			self.loginResult.value = request.stringResponse
		})
		xmlRpcRequest!.addDelegate(delegate: xmlRpcRequestDelegateStub!)
		xmlRpcRequest!.addStringArg(value: username.first.value!)
		xmlRpcRequest!.addStringArg(value: CorePreferences.them.encryptedPass( user: username.first.value!, clearPass: pass1.first.value!)!)
		xmlRpcRequest!.addStringArg(value: CorePreferences.them.loginDomain!)
		xmlRpcSession.sendRequest(request: xmlRpcRequest!)
	}
	
}




