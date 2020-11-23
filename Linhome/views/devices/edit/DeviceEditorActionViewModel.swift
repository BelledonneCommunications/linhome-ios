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


class DeviceEditorActionViewModel : ViewModel {
	var owningViewModel: DeviceEditorViewModel
	var displayIndex: Int
    var type = MutableLiveData<Int>(0)
    var code = Pair(MutableLiveData<String>(), MutableLiveData<Bool>(false))
	var actionRow : ActionRow?
	
	init (owningViewModel: DeviceEditorViewModel,displayIndex: Int) {
		self.owningViewModel = owningViewModel
		self.displayIndex = displayIndex
	}

    func valid() -> Bool {
		return (type.value == 0 && (code.first.value == nil || code.first.value!.isEmpty)) || (type.value != 0 && code.second.value!)
    }

    func notEmpty() -> Bool {
        return type.value != 0 && !(code.first.value == nil || code.first.value!.isEmpty)
    }

}
