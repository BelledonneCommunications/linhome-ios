//
//  ValidityResult.swift
//  Linhome
//
//  Created by Christophe Deschamps on 23/06/2020.
//  Copyright © 2020 Belledonne communications. All rights reserved.
//

import UIKit

class ValidityResult: NSObject {
	
	var valid:Bool
	var error:String?
	
	init(_ valid:Bool, _ error:String? ) {
		self.valid = valid
		self.error = error
	}

}
