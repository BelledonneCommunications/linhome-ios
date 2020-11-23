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
