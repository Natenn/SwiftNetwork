// The Swift Programming Language
// https://docs.swift.org/swift-book

import Foundation

open class SwiftNetwork {
    /// Shared singleton instance
    @MainActor public static let shared = SwiftNetwork()

    private init() {}

    /// Public handle to execute API Calls
    /// - Parameters:
    ///   - request: constructed Request with desired options
    ///   - type: return type for Response
    ///   - success: optional block for success
    ///   - failure: optional block for failure
    open func execute<T: Decodable>(
        _ request: Request,
        expecting type: T.Type,
        success: @escaping @Sendable (T) -> Void = { _ in },
        failure: @escaping @Sendable (_ error: Error) -> Void = { _ in },
        deferBlock: @escaping @Sendable () -> Void = {}
    ) {
        let completion: @Sendable (Result<T, Error>) -> Void = { response in
            switch response {
            case let .success(response):
                success(response)
            case let .failure(error):
                print("Error:", error.localizedDescription)
                failure(error)
            }
        }

        executeTask(
            request,
            expecting: type,
            completion: completion,
            deferBlock: deferBlock
        )
    }

    /// private function that executes the API calls
    /// - Parameters:
    ///   - request: given Request with desired parameters
    ///   - type: return type for Response
    ///   - completion: Completion Handler to notify its executor
    private func executeTask<T: Decodable>(
        _ request: Request,
        expecting type: T.Type,
        completion: @escaping @Sendable (Result<T, Error>) -> Void = { _ in },
        deferBlock: @escaping @Sendable () -> Void = {}
    ) {
        guard let urlRequest = request.urlRequest else {
            completion(.failure(SNError.failedToCreateRequest))
            return
        }

        let task = URLSession.shared.dataTask(with: urlRequest) { data, response, error in
            guard let data = data, error == nil else {
                completion(.failure(error ?? SNError.failedToGetData))
                return
            }

            guard let httpResponse = response as? HTTPURLResponse else {
                print("Error: Invalid response")
                return
            }
            print(urlRequest.httpMethod!, urlRequest.url!)
            print("Status Code: \(httpResponse.statusCode)")
            print("Request Headers: \(String(describing: urlRequest.allHTTPHeaderFields))")

            do {
                let response = try JSONDecoder().decode(type.self, from: data)
                completion(.success(response))
            } catch {
                completion(.failure(SNError.failedToDecodeJSON))
            }

            defer {
                deferBlock()
            }

            print("Response:", String(data: data, encoding: .utf8)!, "\n")
        }
        task.resume()
    }
}
