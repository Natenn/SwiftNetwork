//
//  Config.swift
//  SwiftNetwork
//
//  Created by Naten on 14.09.24.
//

import Foundation

open class Config {
    public nonisolated(unsafe) static let main = Config()
    
    private init() {}
    
    public var baseUrl: String?
    public var needsAuthToken: Bool = false
    public var authToken: String?
    public var version: Version?
}
