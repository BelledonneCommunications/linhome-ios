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
import UIKit
import linphone


class CreatorAssistantView : MainViewContentWithScrollableForm {
	
	func updateField(status: LinphoneAccountCreatorUsernameStatus?, textInput: LTextInput) {
		switch status {
		case LinphoneAccountCreatorUsernameStatusTooShort : textInput.setError(Texts.get("account_creator_username_too_short"))
		case LinphoneAccountCreatorUsernameStatusTooLong : textInput.setError(Texts.get("account_creator_username_too_long"))
		case LinphoneAccountCreatorUsernameStatusInvalidCharacters : textInput.setError(Texts.get("account_creator_username_invalid_characters"))
		case LinphoneAccountCreatorUsernameStatusInvalid : textInput.setError(Texts.get("account_creator_username_invalid"))
		case LinphoneAccountCreatorUsernameStatusOk : textInput.clearError()
		default: break
		}
	}
	
	
	func updateField(status: LinphoneAccountCreatorPasswordStatus?, textInput: LTextInput) {
		switch status {
		case LinphoneAccountCreatorPasswordStatusTooShort : textInput.setError(Texts.get("account_creator_password_too_short"))
		case LinphoneAccountCreatorPasswordStatusTooLong : textInput.setError(Texts.get("account_creator_password_too_long"))
		case LinphoneAccountCreatorPasswordStatusInvalidCharacters : textInput.setError(Texts.get("account_creator_password_invalid_characters"))
		case LinphoneAccountCreatorPasswordStatusMissingCharacters : textInput.setError(Texts.get("account_creator_password_missingchars"))
		case LinphoneAccountCreatorPasswordStatusOk : textInput.clearError()
		default: break
		}
	}
	
	func updateField(status: LinphoneAccountCreatorEmailStatus?, textInput: LTextInput) {
		switch status {
		case LinphoneAccountCreatorEmailStatusMalformed : textInput.setError(Texts.get("account_creator_email_malformed"))
		case LinphoneAccountCreatorEmailStatusInvalidCharacters : textInput.setError(Texts.get("account_creator_email_invalid_characters"))
		case LinphoneAccountCreatorEmailStatusOk : textInput.clearError()
		default: break
		}
	}
	
	func updateField(status: LinphoneAccountCreatorDomainStatus?, textInput: LTextInput) {
		
		switch status {
		case LinphoneAccountCreatorDomainInvalid : textInput.setError(Texts.get("account_creator_domain_invalid"))
		case LinphoneAccountCreatorDomainOk : textInput.clearError()
		default: break
		}
	}
}

