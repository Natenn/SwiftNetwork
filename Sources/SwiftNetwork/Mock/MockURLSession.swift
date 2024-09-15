//
//  MockURLSession.swift
//  SwiftNetwork
//
//  Created by Naten on 14.09.24.
//

import Foundation

// MARK: - URLSessionProtocol

public protocol URLSessionProtocol: Sendable {
    func data(for request: URLRequest) async throws -> (Data, URLResponse)
}

// MARK: - URLSession + URLSessionProtocol

extension URLSession: URLSessionProtocol {}

// MARK: - MockURLSession

actor MockURLSession: URLSessionProtocol {
    var mockDataTask: (Data?, URLResponse?, Error?)

    func setMockDataTask(data: Data?, response: URLResponse?, error: Error?) {
        mockDataTask = (data, response, error)
    }

    func data(for _: URLRequest) async throws -> (Data, URLResponse) {
        if let error = mockDataTask.2 {
            throw error
        }
        guard let data = mockDataTask.0, let response = mockDataTask.1 else {
            throw SNError.invalidResponse
        }
        return (data, response)
    }
}
