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
import UIKit
import linphonesw

class HistoryEventViewModel : ViewModel {
	let callLog: CallLog
	let historyViewModel: HistoryViewModel
	let device: Device?
	var historyEvent: HistoryEvent?
	
	
	init (callLog: CallLog, historyViewModel: HistoryViewModel)  {
		self.callLog = callLog
		self.historyViewModel = historyViewModel
		self.device = DeviceStore.it.findDeviceByAddress(address: callLog.remoteAddress!)
		self.historyEvent = HistoryEventStore.it.findHistoryEventByCallId(callId: callLog.callId)
	}
	
	override func onEnd() {
		historyEvent?.viewedByUser = true
		historyEvent.map { HistoryEventStore.it.persistHistoryEvent(entry: $0) }
	}
	
	
	func callTypeIcon() -> String {
		switch (callLog.status) {
		case Call.Status.Missed: return "icons/missed"
		case Call.Status.Declined, Call.Status.DeclinedElsewhere: return "icons/declined"
		case Call.Status.Aborted, Call.Status.EarlyAborted :return "icons/declined"
		case Call.Status.Success, Call.Status.AcceptedElsewhere : return callLog.dir == Call.Dir.Incoming ? "icons/accepted" : "icons/called"
		}
	}
	
	func callTypeAndDate() -> String {
		
		let date = Date(timeIntervalSince1970: TimeInterval(callLog.startDate))
		let dateFormatter = DateFormatter()
		dateFormatter.dateFormat = "HH:mm::ss"
		let callTime = dateFormatter.string(from: date)
		
		var typeText : String? = nil
		switch (callLog.status) {
		case Call.Status.Missed : typeText = "history_list_call_type_missed"
		case Call.Status.Declined, Call.Status.DeclinedElsewhere : typeText = "history_list_call_type_declined"
		case Call.Status.Aborted, Call.Status.EarlyAborted : typeText = "history_list_call_type_aborted"
		case Call.Status.Success, Call.Status.AcceptedElsewhere : typeText = callLog.dir == Call.Dir.Incoming ? "history_list_call_type_accepted" : "history_list_call_type_called"
		}
		
		return Texts.get(
			"history_list_call_date_type",
			arg1: Texts.get(typeText!),
			arg2: callTime
		)
	}
	
	func toggleSelect() {
		if (historyViewModel.selectedForDeletion.value!.contains(callLog.callId)) {
			historyViewModel.selectedForDeletion.value!.removeAll{callLog.callId == $0}
		}
		else {
			historyViewModel.selectedForDeletion.value!.append(callLog.callId)
		}
		historyViewModel.notifyDeleteSelectionListUpdated()
	}
	
	
	func isNew() -> Bool {
		return callLog.isNew()
	}
	
	
}
