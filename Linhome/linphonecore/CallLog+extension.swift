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



import UIKit
import linphonesw


extension CallLog {
	
	func getHistoryEvent() -> HistoryEvent {
		if (userData != nil) {
			let historyEvent = Unmanaged<HistoryEvent>.fromOpaque(userData!).takeUnretainedValue()
			if (historyEvent.callId == nil && callId != nil) {
				historyEvent.callId = callId
				HistoryEventStore.it.persistHistoryEvent(entry: historyEvent)
				userData = nil
			}
			return historyEvent
		}
		if let callId = callId, let event = HistoryEventStore.it.findHistoryEventByCallId(callId: callId) {
			return event
		}
		
		
		let historyEvent = HistoryEvent()
		if (callId != nil) {
			historyEvent.callId = callId
			HistoryEventStore.it.persistHistoryEvent(entry: historyEvent)
		}
		return historyEvent
	}
	
	
	func isNew() -> Bool {
		let event = getHistoryEvent()
		return dir == Call.Dir.Incoming && [
			Call.Status.Missed,
			Call.Status.Declined,
			Call.Status.DeclinedElsewhere
			].contains(status) && !event.viewedByUser
	}
}

