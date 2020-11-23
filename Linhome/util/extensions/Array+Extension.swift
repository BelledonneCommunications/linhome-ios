//
//  Array+Extension.swift
//  Linhome
//
//  Created by Christophe Deschamps on 30/06/2020.
//  Copyright © 2020 Belledonne communications. All rights reserved.
//

import Foundation


extension Array where Element: Equatable {
    func all(where predicate: (Element) -> Bool) -> [Element]  {
        return self.compactMap { predicate($0) ? $0 : nil }
    }
}
