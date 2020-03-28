//
//  SFSymbol.swift
//  SFSymbolsCollection
//
//  Created by Shinzan Takata on 2020/03/13.
//  Copyright © 2020 shiz. All rights reserved.
//

import Foundation

typealias CategoryName = String
typealias SymbolName = String

struct SFSymbolCategory: Equatable, Decodable, Hashable {
    let iconName: String
    let name: CategoryName
    var symbols: [Symbol]

    struct Symbol: Decodable, Equatable, Hashable {
        let name: SymbolName
        var isFavorite: Bool
        init(from decoder: Decoder) throws {
            let container = try decoder.singleValueContainer()
            name = try container.decode(SymbolName.self)
            isFavorite = false
        }

        init(name: SymbolName, isFavorite: Bool) {
            self.name = name
            self.isFavorite = isFavorite
        }
    }

    private struct DecodableSFSymbol: Decodable {
        let categories: [SFSymbolCategory]
    }

    static func loadJSONFile() -> [SFSymbolCategory] {
        let path = Bundle.main.path(forResource: "SFSymbols", ofType: "json")!
        let url = URL(fileURLWithPath: path)
        let data = try! Data(contentsOf: url)
        return try! JSONDecoder().decode(DecodableSFSymbol.self, from: data).categories
    }
}


