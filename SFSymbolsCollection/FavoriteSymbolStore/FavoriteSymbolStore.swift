//
//  FavoriteStore.swift
//  SFSymbolsCollection
//
//  Created by Shinzan Takata on 2020/03/27.
//  Copyright © 2020 shiz. All rights reserved.
//

import Foundation

struct FavoriteSymbolKey: Comparable, Hashable {
    let iconName: String
    let categoryName: CategoryName
    static func < (lhs: FavoriteSymbolKey, rhs: FavoriteSymbolKey) -> Bool {
        lhs.categoryName < rhs.categoryName
    }
}

typealias FavoriteSymbols = [FavoriteSymbolKey: [SFSymbolCategory.Symbol]]

protocol FavoriteSymbolStore {
    func delete(_ category: FavoriteSymbolKey, symbol: SFSymbolCategory.Symbol, completion: (Result<Void, Error>) -> Void)
    func save(_ category: FavoriteSymbolKey, symbol: SFSymbolCategory.Symbol, completion: (Result<Void, Error>) -> Void)
    func get(completion: (Result<FavoriteSymbols, Error>) -> Void)
}
