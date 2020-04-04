//
//  CategoryCollectionViewDiffableDataSource.swift
//  SFSymbolsCollection
//
//  Created by Shinzan Takata on 2020/03/29.
//  Copyright © 2020 shiz. All rights reserved.
//

import UIKit

final class CategoryCollectionViewDiffableDataSource: UICollectionViewDiffableDataSource<SFSymbolCategory, SFSymbolCategory.Symbol> {

    private var categories = SFSymbolCategory.loadJSONFile() {
        didSet {
            updateSnapshot()
        }
    }
    private let store: FavoriteSymbolStore

    init(collectionView: UICollectionView, store: FavoriteSymbolStore) {
        self.store = store
        super.init(collectionView: collectionView) { collectionView, indexPath, symbol -> UICollectionViewCell? in
            guard let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: CategoryCell.reuseIdentifier, for: indexPath) as? CategoryCell else {
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
            guard self.categories.count > indexPath.section else {
                return nil
            }

            let category = self.snapshot().sectionIdentifiers[indexPath.section]
            header.configure(category)
            return header
        }

        updateSnapshot()

        addNotifications()
    }

    deinit {
        removeNotifications()
    }

    private func updateSnapshot() {
        var initialSnapshot = NSDiffableDataSourceSnapshot<SFSymbolCategory, SFSymbolCategory.Symbol>()
        for symbol in categories {
            initialSnapshot.appendSections([symbol])
            initialSnapshot.appendItems(symbol.symbols)
        }
        DispatchQueue.main.async {
            self.apply(initialSnapshot, animatingDifferences: false)
        }
    }

    func reloadData() {
        store.get { [weak self] result in
            guard let self = self, let favorites = try? result.get() else {
                return
            }
            self.configureSymbols(from: favorites)
        }
    }
}

// MARK: Notification

extension CategoryCollectionViewDiffableDataSource {
    private func addNotifications() {
        NotificationCenter.default.addObserver(self, selector: #selector(addFavoriteSymbol(_:)), name: .didFavoriteSymbolAdd, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(deleteFavoriteSymbol(_:)), name: .didFavoriteSymbolDelete, object: nil)
    }

    private func removeNotifications() {
        NotificationCenter.default.removeObserver(self)
    }

    @objc func addFavoriteSymbol(_ notification: Notification) {
        guard let symbol = notification.object as? SFSymbolCategory.Symbol else {
            return
        }
        configureSymbol(from: symbol, isFavorite: true)
    }

    @objc func deleteFavoriteSymbol(_ notification: Notification) {
        guard let symbol = notification.object as? SFSymbolCategory.Symbol else {
            return
        }
        configureSymbol(from: symbol, isFavorite: false)
    }
}

// MARK: Data Configuration

extension CategoryCollectionViewDiffableDataSource {
    func configureSymbols(from favorites: FavoriteSymbols) {
        let intersect = categories.compactMap { $0.symbols }
            .filter(favorites.map { $0.value }.contains)
            .flatMap { $0 }
        categories.forEach { category in
            var category = category
            if let index = category.symbols.firstIndex(where: intersect.contains) {
                category.symbols[index] = SFSymbolCategory.Symbol(name: category.symbols[index].name, isFavorite: true)
            }
        }
    }

    private func configureSymbol(from symbol: SFSymbolCategory.Symbol, isFavorite: Bool) {
        categories = categories.map { category -> SFSymbolCategory in
            var category = category

            guard let index = category.symbols.firstIndex(where: { $0.name == symbol.name }) else {
                return category
            }
            category.symbols[index] = SFSymbolCategory.Symbol(name: category.symbols[index].name, isFavorite: isFavorite)
            return category
        }
    }
}

