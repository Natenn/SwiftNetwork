//
//  APIConstants.swift
//  SwiftNetwork
//
//  Created by Naten on 20.08.24.
//

import Foundation

public extension Request {
    /// Request Query Items
    typealias Query = [String: AnyHashable]

    /// Request Headers Type
    typealias Headers = [String: String]

    /// Request Body Type
    typealias Body = [String: AnyHashable]
}

// MARK: - Empty Values for each Extension Type

public extension Request.Query {
    static var emptyQuery: Request.Query { return [:] }
}

public extension Request.Headers {
    static var emptyHeaders: Request.Headers { return [:] }
}

public extension Request.Body {
    static var emptyBody: Request.Body { return [:] }
}

// MARK: - SNError

/// API Errors
public enum SNError: Error {
    case failedToCreateRequest
    case failedToGetData
    case failedToDecodeJSON
    case invalidResponse
    case unexpectedError
}

// MARK: - Method

/// Request Method
public enum HTTPMethod: String {
    case get = "GET"
    case post = "POST"
    case put = "PUT"
    case delete = "DELETE"
}

// MARK: - Version

/// API Versions
public enum Version: String {
    case v1
}

// MARK: - RequestProtocol

/// RequestProtocol for API
public enum RequestProtocol: String {
    case http
    case https
}
