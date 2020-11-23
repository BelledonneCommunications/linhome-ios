
import Foundation
import linphonesw
import linphone


class RemoteAnyViewModel: ViewModel {
	
	var url: Pair<MutableLiveData<String>, MutableLiveData<Bool>> = Pair(MutableLiveData<String>(), MutableLiveData<Bool>(false))
	
	var configurationResult = MutableLiveData<ConfiguringState>()
	let pushReady = MutableLiveData<Bool>()
	
	var delegate : CoreDelegateStub? = nil
	
	
	override init() {
	}
	
	func valid() -> Bool {
		return url.second.value!
	}
	
	override func onStart() {
		super.onStart()
		if (delegate == nil) {
			delegate = CoreDelegateStub(
				onConfiguringStatus: { (core, status, message) in
					if (core.provisioningUri == nil || core.provisioningUri.count == 0) {
						Log.debug("Ignoring core status update as URL is empty. Core could have been restarted by app going in BG then FG (permission check for example)")
						return
					}
					if (status == ConfiguringState.Successful) {
						if (Account.it.pushGateway() != nil) {
							Account.it.linkProxiesWithPushGateway(pushReady: self.pushReady)
						} else {
							Account.it.createPushGateway(pushReady: self.pushReady)
						}
					}
					self.configurationResult.value = status
			},
				onQrcodeFound: { (core, qr) in
					DispatchQueue.main.async {
						Core.get().qrcodeVideoPreviewEnabled = false
						Core.get().videoPreviewEnabled = false
						self.url.first.value = qr
						self.startRemoteProvisionning()
					}
					
			})
		}
		delegate.map{Core.get().addDelegate(delegate:$0)}
	}
	
	override func onEnd() {
		delegate.map{Core.get().removeDelegate(delegate:$0)}
		super.onEnd()
	}
	
	func startRemoteProvisionning() {
		do {
			try Core.get().setProvisioninguri(newValue: url.first.value!)
			Core.get().stop()
			try Core.get().extendedStart()
		} catch {
			self.configurationResult.value = ConfiguringState.Failed
			Log.error("Exception caught firing remote provisionning : \(error)")
			
		}
	}
	
}




