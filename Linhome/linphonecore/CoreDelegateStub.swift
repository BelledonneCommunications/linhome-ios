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


class CoreDelegateStub : CoreDelegate {
	
	var _onCallStateChanged: ((linphonesw.Core, linphonesw.Call, linphonesw.Call.State, String) -> Void)?
	var _onRegistrationStateChanged: ((linphonesw.Core, linphonesw.ProxyConfig, linphonesw.RegistrationState, String) -> Void)?
	var _onGlobalStateChanged: ((linphonesw.Core, linphonesw.GlobalState, String) -> Void)?
	var _onConfiguringStatus: ((linphonesw.Core, linphonesw.ConfiguringState, String) -> Void)?
	var _onQrcodeFound: ((linphonesw.Core, String) -> Void)?
	var _onLogCollectionUploadStateChanged: ((linphonesw.Core, linphonesw.Core.LogCollectionUploadState, String) -> Void)?
	var _onCallLogUpdated: ((linphonesw.Core, CallLog) -> Void)?

	func onCallStateChanged(core: linphonesw.Core, call: linphonesw.Call, state: linphonesw.Call.State, message: String) {_onCallStateChanged.map{$0(core,call,state,message)}}
	func onRegistrationStateChanged(core: linphonesw.Core, proxyConfig: linphonesw.ProxyConfig, state: linphonesw.RegistrationState, message: String) {_onRegistrationStateChanged.map{$0(core,proxyConfig,state,message)}}
	func onGlobalStateChanged(core: linphonesw.Core, state: linphonesw.GlobalState, message: String) {_onGlobalStateChanged.map{$0(core,state,message)}}
	func onConfiguringStatus(core: Core, status: ConfiguringState, message: String) {_onConfiguringStatus.map{$0(core,status,message)}}
	func onQrcodeFound(core: Core, result url: String) {_onQrcodeFound.map{$0(core,url)}}
	func onLogCollectionUploadStateChanged(core: linphonesw.Core, state: linphonesw.Core.LogCollectionUploadState, info: String) {_onLogCollectionUploadStateChanged.map{$0(core,state,info)}}
	func onCallLogUpdated(core: Core, callLog: CallLog) {_onCallLogUpdated.map{$0(core,callLog)}}
	
	init(
		onCallStateChanged:  ((linphonesw.Core, linphonesw.Call, linphonesw.Call.State, String) -> Void)? = nil,
		onRegistrationStateChanged:  ((linphonesw.Core, linphonesw.ProxyConfig, linphonesw.RegistrationState, String) -> Void)? = nil,
		onGlobalStateChanged:  ((linphonesw.Core, linphonesw.GlobalState, String) -> Void)? = nil,
		onConfiguringStatus:  ((linphonesw.Core, linphonesw.ConfiguringState, String) -> Void)? = nil,
		onQrcodeFound:  ((linphonesw.Core, String) -> Void)? = nil,
		onLogCollectionUploadStateChanged:  ((linphonesw.Core, linphonesw.Core.LogCollectionUploadState, String) -> Void)? = nil,
		onCallLogUpdated:  ((linphonesw.Core, CallLog) -> Void)? = nil
	) {
		self._onCallStateChanged = onCallStateChanged
		self._onRegistrationStateChanged = onRegistrationStateChanged
		self._onGlobalStateChanged = onGlobalStateChanged
		self._onConfiguringStatus = onConfiguringStatus
		self._onQrcodeFound = onQrcodeFound
		self._onLogCollectionUploadStateChanged = onLogCollectionUploadStateChanged
		self._onCallLogUpdated = onCallLogUpdated
	}
	
	
}
