//
//  Coin.swift
//  Diff
//
//  Created by mac on 27/03/2023.
//

import Foundation
import Combine

struct Coin: Codable {
    let id: String
    let rank: String
    let symbol: String
    let name: String
    let supply: String
    let maxSupply: String?
    let marketCapUsd: String?
    let volumeUsd24Hr: String?
    let priceUsd: String?
    let changePercent24Hr: String?
    let vwap24Hr: String?
}

// Coin + API
class CoinCapAPIClient {
    private let session: URLSession
    
    init(session: URLSession = URLSession.shared) {
        self.session = session
    }
    
    func fetchCoins(limit: Int) -> AnyPublisher<[Coin], Error> {
        guard let url = URL(string: "https://api.coincap.io/v2/assets") else {
            fatalError("Invalid URL")
        }
        
        let parameters = ["limit": "\(limit)"]
        var urlComponents = URLComponents(url: url, resolvingAgainstBaseURL: false)
        urlComponents?.queryItems = parameters.map { URLQueryItem(name: $0.key, value: $0.value) }
        
        guard let requestUrl = urlComponents?.url else {
            fatalError("Invalid URL Components")
        }
        
        let request = URLRequest(url: requestUrl)
        
        return session.dataTaskPublisher(for: request)
            .map { $0.data }
            .decode(type: CoinCapResponse.self, decoder: JSONDecoder())
            .map { $0.data }
            .eraseToAnyPublisher()
    }
}

struct CoinCapResponse: Codable {
    let data: [Coin]
}
