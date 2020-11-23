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
import Zip

class Customisation {
	
	static let it = Customisation()
		
	private var themeXml = FileUtil.sharedContainerUrl().path +  "/theme.xml"
	private var textsXml = FileUtil.sharedContainerUrl().path +  "/texts.xml"
	private var deviceTypesXml = FileUtil.sharedContainerUrl().path +  "/device_types.xml"
	private var actionsTypesXml = FileUtil.sharedContainerUrl().path +  "/action_types.xml"
	private var methodTypesXml = FileUtil.sharedContainerUrl().path +  "/method_types.xml"
	
    var themeConfig: Config!
	var textsConfig: Config!
	var deviceTypesConfig: Config!
    var actionTypesConfig: Config!
	var actionsMethodTypesConfig: Config!
	
	init () {

		unzipBranding()
		
		FileUtil.showListOfFilesInSharedDir()

		themeConfig = emptyConfig()
		_ = themeConfig.loadFromXmlFile(filename: themeXml)
		
		textsConfig = emptyConfig()
		_ = textsConfig.loadFromXmlFile(filename: textsXml)
		
		deviceTypesConfig = emptyConfig()
		_ = deviceTypesConfig.loadFromXmlFile(filename: deviceTypesXml)
		
		actionTypesConfig = emptyConfig()
		_ = actionTypesConfig.loadFromXmlFile(filename: actionsTypesXml)
		
		actionsMethodTypesConfig = emptyConfig()
		_ = actionsMethodTypesConfig.loadFromXmlFile(filename: methodTypesXml)
		
	}

	private func unzipBranding() {
		do {
			try Zip.unzipFile(FileUtil.bundleFilePathAsUrl("linhome.zip")!, destination: FileUtil.sharedContainerUrl(), overwrite: true, password: nil, progress: nil)
		} catch {
			print("Extraction of ZIP archive failed with error:\(error)")
		}
	}
	
	private func emptyConfig() -> Config {
		return try!Factory.Instance.createConfigFromString(data: "")
	}
	
}
