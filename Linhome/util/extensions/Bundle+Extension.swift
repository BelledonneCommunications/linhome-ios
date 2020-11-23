//
//  Bundle+Extension.swift
//  Linhome
//
//  Created by Christophe Deschamps on 23/06/2020.
//  Copyright © 2020 Belledonne communications. All rights reserved.
//

import Foundation

extension Bundle {
    var releaseVersionNumber: String? {
        return infoDictionary?["CFBundleShortVersionString"] as? String
    }
    var buildVersionNumber: String? {
        return infoDictionary?["CFBundleVersion"] as? String
    }
	
	var appVersion: String {
		return "\(releaseVersionNumber ?? "version")"
	}
	
	func desc() -> String {
		return "\(releaseVersionNumber ?? "") (\(buildVersionNumber ?? ""))"
	}
	
}
