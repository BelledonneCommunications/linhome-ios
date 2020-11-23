struct Action {
	
	var type:String?
	var code:String?
	
	func typeName()-> String? {
		guard let trueType = type else {
			return nil
		}
		return ActionTypes.it.typeNameForActionType(typeKey: trueType)
		
	}
	
	func iconName()-> String? {
		guard let trueType = type else {
			return nil
		}
		return ActionTypes.it.iconNameForActionType(typeKey: trueType)
		
	}
	
	func actionText()-> String? {
		guard let trueType = type else {
			return nil
		}
		return ActionTypes.it.typeNameForActionType(typeKey: trueType)
		
	}
	
	func actionTextWithCode()-> String? {
		guard let trueType = type else {
			return nil
		}
		return "\(ActionTypes.it.typeNameForActionType(typeKey: trueType)) - \(code ?? "")"
	}
	
	
}
