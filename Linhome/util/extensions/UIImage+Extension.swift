//
//  Array+Extension.swift
//  Linhome
//
//  Created by Christophe Deschamps on 30/06/2020.
//  Copyright © 2020 Belledonne communications. All rights reserved.
//

import Foundation
import UIKit

extension UIImage {
    func resized(to size: CGSize) -> UIImage {
        return UIGraphicsImageRenderer(size: size).image { _ in
            draw(in: CGRect(origin: .zero, size: size))
        }
    }
}
