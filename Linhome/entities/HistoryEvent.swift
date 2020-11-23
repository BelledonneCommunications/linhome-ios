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
