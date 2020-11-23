//
//  Optional+orNil.swift
//  Linhome
//
//  Created by Christophe Deschamps on 05/03/2020.
//  Copyright © 2020 Belledonne communications. All rights reserved.
//

import UIKit

extension Optional {
	var orNil : String {
		if self == nil {
			return "nil"
		}
		if "\(Wrapped.self)" == "String" {
			return "\"\(self!)\""
		}
		return "\(self!)"
	}
}
