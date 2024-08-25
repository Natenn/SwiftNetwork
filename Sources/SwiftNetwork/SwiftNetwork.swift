// The Swift Programming Language
// https://docs.swift.org/swift-book

import Combine
import Foundation

// MARK: - SwiftNetwork

open class SwiftNetwork {
    /// Shared singleton instance
    @MainActor public static let shared = SwiftNetwork()
    private var cancellables: Set<AnyCancellable>

    private init() {
        cancellables = Set<AnyCancellable>()
    }

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
            Self.printHeaders(from: urlRequest, and: httpResponse)

            do {
                let response = try JSONDecoder().decode(type.self, from: data)
                completion(.success(response))
            } catch {
                completion(.failure(SNError.failedToDecodeJSON))
            }

            defer {
                deferBlock()
            }

            Self.printResponse(from: data)
        }
        task.resume()
    }

    /// Execute API calls using Future
    /// - Parameters:
    ///   - request: Request
    ///   - type: return type<T> for Response
    /// - Returns: Future<T, Error>
    open func execute<T: Decodable>(_ request: Request, expecting type: T.Type) -> Future<T, Error> {
        Future { promise in
            guard let urlRequest = request.urlRequest else {
                promise(.failure(SNError.failedToCreateRequest))
                return
            }

            URLSession.shared.dataTaskPublisher(for: urlRequest)
                .tryMap { data, response -> Data in
                    guard let httpResponse = response as? HTTPURLResponse else {
                        throw SNError.invalidResponse
                    }
                    Self.printHeaders(from: urlRequest, and: httpResponse)
                    Self.printResponse(from: data)

                    return data
                }
                .decode(type: type.self, decoder: JSONDecoder())
                .receive(on: RunLoop.main)
                .sink(
                    receiveCompletion: { completion in
                        if case let .failure(error) = completion {
                            print("Error:", error.localizedDescription)

                            switch error {
                            case let decodingError as DecodingError:
                                promise(.failure(decodingError))

                            default:
                                promise(.failure(SNError.unexpectedError))
                            }
                        }
                        print("\n")
                    },
                    receiveValue: {
                        promise(.success($0))
                    }
                ).store(in: &self.cancellables)
        }
    }

    private static func printHeaders(from urlRequest: URLRequest, and httpResponse: HTTPURLResponse) {
        print(urlRequest.httpMethod!, urlRequest.url!)
        print("Status Code: \(httpResponse.statusCode)")
        print("Request Headers: \(String(describing: urlRequest.allHTTPHeaderFields))")
    }

    private static func printResponse(from data: Data) {
        print("Response:", String(data: data, encoding: .utf8)!, "\n")
    }

    deinit {
        cancellables.forEach { $0.cancel() }
    }
}

// MARK: - Config

open class Config {
    public nonisolated(unsafe) static let main = Config()

    private init() {}

    public var baseUrl: String?
    public var needsAuthToken: Bool = false
    public var authToken: String?
    public var version: Version?
}
