

class NonEmptyStringValidator : GenericStringValidator {
	
	init() {
		super.init(Texts.get("input_invalid_empty_field"))
	}
	
    override func validity(s: String?)-> ValidityResult {
        return (TextUtils.isEmpty(s)) ? ValidityResult(false, errorText) : ValidityResult(true, nil)
    }
}
