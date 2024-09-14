//
//  RequestTests.swift
//  SwiftNetwork
//
//  Created by Naten on 15.09.24.
//

@testable import SwiftNetwork
import XCTest

final class RequestTests: XCTestCase {
    func testRequestConstruction() {
        let endpoint = "users"
        let method = HTTPMethod.post
        let headers = ["Content-Type": "application/json"]
        let query = ["page": "1", "limit": "10"]
        let body = ["name": "John Doe", "email": "john@example.com"]

        let request = Request(
            baseUrl: "api.example.com",
            version: .v1,
            endpoint: endpoint,
            method: method,
            headers: headers,
            query: query,
            body: body
        )

        XCTAssert(request.url?.absoluteString.contains("https://api.example.com/v1/users?") == true)
        XCTAssert(request.url?.absoluteString.contains("page=1") == true)
        XCTAssert(request.url?.absoluteString.contains("limit=10") == true)
        XCTAssert(request.url?.absoluteString.contains("&") == true)
        XCTAssert(request.url?.absoluteString.count == 48)
        XCTAssertEqual(request.urlRequest?.httpMethod, "POST")
        XCTAssertEqual(request.urlRequest?.allHTTPHeaderFields?["Content-Type"], "application/json")

        if let bodyData = request.urlRequest?.httpBody,
           let bodyDict = try? JSONSerialization.jsonObject(with: bodyData) as? [String: String]
        {
            XCTAssertEqual(bodyDict["name"], "John Doe")
            XCTAssertEqual(bodyDict["email"], "john@example.com")
        } else {
            XCTFail("Failed to decode request body")
        }
    }

    func testConfig() {
        Config.main.baseUrl = "api.example.com"
        Config.main.version = .v1
        Config.main.needsAuthToken = true
        Config.main.authToken = "Basic token"

        let request = Request(endpoint: "users")

        XCTAssertEqual(request.url?.absoluteString, "https://api.example.com/v1/users")
        XCTAssertEqual(request.urlRequest?.allHTTPHeaderFields?["Authorization"], "Basic token")
    }
}
