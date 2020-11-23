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



class NonEmptyStringMatcherValidator: GenericStringValidator {
		
		var  textInput: LTextInput
		
		init(textInput: LTextInput, errorTextKey:String) {
			self.textInput = textInput
			super.init(errorTextKey)
		}
		
    override func validity(s: String?) -> ValidityResult {
		if (TextUtils.isEmpty(s)) {
            return ValidityResult(false, Texts.get("input_invalid_empty_field"))
		}
		else if (textInput.liveString?.value != s) {
            return ValidityResult(false, errorText)
		}
        return ValidityResult(true, nil)
    }

}
