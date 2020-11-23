//
//  Customisation.swift
//  Linhome

//
//  Created by Christophe Deschamps on 18/06/2020.
//  Copyright © 2020 Belledonne communications. All rights reserved.
//

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
