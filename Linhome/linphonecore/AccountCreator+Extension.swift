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

extension AccountCreator {
	func setUserName(_ s:String) -> LinphoneAccountCreatorUsernameStatus {
		return linphone_account_creator_set_username(getCobject , s)
	}
	func setPassword(_ s:String) -> LinphoneAccountCreatorPasswordStatus {
		return linphone_account_creator_set_password(getCobject , s)
	}
	func setEmail(_ s:String) -> LinphoneAccountCreatorEmailStatus {
		return linphone_account_creator_set_email(getCobject , s)
	}
	func setDomain(_ s:String) -> LinphoneAccountCreatorDomainStatus {
		return linphone_account_creator_set_domain(getCobject , s)
	}
	
}
