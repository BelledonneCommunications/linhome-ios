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


class StorageManager {

	static let it = StorageManager()
	
    // UserData File structure
    // devices.xml --> contains the devices descriptions (Linphone config format)
    // snapshots/<device ID>.jpg -> picture for device in device line, one picture per device, snapthots taken at the very first time a call is made with video content
    // recordings/<unique ID>.mkv -> audio/video recording unique ID is different than call ID as it needs to be set before the call is made. Stores in CallLogUserData.
    // recordings/<unique ID>.jpg -> picture for thumbnail when video recording unique ID is different than call ID as it needs to be set before the call is made. Stores in CallLogUserData.

    let devicesXml = FileUtil.sharedContainerUrl().path + "/devices.xml"
    let historyEventsXml = FileUtil.sharedContainerUrl().path + "/history_events.xml"
    let devicesThumnailPath = FileUtil.sharedContainerUrl().path + "/devices/thumbnails/"
    let callsRecordingsDir = FileUtil.sharedContainerUrl().path + "/calls/recordings/"
    let storePrivately = Customisation.it.themeConfig.getBool(section: "arbitrary-values", key: "store_user_data_in_private_storage", defaultValue: true)

    init () {
		FileUtil.ensureDirectoryExists(path: devicesThumnailPath)
		FileUtil.ensureDirectoryExists(path: callsRecordingsDir)
    }

    func getUserDataPath() -> String {
		if (canUseExternalStorage()) {
			return  FileUtil.documentsDirectory().path
		} else {
			return  FileUtil.libraryDirectory().path
		}
    }

    func canUseExternalStorage() -> Bool {
        return !storePrivately
    }
}
