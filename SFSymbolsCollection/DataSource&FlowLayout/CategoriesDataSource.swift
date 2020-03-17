//
//  CategoriesDataSource.swift
//  SFSymbolsCollectionUsingNewAPI
//
//  Created by Shinzan Takata on 2020/03/13.
//  Copyright © 2020 shiz. All rights reserved.
//

import UIKit

final class CategoryCollectionViewDataSource: NSObject, UICollectionViewDataSource {
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
        return symbols.count
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return symbols[section].iconNames.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: CategoryCell.reuseIdentifier, for: indexPath) as? CategoryCell else {
                fatalError()
        }
        guard let iconName = cellItem(at: indexPath) else {
            return UICollectionViewCell()
        }
        cell.configure(iconName)
        return cell
    }

    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        guard let header = collectionView.dequeueReusableSupplementaryView(
            ofKind: UICollectionView.elementKindSectionHeader,
            withReuseIdentifier: CategoryHeader.reuseIdentifier, for: indexPath) as? CategoryHeader else {
                fatalError()
        }
        guard let category = sectionItem(at: indexPath) else {
            return UICollectionReusableView()
        }
        header.configure(category)
        return header
    }

    func sectionItem(at indexPath: IndexPath) -> SFSymbolCategory? {
        guard symbols.count > indexPath.section else {
            return nil
        }
        return symbols[indexPath.section]
    }

    func cellItem(at indexPath: IndexPath) -> String? {
        guard let section = sectionItem(at: indexPath),
            section.iconNames.count > indexPath.item else {
                return nil
        }
        return section.iconNames[indexPath.item]
    }
}
