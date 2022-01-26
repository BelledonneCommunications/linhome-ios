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
	
	func isValid(typeKey: String)-> Bool {
		return Customisation.it.actionTypesConfig.getString(section: typeKey, key: "textkey", defaultString: "-") != "-"
	}

}
