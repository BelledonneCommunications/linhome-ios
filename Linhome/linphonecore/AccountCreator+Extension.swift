//
//  AccountCreator+Extension.swift
//  Linhome
//
//  Created by Christophe Deschamps on 23/06/2020.
//  Copyright © 2020 Belledonne communications. All rights reserved.
//

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
