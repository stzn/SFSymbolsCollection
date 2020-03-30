//
//  InMemoryFavoriteSymbolStore.swift
//  SFSymbolsCollection
//
//  Created by Shinzan Takata on 2020/03/28.
//  Copyright © 2020 shiz. All rights reserved.
//

import UIKit

extension NSNotification.Name {
    static let didFavoriteSymbolAdd = NSNotification.Name("didFavoriteSymbolAdd")
    static let didFavoriteSymbolDelete = NSNotification.Name("didFavoriteSymbolDelete")
}

final class InMemoryFavoriteSymbolStore: FavoriteSymbolStore {
    var dictionary: FavoriteSymbols = [:]
    let asyncQueue = DispatchQueue(label: "asyncQueue")

    func save(_ category: FavoriteSymbolKey, symbol: SFSymbolCategory.Symbol, completion: @escaping (Result<Void, Error>) -> Void) {
        asyncQueue.asyncAfter(deadline: .now() + 0.1) {
            self.dictionary[category, default: []].append(symbol)
            NotificationCenter.default.post(name: NSNotification.Name.didFavoriteSymbolAdd, object: symbol)
            completion(.success(()))
        }
    }

    func get(completion: @escaping (Result<FavoriteSymbols, Error>) -> Void) {
        asyncQueue.asyncAfter(deadline: .now() + 0.1) {
            completion(.success(self.dictionary))
        }
    }

    func delete(_ category: FavoriteSymbolKey, symbol: SFSymbolCategory.Symbol, completion: @escaping (Result<Void, Error>) -> Void) {
        asyncQueue.asyncAfter(deadline: .now() + 0.1) {
            if var symbols = self.dictionary[category] {
                symbols.removeAll(where: { $0.name == symbol.name })
                if symbols.count == 0 {
                    self.dictionary[category] = nil
                } else {
                    self.dictionary[category] = symbols
                }
                NotificationCenter.default.post(name: NSNotification.Name.didFavoriteSymbolDelete, object: symbol)
            }
            completion(.success(()))
        }
    }
}

