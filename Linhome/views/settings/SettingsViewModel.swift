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


import linphonesw

class SettingsViewModel : ViewModel {
	
	var delegate : CoreDelegateStub? = nil
	
	var audioCodecs : [CodecDescriptor]? = nil
	var videCodecs : [CodecDescriptor]? = nil

	let enableIpv6 = MutableLiveData(Core.get().ipv6Enabled)
	let latestSnapshotShown = MutableLiveData(CorePreferences.them.showLatestSnapshot)


    // Logs
    let enableDebugLogs = MutableLiveData(CorePreferences.them.debugLog)
    let logUploadResult = MutableLiveData<Pair<Core.LogCollectionUploadState, String>>()
	

    // Media Encryption
    var encryptionIndex = MutableLiveData<Int>()
    var encryptionLabels = [String]()
    var encryptionValues = [MediaEncryption]()

	
    // Show latest snapshot in device
    let showLatestSnapshot = MutableLiveData(CorePreferences.them.showLatestSnapshot)

	
	override init() {
		super.init()
		enableIpv6.observe { (enable) in
			Core.get().ipv6Enabled = enable!
		}
		encryptionIndex.observe { (position) in
			try?Core.get().setMediaencryption(newValue: self.encryptionValues[position!])
		}
		enableDebugLogs.observe { (enable) in
			CorePreferences.them.debugLog = enable!
		}
		showLatestSnapshot.observe { (enable) in
			CorePreferences.them.showLatestSnapshot = enable!
		}
		audioCodecs = initCodecsList(payloads: Core.get().audioPayloadTypes, showRate: true)
		videCodecs = initCodecsList(payloads: Core.get().videoPayloadTypes, showRate: false)
		delegate = CoreDelegateStub(onLogCollectionUploadStateChanged: { (lc, state, url) in
			self.logUploadResult.value = Pair(state, url)
		})
		initEncryptionList()
	}
		
    private func initCodecsList(
        payloads: [PayloadType],
        showRate: Bool = false) ->  [CodecDescriptor] {
		var codecSet = [CodecDescriptor]()
		payloads.forEach { payload in
			let codec = CodecDescriptor(title: payload.mimeType, rate: showRate ? "\(payload.clockRate) Hz" : nil, liveState: MutableLiveData<Bool>(payload.enabled()))
			codec.liveState.observe { (enable) in
				Log.info("Attempt set payload \(payload.mimeType) enabled to : \(String(describing: enable)) result is \(payload.enable(enabled: enable!))")
			}
			codecSet.append(codec)
		}
		return codecSet
    }

	private func initEncryptionList() {
		  encryptionLabels.append(Texts.get("none"))
		encryptionValues.append(MediaEncryption.None)

		if (Core.get().mediaEncryptionSupported(menc: MediaEncryption.SRTP)) {
			  encryptionLabels.append("SRTP")
			  encryptionValues.append(MediaEncryption.SRTP)
		  }
		encryptionIndex.value = encryptionValues.firstIndex(of: Core.get().mediaEncryption)
	  }
	
	
	func clearLogs() {
		Core.resetLogCollection()
	}
	
	func sendLogs() {
		Core.get().uploadLogCollection()
	}
	

	override func onStart() {
		super.onStart()
		delegate.map{Core.get().addDelegate(delegate:$0)}
	}
	
	override func onEnd() {
		delegate.map{Core.get().removeDelegate(delegate:$0)}
		super.onEnd()
	}


}
