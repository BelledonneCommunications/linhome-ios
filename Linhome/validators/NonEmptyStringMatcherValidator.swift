

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
