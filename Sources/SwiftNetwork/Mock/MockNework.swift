//
//  MockNetwork.swift
//  SwiftNetwork
//
//  Created by Naten on 14.09.24.
//

import Foundation

public final class MockNetwork: Networkable {
    public var mockResponse: Any? = nil
    public var execution: () -> Void = {}

    public init() {}
    
    public func execute<T: Decodable>(
        _: Request,
        expecting _: T.Type,
        success: @escaping @Sendable (T) -> Void = { _ in },
        failure: @escaping @Sendable (_ error: Error) -> Void = { _ in }
    ) async throws {
        guard let response = mockResponse as? T else {
            failure(SNError.failedToDecodeJSON)
            return
        }

        success(response)
        execution()
    }
}
