//
//  Request.swift
//  SwiftNetwork
//
//  Created by Naten on 20.08.24.
//

import Foundation

/// Configurable URL Request
open class Request {
    private let requestProtocol: RequestProtocol

    private let baseUrl: String?

    private let version: Version?

    private let endpoint: String

    private let method: Method

    private let pathExtension: String

    private let headers: Headers

    private let needsAuthToken: Bool

    private let query: Query

    private let body: Body

    /// Configurable URL Request
    /// - Parameters:
    ///   - requestProtocol: Request Protocol, http or https (default value is https)
    ///   - baseUrl: Request Base Url
    ///   - version: version of endpoint, default value is v1
    ///   - endpoint: Required parameter, String
    ///   - method: REST request method, default is GET
    ///   - headers: Request headers, is empty by default
    ///   - query: Request query parameters, is empty by default
    ///   - body: Request body, is empty by default
    ///   - needsAuthToken: Boolean that determines whether request needs AuthToken or not
    ///   - hasPathParameter: Boolean that determines whether Path has additional parameters passed through query
    public init(
        requestProtocol: RequestProtocol = .https,
        baseUrl: String? = Config.main.baseUrl,
        version: Version? = Config.main.version,
        endpoint: String,
        method: Method = .get,
        pathExtension: String = "",
        headers: Headers = .emptyHeaders,
        needsAuthToken: Bool = true,
        query: Query = .emptyQuery,
        body: Body = .emptyBody
    ) {
        self.requestProtocol = requestProtocol
        self.baseUrl = baseUrl
        self.version = version
        self.endpoint = endpoint
        self.method = method
        self.pathExtension = pathExtension
        self.headers = headers
        self.needsAuthToken = needsAuthToken
        self.query = query
        self.body = body
    }

    /// Constructs API URL with parameters from init()
    private var constructedUrl: String {
        /// Base URL
        var url = "\(requestProtocol)://"

        if let baseUrl {
            url.append("\(baseUrl)/")
        }

        /// API Version
        if version?.rawValue != nil {
            url += "\(version!.rawValue)/"
        }

        /// API Endpoint
        url += "\(endpoint)"

        /// Additional path after endpoint
        if !pathExtension.isEmpty {
            url += "/\(pathExtension)"
        }

        /// Query Parameters
        if !query.isEmpty {
            url += "?"

            let queryItems = query.compactMap {
                "\($0.key)=\($0.value)"
            }.joined(separator: "&")

            url += queryItems
        }

        return url
    }

    /// Publicly accessible URL
    public var url: URL? {
        return URL(string: constructedUrl)
    }

    /// Constructs URLRequest with URL, Headers && Body
    public var urlRequest: URLRequest? {
        /// Construction of URL
        guard let url = URL(string: constructedUrl) else {
            return nil
        }
        var request = URLRequest(url: url)

        /// Request Method defined
        request.httpMethod = method.rawValue

        /// Add auth token to headers unless instructed otherwise in case of authorisation itself
        if let authToken = Config.main.authToken, needsAuthToken {
            request.setValue(authToken, forHTTPHeaderField: "Authorization")
        }

        /// Setting Request Headers
        if !headers.isEmpty {
            headers.forEach {
                request.setValue($1, forHTTPHeaderField: $0)
            }
        }

        /// Setting Request Body
        if !body.isEmpty {
            request.httpBody = try? JSONSerialization.data(withJSONObject: body)
        }

        return request
    }
}
