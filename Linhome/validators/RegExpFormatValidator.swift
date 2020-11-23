
import Foundation

class RegExpFormatValidator : GenericStringValidator {
		
		var reggExp: NSRegularExpression
		
		init(_ reggExp: String, _ errorTextKey:String ) {
			self.reggExp = NSRegularExpression(reggExp)
			super.init(errorTextKey)
		}
		
		
    override func validity(s: String) ->  ValidityResult {
			if (!reggExp.matches(s)) {
            	return ValidityResult(false, errorText)
		}
        return ValidityResult(true, nil)
    }

}
