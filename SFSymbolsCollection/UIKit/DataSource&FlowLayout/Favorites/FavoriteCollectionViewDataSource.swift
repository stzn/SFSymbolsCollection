//
//  FavoriteCollectionViewDataSource.swift
//  SFSymbolsCollection
//
//  Created by Shinzan Takata on 2020/03/28.
//  Copyright © 2020 shiz. All rights reserved.
//

import UIKit

final class FavoriteCollectionViewDataSource: NSObject, UICollectionViewDataSource {
    private let store: FavoriteSymbolStore
    private var symbols: FavoriteSymbols = [:]
    private var sections: [FavoriteSymbolKey] {
        symbols.keys.sorted()
    }

    init(store: FavoriteSymbolStore) {
        self.store = store
        super.init()
        reloadData()
    }

    func reloadData(completion: (() -> Void)? = nil) {
        store.get { [weak self] result in
            if let symbols = try? result.get() {
                self?.symbols = symbols
                completion?()
            }
        }
    }

    func deleteFavorites(indexPaths: [IndexPath], completion: @escaping (Result<Void, Error>) -> Void) {
        indexPaths.forEach {
            guard let section = sectionItem(at: $0), let symbol = cellItem(at: $0) else {
                return
            }
            store.delete(section, symbol: symbol) { result in
                if case .failure(let error) = result {
                    completion(.failure(error))
                    return
                }
            }
        }
        completion(.success(()))
    }

    func numberOfSections(in collectionView: UICollectionView) -> Int {
        sections.count
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        guard sections.count > 0 else {
            return 0
        }
        return symbols[sections[section]]?.count ?? 0
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: SymbolCell.reuseIdentifier, for: indexPath) as? SymbolCell,
            let symbol = cellItem(at: indexPath) else {
                return UICollectionViewCell()
        }
        cell.configure(symbol)
        return cell
    }

    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        guard let header = collectionView.dequeueReusableSupplementaryView(
            ofKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: CategoryHeader.reuseIdentifier, for: indexPath) as? CategoryHeader, sections.count > 0 else {
                return UICollectionReusableView(frame: .zero)
        }
        let section = sections[indexPath.section]
        header.configure(SFSymbolCategory(iconName: section.iconName, name: section.categoryName, symbols: []))
        return header
    }

    func sectionItem(at indexPath: IndexPath) -> FavoriteSymbolKey? {
        guard sections.count > indexPath.section else {
            return nil
        }
        return sections[indexPath.section]
    }

    func cellItem(at indexPath: IndexPath) -> SFSymbolCategory.Symbol? {
        guard let section = sectionItem(at: indexPath),
            let symbols = symbols[section],
            symbols.count > indexPath.item else {
                return nil
        }
        return symbols[indexPath.item]
    }
}
