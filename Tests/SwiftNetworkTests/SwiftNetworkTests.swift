//
//  SwiftNetworkTests.swift
//  SwiftNetwork
//
//  Created by Naten on 14.09.24.
//

@testable import SwiftNetwork
import XCTest

class SwiftNetworkTests: XCTestCase {
    var sut: SwiftNetwork!
    var mockURLSession: MockURLSession!

    override func setUp() {
        super.setUp()
        mockURLSession = MockURLSession()
        sut = SwiftNetwork(urlSession: mockURLSession)
    }

    override func tearDown() {
        sut = nil
        mockURLSession = nil
        super.tearDown()
    }

    func testSwiftNetworkExecuteSuccess() async throws {
        let expectation = XCTestExpectation()
        let mockData = TestResponseModel(name: "John Doe", age: 30)
        let jsonData = try JSONEncoder().encode(mockData)
        let mockResponse = HTTPURLResponse(url: URL(string: "https://api.example.com")!, statusCode: 200, httpVersion: nil, headerFields: nil)!

        await mockURLSession.setMockDataTask(data: jsonData, response: mockResponse, error: nil)

        let request = Request(endpoint: "test")

        try await sut.execute(request, expecting: TestResponseModel.self) { response in
            XCTAssertEqual(response.name, "John Doe")
            XCTAssertEqual(response.age, 30)
            expectation.fulfill()
        } failure: { error in
            XCTFail("Request should not fail: \(error)")
        }

        await fulfillment(of: [expectation], timeout: 2.0)
    }

    func testSwiftNetworkExecuteFailure() async throws {
        let expectation = XCTestExpectation()
        let mockError = SNError.failedToGetData

        await mockURLSession.setMockDataTask(data: nil, response: nil, error: mockError)

        let request = Request(endpoint: "test")

        try await sut.execute(request, expecting: String.self) { _ in
            XCTFail("Request should fail")
        } failure: { error in
            XCTAssertEqual(error as? SNError, mockError)
            expectation.fulfill()
        }

        await fulfillment(of: [expectation], timeout: 2.0)
    }

    func testSwiftNetworkInvalidResponse() async throws {
        let expectation = XCTestExpectation()
        let mockData = Data()
        let mockResponse = URLResponse(url: URL(string: "https://api.example.com")!, mimeType: nil, expectedContentLength: 0, textEncodingName: nil)

        await mockURLSession.setMockDataTask(data: mockData, response: mockResponse, error: nil)

        let request = Request(endpoint: "test")

        try await sut.execute(request, expecting: TestResponseModel.self) { _ in
            XCTFail("Request should fail")
        } failure: { error in
            XCTAssertEqual(error as? SNError, SNError.invalidResponse)
            expectation.fulfill()
        }

        await fulfillment(of: [expectation], timeout: 2.0)
    }

    func testSwiftNetworkDecodeFailure() async throws {
        let expectation = XCTestExpectation()
        let invalidJsonData = "Invalid JSON".data(using: .utf8)!
        let mockResponse = HTTPURLResponse(url: URL(string: "https://api.example.com")!, statusCode: 200, httpVersion: nil, headerFields: nil)!

        await mockURLSession.setMockDataTask(data: invalidJsonData, response: mockResponse, error: nil)

        let request = Request(endpoint: "test")

        try await sut.execute(request, expecting: Int.self) { _ in
            XCTFail("Request should fail")
        } failure: { error in
            XCTAssertEqual(error as? SNError, SNError.failedToDecodeJSON)
            expectation.fulfill()
        }

        await fulfillment(of: [expectation], timeout: 2.0)
    }

    func testSwiftNetworkEmptyResponse() async throws {
        let expectation = XCTestExpectation()
        let emptyData = Data()
        let mockResponse = HTTPURLResponse(url: URL(string: "https://api.example.com")!, statusCode: 204, httpVersion: nil, headerFields: nil)!

        await mockURLSession.setMockDataTask(data: emptyData, response: mockResponse, error: nil)

        let request = Request(endpoint: "test")

        try await sut.execute(request, expecting: EmptyResponse.self) { response in
            XCTAssertNotNil(response)
            expectation.fulfill()
        } failure: { error in
            XCTFail("Request should not fail: \(error)")
        }

        await fulfillment(of: [expectation], timeout: 2.0)
    }
}
