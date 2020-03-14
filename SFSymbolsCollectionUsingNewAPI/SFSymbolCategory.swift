//
//  SFSymbol.swift
//  SFSymbolsCollectionUsingNewAPI
//
//  Created by Shinzan Takata on 2020/03/13.
//  Copyright © 2020 shiz. All rights reserved.
//

import Foundation

typealias CategoryName = String
typealias SymbolName = String

struct SFSymbolCategory: Equatable, Decodable, Hashable {
    let categoryIconName: String
    let name: CategoryName
    let iconNames: [SymbolName]

    private struct DecodableSFSymbol: Decodable {
        let symbols: [SFSymbolCategory]
    }

    static func loadJSONFile() -> [SFSymbolCategory] {
        let path = Bundle.main.path(forResource: "symbols", ofType: "json")!
        let url = URL(fileURLWithPath: path)
        let data = try! Data(contentsOf: url)
        return try! JSONDecoder().decode(DecodableSFSymbol.self, from: data).symbols
    }
}


