//
//  Log+Extensions.swift
//  SwiftNetwork
//
//  Created by Naten on 14.09.24.
//

import Foundation

public extension String? {
    var string: String {
        if let self {
            return self
        }
        return "nil"
    }
}

public extension [String: String]? {
    var string: [String: String] {
        if let self {
            return self
        }
        return ["nil": "nil"]
    }
}

public extension URL? {
    var string: String {
        if let self {
            return self.absoluteString
        }
        return "nil"
    }
}
