//
//  NetworkLayer.swift
//  CalculatorApp
//
//  Created by Alexey Budynkov on 26.01.2023.
//

import Foundation
import Combine

public enum ServiceError: Error, Equatable {
    case invalidURL
    case noInternetConnection
    case requestTimeout
    case networkError
    case statusCodeError(code: Int?)
}

public class NetworkLayer {
    
    public func fetchJSON<T: Decodable>(from url: URL) -> AnyPublisher<T, Error> {
        return URLSession.shared.dataTaskPublisher(for: url)
            .mapError { error -> ServiceError in
                switch error.code {
                case .notConnectedToInternet:
                    return .noInternetConnection
                case .timedOut:
                    return .requestTimeout
                default:
                    return .networkError
                }
            }
            .tryMap { data, response in
                guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
                    throw ServiceError.statusCodeError(code: (response as? HTTPURLResponse)?.statusCode)
                }
    
                return data
            }
            .decode(type: T.self, decoder: JSONDecoder())
            .eraseToAnyPublisher()
    }
 
    public init(){
        
    }
}
