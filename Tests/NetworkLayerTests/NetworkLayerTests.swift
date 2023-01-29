import XCTest
import Combine
@testable import NetworkLayer


struct CryptoRate: Codable {
    let m15: Double
    let last: Double
    let buy: Double
    let sell: Double
    let symbol: String
    
    enum CodingKeys: String, CodingKey {
        case m15 = "15m"
        case last
        case buy
        case sell
        case symbol
    }
}

typealias CurrenciesRates = [String:CryptoRate]

final class NetworkLayerTests: XCTestCase {
    
    var networkLayer: NetworkLayer!
    var cancellables = Set<AnyCancellable>()
    
    override func setUp() {
        networkLayer = NetworkLayer()
    }
    
    override func tearDown() {
        networkLayer = nil
    }

    func testFetchJSONSuccessful() {
        let url = URL(string: "https://www.blockchain.com/ticker")!
        let expectation = self.expectation(description: "Fetch JSON")
        var result: Result<CurrenciesRates, Error>?
        
        networkLayer.fetchJSON(from: url)
            .sink(receiveCompletion: { completion in
                switch completion {
                case .finished:
                    expectation.fulfill()
                case .failure(let error):
                    result = .failure(error)
                }
            }, receiveValue: { value in
                result = .success(value)
            })
            .store(in: &self.cancellables)
        
        waitForExpectations(timeout: 5)
        
        
        switch result {
        case .success(let posts):
            XCTAssertNotNil(posts)
        case .failure(let error):
            XCTFail("Error: \(error)")
        case .none:
            XCTFail("None")
        }

    }
    
    func testFetchJSONFailure() {
        let url = URL(string: "https://www.blockchain.com/picker")!
        
        let expectation = self.expectation(description: "Fetch JSON")
        var result: Result<CurrenciesRates, Error>?
        
        networkLayer.fetchJSON(from: url)
            .sink(receiveCompletion: { completion in
                switch completion {
                case .finished:
                    print("finished")
                case .failure(let error):
                    result = .failure(error)
                    expectation.fulfill()
                }
            }, receiveValue: { value in
                result = .success(value)
            })
            .store(in: &self.cancellables)
        
        waitForExpectations(timeout: 5)
        XCTAssertNotNil(result)
        
        switch result {
        case .success(let posts):
            XCTFail("Error: \(posts)")
        case .failure(let error):
            XCTAssertEqual(error as? ServiceError, ServiceError.statusCodeError(code: 404))
        case .none:
            XCTFail("None")
        }
    }
    
}
