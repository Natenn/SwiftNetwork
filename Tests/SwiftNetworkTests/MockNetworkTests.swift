@testable import SwiftNetwork
import XCTest

final class MockNetworkTests: XCTestCase {
    var mockNetwork: MockNetwork!

    override func setUp() {
        super.setUp()
        mockNetwork = MockNetwork()
    }

    override func tearDown() {
        mockNetwork = nil
        super.tearDown()
    }

    func testMockNetworkExecuteSuccess() async throws {
        let expectation = XCTestExpectation()
        let mockData = ["name": "John Doe", "age": 30] as [String: Any]
        let jsonData = try JSONSerialization.data(withJSONObject: mockData)

        let request = Request(endpoint: "test")

        let mockResponse = try JSONDecoder().decode(TestResponseModel.self, from: jsonData)
        mockNetwork.mockResponse = mockResponse

        try await mockNetwork.execute(request, expecting: TestResponseModel.self) { response in
            XCTAssertEqual(response.name, "John Doe")
            XCTAssertEqual(response.age, 30)
            expectation.fulfill()
        } failure: { error in
            XCTFail("Request should not fail: \(error)")
        }

        await fulfillment(of: [expectation], timeout: 2.0)
    }

    func testMockNetworkExecuteFailure() async throws {
        let expectation = XCTestExpectation()
        let request = Request(endpoint: "test")
        mockNetwork.mockResponse = [Int]()

        try await mockNetwork.execute(request, expecting: String.self) { _ in
            XCTFail("Request should fail")
        } failure: { error in
            XCTAssertEqual(error as? SNError, SNError.failedToDecodeJSON)
            expectation.fulfill()
        }

        await fulfillment(of: [expectation], timeout: 2.0)
    }
}
