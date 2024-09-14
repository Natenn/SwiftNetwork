// The Swift Programming Language
// https://docs.swift.org/swift-book

import Combine
import Foundation

public final class SwiftNetwork: Networkable, Sendable {
    public static let shared = SwiftNetwork()

    private init() {}

    public func execute<T: Decodable>(
        _ request: Request,
        expecting type: T.Type,
        success: @escaping @Sendable (T) -> Void = { _ in },
        failure: @escaping @Sendable (_ error: Error) -> Void = { _ in }
    ) async throws {
        do {
            let (data, response) = try await getData(request, expecting: type)
            success(data)
        } catch {
            printError(from: error)
            failure(error)
        }
    }

    private func getData<T: Decodable>(
        _ request: Request,
        expecting type: T.Type
    ) async throws -> (T, HTTPURLResponse) {
        guard let urlRequest = request.urlRequest else {
            throw SNError.failedToCreateRequest
        }

        let (data, urlResponse) = try await URLSession.shared.data(for: urlRequest)

        guard let httpResponse = urlResponse as? HTTPURLResponse else {
            throw SNError.invalidResponse
        }
        printHeaders(from: urlRequest, and: httpResponse)
        printResponse(from: data)

        guard let data = decode(type.self, from: data) else {
            throw SNError.failedToDecodeJSON
        }

        return (data, httpResponse)
    }

    private func decode<T: Decodable>(_ type: T.Type, from data: Data) -> T? {
        do {
            if type == EmptyResponse.self {
                return EmptyResponse(data: data) as? T
            }
            return try JSONDecoder().decode(T.self, from: data)
        } catch {
            return nil
        }
    }

    private func printHeaders(from urlRequest: URLRequest, and httpResponse: HTTPURLResponse) {
        print()
        print(urlRequest.httpMethod.string, urlRequest.url.string)
        print("Status Code: \(httpResponse.statusCode)")
        print("Request Headers: \(urlRequest.allHTTPHeaderFields.string)")
    }

    private func printResponse(from data: Data) {
        print("Response:", String(data: data, encoding: .utf8).string)
    }

    private func printError(from error: Error) {
        print("Error:", error)
    }
}
