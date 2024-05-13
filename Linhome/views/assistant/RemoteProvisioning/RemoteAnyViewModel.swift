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


class RemoteAnyViewModel: FlexiApiPushAccountCreationViewModel {
	
	var url: Pair<MutableLiveData<String>, MutableLiveData<Bool>> = Pair(MutableLiveData<String>(), MutableLiveData<Bool>(false))
	
	var configurationResult = MutableLiveData<ConfiguringState>()
	
	var delegate : CoreDelegateStub? = nil
	
	
	func valid() -> Bool {
		return url.second.value!
	}
	
	init() {
		super.init(defaultValuePath: CorePreferences.them.linhomeAccountDefaultValuesPath)
	}
	
	override func onStart() {
		super.onStart()
		if (delegate == nil) {
			delegate = CoreDelegateStub(
				onConfiguringStatus: { (core, status, message) in
					if (core.provisioningUri == nil || core.provisioningUri?.count == 0) {
						Log.debug("Ignoring core status update as URL is empty. Core could have been restarted by app going in BG then FG (permission check for example)")
						return
					}
					if (status == ConfiguringState.Successful) {
						if (LinhomeAccount.it.pushAccount() != nil) {
							LinhomeAccount.it.linkProxiesWithPushAccount(pushReady: self.pushReady)
						} else {
							self.createPushAccount()
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
			try Core.get().start()
		} catch {
			self.configurationResult.value = ConfiguringState.Failed
			Log.error("Exception caught firing remote provisionning : \(error)")
			
		}
	}
	
}




