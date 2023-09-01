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



import Foundation
import linphonesw

class HistoryViewModel : ViewModel {
	var history  = MutableLiveData(Core.get().callLogsWithNonEmptyCallId())
	var historySplit = MutableLiveData([Int: [CallLog]]())
	let editing = MutableLiveData(false)
	let selectedForDeletion =  MutableLiveData([String]())
	var coreListener : CoreDelegateStub?
	
	override init () {
		super.init()
		coreListener = CoreDelegateStub(onCallLogUpdated: { (core, callLog) in
				self.history.value = Core.get().callLogsWithNonEmptyCallId()
		})
		history.readCurrentAndObserve { (history) in
			self.historySplit.value!.removeAll()
			self.history.value!.reversed().forEach{ (callLog) in
				let day = Int(callLog.startDate/86400)
				if (self.historySplit.value![day] == nil) {
					self.historySplit.value![day] = []
				}
				self.historySplit.value![day]!.append(callLog)
			}
		}
	}
	
	override func onStart() {
		super.onStart()
		coreListener.map{Core.get().addDelegate(delegate:$0)}
	}
	
	override func onEnd() {
		Core.get().removeDelegate(delegate: coreListener!)
	}
	
	func toggleSelectAllForDeletion() {
		if (selectedForDeletion.value!.count == history.value!.count) {
			selectedForDeletion.value!.removeAll()
		} else {
			selectedForDeletion.value!.removeAll()
			history.value!.forEach { it in
				selectedForDeletion.value!.append(it.callId)
			}
		}
		notifyDeleteSelectionListUpdated()
	}
	
	func notifyDeleteSelectionListUpdated() {
		selectedForDeletion.notifyValue()
	}
	
	func deleteSelection() {
		selectedForDeletion.value!.forEach { callId in
			HistoryEventStore.it.removeHistoryEventByCallId(callId: callId)
			Core.get().workAroundFindCallLogFromCallId(callId: callId).map { log in
				Core.get().removeCallLog(callLog: log)
			}
			history.value = Core.get().callLogsWithNonEmptyCallId()
		}
	}
	
	func markEventsAsRead() {
		history.value?.forEach { event in
			event.getHistoryEvent().viewedByUser = true
			event.getHistoryEvent().persist()
		}
	}
	
	
	func refresh() { // Could happen it log is updatesd by extensions - callback not called
		self.history.value = Core.get().callLogsWithNonEmptyCallId()
	}

}
