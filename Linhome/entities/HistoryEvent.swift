import Foundation

class HistoryEvent {
    var id: String // HistoryEvent for outgoing call must be created before the call is created to set recording path so it can't be the callID
    var callId: String? = nil
    var viewedByUser: Bool = false
	var mediaFileName: String!
	var mediaThumbnailFileName: String!
    var hasVideo: Bool = false

	init () {
		self.id = xDigitsUUID()
		self.mediaFileName = StorageManager.it.callsRecordingsDir +  "\(id).mkv"
		self.mediaThumbnailFileName = StorageManager.it.callsRecordingsDir +  "\(id).jpg"
	}
	
	init(id:String, callId:String, viewedByUser:Bool, mediaFileName:String, mediaThumbnailFileName:String, hasVideo:Bool) {
		self.id = id
		self.callId = callId
		self.viewedByUser = viewedByUser
		self.mediaFileName = mediaFileName
		self.mediaThumbnailFileName = mediaThumbnailFileName
		self.hasVideo = hasVideo
	}
	
	
    func hasMedia() -> Bool {
		return FileUtil.fileExistsAndIsNotEmpty(path: mediaFileName)
    }

    func hasMediaThumbnail() -> Bool {
		return FileUtil.fileExistsAndIsNotEmpty(path: mediaThumbnailFileName)
    }

    func persist() {
		HistoryEventStore.it.persistHistoryEvent(entry: self)
    }


}
