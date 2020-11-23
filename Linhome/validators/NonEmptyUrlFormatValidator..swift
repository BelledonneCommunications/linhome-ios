
import Foundation

class NonEmptyUrlFormatValidator : GenericStringValidator  {
	
	init() {
		super.init("input_invalid_format_uri")
	}
	
	override func validity(s: String) -> ValidityResult {
		if (TextUtils.isEmpty(s)) {
			return ValidityResult(false, Texts.get("input_invalid_empty_field"))
		} else if (!validUrl(s)) {
			return ValidityResult(false, errorText)
		}
		return ValidityResult(true, nil)
	}
	
	func validUrl(_ s:String) -> Bool {
		let regEx = "((https|http|file|ftp|sftp)://)((\\w|-)+)(([.]|[/])((\\w|-)+))+"
		let predicate = NSPredicate(format: "SELF MATCHES %@", argumentArray: [regEx])
		return predicate.evaluate(with: s)
	}
}

