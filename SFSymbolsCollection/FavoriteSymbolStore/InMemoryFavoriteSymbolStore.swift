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

    func save(_ category: FavoriteSymbolKey, symbol: SFSymbolCategory.Symbol, completion: (Result<Void, Error>) -> Void) {
        dictionary[category, default: []].append(symbol)
        NotificationCenter.default.post(name: NSNotification.Name.didFavoriteSymbolAdd, object: symbol)
        completion(.success(()))
    }

    func get(completion: (Result<FavoriteSymbols, Error>) -> Void) {
        completion(.success(dictionary))
    }

    func delete(_ category: FavoriteSymbolKey, symbol: SFSymbolCategory.Symbol, completion: (Result<Void, Error>) -> Void) {
        if var symbols = dictionary[category] {
            symbols.removeAll(where: { $0.name == symbol.name })
            if symbols.count == 0 {
                dictionary[category] = nil
            } else {
                dictionary[category] = symbols
            }
            NotificationCenter.default.post(name: NSNotification.Name.didFavoriteSymbolDelete, object: symbol)
        }
    }
}

