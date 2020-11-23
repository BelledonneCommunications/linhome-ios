

class ActionTypes {
    var spinnerItems =  [SpinnerItem]()
	
	static let it = ActionTypes()
	
	init () {
		   Customisation.it.actionTypesConfig.map{ config in
			   config.sectionsNamesList.forEach{ it in
				   spinnerItems.append(SpinnerItem(textKey: config.getString(section: it,key: "textkey",defaultString: "missing"),
												   iconFile:  config.getString(section: it, key: "icon"),
												   backingKey: it))
			   }
		   }
	   }

    func typeNameForActionType(typeKey: String)-> String {
		return Texts.get(Customisation.it.actionTypesConfig.getString(section: typeKey, key: "textkey",defaultString: ""))
    }

    func iconNameForActionType(typeKey: String)-> String {
        		return Texts.get(Customisation.it.actionTypesConfig.getString(section: typeKey, key: "icon",defaultString: ""))
    }

}
