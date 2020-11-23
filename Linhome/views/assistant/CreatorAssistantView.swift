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

