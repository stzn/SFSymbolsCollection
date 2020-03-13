//
//  CategoriesDataSource.swift
//  SFSymbolsCollectionUsingNewAPI
//
//  Created by Shinzan Takata on 2020/03/13.
//  Copyright © 2020 shiz. All rights reserved.
//

import UIKit

final class CategoriesDataSource: NSObject, UICollectionViewDataSource {
    private struct DecodableSFSymbol: Decodable {
        let symbols: [SFSymbolCategory]
    }

    lazy var symbols: [SFSymbolCategory] = {
        let path = Bundle.main.path(forResource: "symbols", ofType: "json")!
        let url = URL(fileURLWithPath: path)
        let data = try! Data(contentsOf: url)
        return try! JSONDecoder().decode(DecodableSFSymbol.self, from: data).symbols
    }()


    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return symbols.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: CategoryCell.reuseIdentifier, for: indexPath) as? CategoryCell else {
                fatalError()
        }
        let symbol = symbols[indexPath.item]
        cell.configure(symbol)
        return cell
    }

    func item(at indexPath: IndexPath) -> SFSymbolCategory? {
        guard symbols.count - 1 < indexPath.item else {
            return nil
        }
        return symbols[indexPath.item]
    }
}
