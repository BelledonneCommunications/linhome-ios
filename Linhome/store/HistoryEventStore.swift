import Foundation
import linphonesw

class HistoryEventStore {
	
	static var it = HistoryEventStore()
	
	private var historyEventsConfig: Config
	
	var historyEvents  =   [String: HistoryEvent]() // CallId / History event
	var historyEventsXml = StorageManager.it.historyEventsXml
	
	init () {
		FileUtil.ensureFileExists(path: historyEventsXml)
		historyEventsConfig = try!Factory.Instance.createConfig(path: "") // we want to store in XML, not in rc as there could be some funny names.
		let _ = historyEventsConfig.loadFromXmlFile(filename: historyEventsXml)
		historyEvents = readFromXml()
	}
	
	static func refresh() {
		it = HistoryEventStore()
	}
	
	func readFromXml() -> [String: HistoryEvent]  {
		var result =  [String: HistoryEvent]()
		historyEventsConfig.sectionsNamesList.forEach { it in
			historyEventsConfig.getString(section: it, key: "call_id").map{
				result[$0] = HistoryEvent(id: it,
										  callId: historyEventsConfig.getString(section: it, key: "call_id")!,
										  viewedByUser: historyEventsConfig.getBool(section: it, key: "viewed_by_user", defaultValue: false),
										  mediaFileName: historyEventsConfig.getString(section: it, key: "media_file_name") ?? "",
										  mediaThumbnailFileName: historyEventsConfig.getString(section: it, key: "media_thumbnail_file_name") ?? "",
										  hasVideo: historyEventsConfig.getBool(section: it, key: "has_video", defaultValue: false)
				)
			}
		}
		return result
	}
	
	
	func sync() {
		historyEventsConfig.sectionsNamesList.forEach { it in
			historyEventsConfig.cleanSection(section: it)
		}
		historyEvents.forEach { entry in
			historyEventsConfig.setBool(section: entry.value.id, key: "viewed_by_user", value: entry.value.viewedByUser)
			historyEventsConfig.setString(
				section: entry.value.id,
				key: "media_file_name",
				value: entry.value.mediaFileName
			)
			historyEventsConfig.setString(
				section: entry.value.id,
				key: "media_thumbnail_file_name",
				value: entry.value.mediaThumbnailFileName
			)
			historyEventsConfig.setString(section: entry.value.id, key: "call_id", value: entry.value.callId)
			historyEventsConfig.setBool(section: entry.value.id, key: "has_video", value: entry.value.hasVideo)
		}
		FileUtil.write(string: historyEventsConfig.dumpAsXml(), toPath: historyEventsXml)
	}
	
	
	
	func persistHistoryEvent(entry: HistoryEvent) {
		entry.callId.map { it in
			historyEvents[it] = entry
			sync()
		}
	}
	
	func removeHistoryEvent(entry: HistoryEvent) {
		if (FileUtil.fileExists(path: entry.mediaFileName)) {
			FileUtil.delete(path: entry.mediaFileName)
		}
		
		if (FileUtil.fileExists(path: entry.mediaThumbnailFileName)) {
			FileUtil.delete(path: entry.mediaThumbnailFileName)
		}
		
		historyEvents = historyEvents.filter { $0.key != entry.callId }
		sync()
	}
	
	func removeHistoryEventByCallId(callId: String) {
		if let event = findHistoryEventByCallId(callId: callId) {
			removeHistoryEvent(entry: event)
		}
	}
	
	func findHistoryEventByCallId(callId: String) -> HistoryEvent? {
		return historyEvents[callId]
	}
	
	func markAllAsRead() {
		Core.get().callLogs.forEach { log in
			log.getHistoryEvent().viewedByUser = true			
		}
		for event in historyEvents {
				event.value.viewedByUser = true
		}
		sync()
	}
	
}
