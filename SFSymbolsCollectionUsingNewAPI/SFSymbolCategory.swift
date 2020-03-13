//
//  SFSymbol.swift
//  SFSymbolsCollectionUsingNewAPI
//
//  Created by Shinzan Takata on 2020/03/13.
//  Copyright © 2020 shiz. All rights reserved.
//

import Foundation

struct SFSymbolCategory: Decodable {
    let categoryIconName: String
    let name: String
    let iconNames: [String]
}
