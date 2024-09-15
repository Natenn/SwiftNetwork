//
//  Networkable.swift
//  SwiftNetwork
//
//  Created by Naten on 14.09.24.
//

import Foundation

public protocol Networkable {
    func execute<T: Decodable>(
        _ request: Request,
        expecting type: T.Type,
        success: @escaping @Sendable (T) -> Void,
        failure: @escaping @Sendable (_ error: Error) -> Void
    ) async throws
}
