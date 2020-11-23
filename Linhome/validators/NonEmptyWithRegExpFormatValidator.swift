
import Foundation

class NonEmptyWithRegExpFormatValidator : GenericStringValidator {
		
		var  reggExp: NSRegularExpression
	
			init(_ reggExp: String, _ errorTextKey:String ) {
				self.reggExp = NSRegularExpression(reggExp)
				super.init(errorTextKey)
				
			}
		
    override func validity(s: String) -> ValidityResult {
		if (TextUtils.isEmpty(s)) {
            return ValidityResult(false, Texts.get("input_invalid_empty_field"))
		}
		if (!reggExp.matches(s)){
            return ValidityResult(false, errorText)
		}
        return ValidityResult(true, nil)
    }
}
