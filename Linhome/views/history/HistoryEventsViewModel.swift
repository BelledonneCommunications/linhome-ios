import Foundation
import UIKit
import linphonesw

class HistoryEventsViewModel : ViewModel {
	let callLog: CallLog
	let showDate: Bool
	let historyViewModel: HistoryViewModel
	let device: Device?
	let viewMedia = MutableLiveData(false)
	var historyEvent: HistoryEvent?
	
	
	init (callLog: CallLog, showDate: Bool, historyViewModel: HistoryViewModel)  {
		self.callLog = callLog
		self.showDate = showDate
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
		
		let formatter = DateComponentsFormatter()
		formatter.unitsStyle = .positional
		formatter.allowedUnits = [ .hour, .minute, .second ]
		formatter.zeroFormattingBehavior = [ .pad ]
		
		let callTime = formatter.string(from: TimeInterval(callLog.startDate % 84400))!
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
	
	func setViewMedia() {
		viewMedia.value = true
	}
	
	func isNew() -> Bool {
		return callLog.isNew()
	}
	
	
}
