//
//  NSRegularExpression+Extension.swift
//  Linhome
//
//  Created by Christophe Deschamps on 23/06/2020.
//  Copyright © 2020 Belledonne communications. All rights reserved.
//

import Foundation



extension NSRegularExpression {
	
	convenience init(_ pattern: String) {
        do {
            try self.init(pattern: pattern)
        } catch {
            preconditionFailure("Illegal regular expression: \(pattern).")
        }
    }
	
    func matches(_ string: String) -> Bool {
        let range = NSRange(location: 0, length: string.utf16.count)
        return firstMatch(in: string, options: [], range: range) != nil
    }
}
