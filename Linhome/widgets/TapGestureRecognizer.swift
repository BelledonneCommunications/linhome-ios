//
//  TapgestureRecognizer.swift
//  Linhome
//
//  Created by Christophe Deschamps on 19/06/2020.
//  Copyright © 2020 Belledonne communications. All rights reserved.
//

import UIKit

class TapGestureRecognizer: UITapGestureRecognizer {
    var action : (()->Void)? = nil
}
