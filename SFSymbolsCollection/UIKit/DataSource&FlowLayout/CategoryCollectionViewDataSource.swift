//
//  CategoriesDataSource.swift
//  SFSymbolsCollection
//
//  Created by Shinzan Takata on 2020/03/13.
//  Copyright © 2020 shiz. All rights reserved.
//

import UIKit

final class CategoryCollectionViewDataSource: NSObject, UICollectionViewDataSource {
    let symbols = SFSymbolCategory.loadJSONFile()

    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return symbols.count
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return symbols[section].symbols.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: CategoryCell.reuseIdentifier, for: indexPath) as? CategoryCell else {
                fatalError()
        }
        guard let symbol = cellItem(at: indexPath) else {
            return UICollectionViewCell()
        }
        cell.configure(symbol)
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

    func cellItem(at indexPath: IndexPath) -> SFSymbolCategory.Symbol? {
        guard let section = sectionItem(at: indexPath),
            section.symbols.count > indexPath.item else {
                return nil
        }
        return section.symbols[indexPath.item]
    }
}
