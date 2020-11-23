

import Foundation


class ActionsMethodTypes {
    var spinnerItems =  [SpinnerItem]()
	
	static let it = ActionsMethodTypes()


    init () {
		Customisation.it.actionsMethodTypesConfig.map{ config in
			config.sectionsNamesList.forEach{ it in
				spinnerItems.append(SpinnerItem(textKey: config.getString(section: it,key: "textkey",defaultString: "missing"), iconFile: nil, backingKey: it))
			}
		}
    }

}
