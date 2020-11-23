//
//  StringUtil.swift
//  Linhome
//
//  Created by Christophe Deschamps on 26/06/2020.
//  Copyright © 2020 Belledonne communications. All rights reserved.
//

import Foundation

func xDigitsUUID(count: Int = 10) -> String {
	return String(NSUUID().uuidString.lowercased().prefix(count))
}
