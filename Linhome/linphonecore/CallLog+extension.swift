//
//  CoreManager.swift
//  Linhome
//
//  Created by Christophe Deschamps on 24/02/2020.
//  Copyright © 2020 Belledonne communications. All rights reserved.
//


// Core Extension provides a set of utilies to manage automatically a LinphoneCore no matter if it is from App or an extension.
// It is based on a singleton pattern and adds.

import UIKit
import linphonesw


extension CallLog {
	
	func getHistoryEvent() -> HistoryEvent {
		if (userData != nil) {
			let historyEvent = Unmanaged<HistoryEvent>.fromOpaque(userData!).takeUnretainedValue()
			if (historyEvent.callId == nil && !callId.isEmpty) {
				historyEvent.callId = callId
				HistoryEventStore.it.persistHistoryEvent(entry: historyEvent)
				userData = nil
			}
			return historyEvent
		}
		if let event = HistoryEventStore.it.findHistoryEventByCallId(callId: callId) {
			return event
		}
		
		
		let historyEvent = HistoryEvent()
		if (!callId.isEmpty) {
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

