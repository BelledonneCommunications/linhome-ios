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


class AccountCreatorDelegateStub : AccountCreatorDelegate {
	var _onActivateAccount:  ((AccountCreator, AccountCreator.Status, String) -> Void)?
	var _onActivateAlias: ((AccountCreator, AccountCreator.Status, String) -> Void)?
	var _onIsAccountLinked: ((AccountCreator, AccountCreator.Status, String) -> Void)?
	var _onLinkAccount: ((AccountCreator, AccountCreator.Status, String) -> Void)?
	var _onIsAliasUsed: ((AccountCreator, AccountCreator.Status, String) -> Void)?
	var _onIsAccountActivated: ((AccountCreator, AccountCreator.Status, String) -> Void)?
	var _onLoginLinphoneAccount: ((AccountCreator, AccountCreator.Status, String) -> Void)?
	var _onIsAccountExist: ((AccountCreator, AccountCreator.Status, String) -> Void)?
	var _onUpdateAccount: ((AccountCreator, AccountCreator.Status, String) -> Void)?
	var _onRecoverAccount: ((AccountCreator, AccountCreator.Status, String) -> Void)?
	var _onCreateAccount: ((AccountCreator, AccountCreator.Status, String) -> Void)?
	
	
	func onActivateAccount(creator: AccountCreator, status: AccountCreator.Status, response: String) { _onActivateAccount.map{$0(creator, status, response)}}
	func onActivateAlias(creator: AccountCreator, status: AccountCreator.Status, response: String) { _onActivateAlias.map{$0(creator, status, response)}}
	func onIsAccountLinked(creator: AccountCreator, status: AccountCreator.Status, response: String) { _onIsAccountLinked.map{$0(creator, status, response)}}
	func onLinkAccount(creator: AccountCreator, status: AccountCreator.Status, response: String) { _onLinkAccount.map{$0(creator, status, response)}}
	func onIsAliasUsed(creator: AccountCreator, status: AccountCreator.Status, response: String) { _onIsAliasUsed.map{$0(creator, status, response)}}
	func onIsAccountActivated(creator: AccountCreator, status: AccountCreator.Status, response: String) { _onIsAccountActivated.map{$0(creator, status, response)}}
	func onLoginLinphoneAccount(creator: AccountCreator, status: AccountCreator.Status, response: String) { _onLoginLinphoneAccount.map{$0(creator, status, response)}}
	func onIsAccountExist(creator: AccountCreator, status: AccountCreator.Status, response: String) { _onIsAccountExist.map{$0(creator, status, response)}}
	func onUpdateAccount(creator: AccountCreator, status: AccountCreator.Status, response: String) { _onUpdateAccount.map{$0(creator, status, response)}}
	func onRecoverAccount(creator: AccountCreator, status: AccountCreator.Status, response: String) { _onRecoverAccount.map{$0(creator, status, response)}}
	func onCreateAccount(creator: AccountCreator, status: AccountCreator.Status, response: String) { _onCreateAccount.map{$0(creator, status, response)}}
	
	
	init(
		onActivateAccount:  ((AccountCreator, AccountCreator.Status, String) -> Void)? = nil,
		onActivateAlias:  ((AccountCreator, AccountCreator.Status, String) -> Void)? = nil,
		onIsAccountLinked:  ((AccountCreator, AccountCreator.Status, String) -> Void)? = nil,
		onLinkAccount:  ((AccountCreator, AccountCreator.Status, String) -> Void)? = nil,
		onIsAliasUsed:  ((AccountCreator, AccountCreator.Status, String) -> Void)? = nil,
		onIsAccountActivated:  ((AccountCreator, AccountCreator.Status, String) -> Void)? = nil,
		onLoginLinphoneAccount:  ((AccountCreator, AccountCreator.Status, String) -> Void)? = nil,
		onIsAccountExist:  ((AccountCreator, AccountCreator.Status, String) -> Void)? = nil,
		onUpdateAccount:  ((AccountCreator, AccountCreator.Status, String) -> Void)? = nil,
		onRecoverAccount:  ((AccountCreator, AccountCreator.Status, String) -> Void)? = nil,
		onCreateAccount:  ((AccountCreator, AccountCreator.Status, String) -> Void)? = nil
	) {
		self._onActivateAccount = onActivateAccount
		self._onActivateAlias = onActivateAlias
		self._onIsAccountLinked = onIsAccountLinked
		self._onLinkAccount = onLinkAccount
		self._onIsAliasUsed = onIsAliasUsed
		self._onIsAccountActivated = onIsAccountActivated
		self._onLoginLinphoneAccount = onLoginLinphoneAccount
		self._onIsAccountExist = onIsAccountExist
		self._onUpdateAccount = onUpdateAccount
		self._onRecoverAccount = onRecoverAccount
		self._onCreateAccount = onCreateAccount
	}
	
}


