

class GenericStringValidator  {
	
	var errorTextKey: String
	var errorText:String
	
	init(_ errorTextKey:String) {
		self.errorTextKey = errorTextKey
		self.errorText =  Texts.get(errorTextKey)
	}
	
	func validity(s: String) -> ValidityResult {
		return ValidityResult(false,nil) // Stub
	}
}
