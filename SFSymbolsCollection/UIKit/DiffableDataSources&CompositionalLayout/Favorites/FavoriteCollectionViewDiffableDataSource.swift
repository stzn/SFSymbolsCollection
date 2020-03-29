//
//  FavoriteCollectionViewDiffableDataSource.swift
//  SFSymbolsCollection
//
//  Created by Shinzan Takata on 2020/03/29.
//  Copyright © 2020 shiz. All rights reserved.
//

import UIKit

final class FavoriteCollectionViewDiffableDataSource: UICollectionViewDiffableDataSource<FavoriteSymbolKey, SFSymbolCategory.Symbol> {

    private let store: FavoriteSymbolStore
    private var symbols: FavoriteSymbols = [:] {
        didSet {
            updateSnapshot()
        }
    }

    private var sections: [FavoriteSymbolKey] {
        symbols.keys.sorted()
    }

    init(collectionView: UICollectionView, store: FavoriteSymbolStore) {
        self.store = store
        super.init(collectionView: collectionView) { collectionView, indexPath, symbol -> UICollectionViewCell? in
            guard let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: SymbolCell.reuseIdentifier, for: indexPath) as? SymbolCell else {
                    return nil
            }
            cell.configure(symbol)
            return cell
        }

        supplementaryViewProvider = { [weak self] (collectionView, kind, indexPath) -> UICollectionReusableView? in
            guard let self = self,
                let header = collectionView.dequeueReusableSupplementaryView(
                    ofKind: kind,
                    withReuseIdentifier: CategoryHeader.reuseIdentifier, for: indexPath) as? CategoryHeader else {
                        return nil
            }
            guard self.sections.count > indexPath.section else {
                return nil
            }

            let section = self.snapshot().sectionIdentifiers[indexPath.section]
            header.configure(SFSymbolCategory(iconName: section.iconName, name: section.categoryName, symbols: []))
            return header
        }

        updateSnapshot()
    }

    private func updateSnapshot() {
        var initialSnapshot = NSDiffableDataSourceSnapshot<FavoriteSymbolKey, SFSymbolCategory.Symbol>()
        for section in sections {
            initialSnapshot.appendSections([section])
            initialSnapshot.appendItems(symbols[section, default: []])
        }
        apply(initialSnapshot)
    }

    func reloadData() {
        store.get { [weak self] result in
            if let symbols = try? result.get() {
                self?.symbols = symbols
            }
        }
    }
}
