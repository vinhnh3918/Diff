//
//  CoinModel.swift
//  Diff
//
//  Created by mac on 27/03/2023.
//

import Foundation
import Combine

class CoinViewModel {
    private let coinCapClient = CoinCapAPIClient()
    
    var coins: [Coin] = []
    
    func fetchCoins(limit: Int) -> AnyPublisher<[Coin], Error> {
        return coinCapClient.fetchCoins(limit: limit)
            .receive(on: DispatchQueue.main)
            .handleEvents(receiveOutput: { [weak self] coins in
                self?.coins = coins
            })
            .eraseToAnyPublisher()
    }
    
    func numberOfCoins() -> Int {
        return coins.count
    }
    
    func coin(at index: Int) -> Coin? {
        guard index < coins.count else {
            return nil
        }
        return coins[index]
    }
}
