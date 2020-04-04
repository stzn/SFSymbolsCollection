//
//  CategoriesDataSource.swift
//  SFSymbolsCollection
//
//  Created by Shinzan Takata on 2020/03/13.
//  Copyright © 2020 shiz. All rights reserved.
//

import UIKit

final class CategoryCollectionViewDataSource: NSObject, UICollectionViewDataSource {
    private var categories = SFSymbolCategory.loadJSONFile()
    private let store: FavoriteSymbolStore

    init(store: FavoriteSymbolStore) {
        self.store = store
        super.init()
        addNotifications()
    }

    deinit {
        removeNotifications()
    }

    func reloadData() {
        store.get { [weak self] result in
            guard let self = self, let favorites = try? result.get() else {
                return
            }
            self.configureSymbols(from: favorites)
        }
    }

    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return categories.count
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return categories[section].symbols.count
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
        guard categories.count > indexPath.section else {
            return nil
        }
        return categories[indexPath.section]
    }

    func cellItem(at indexPath: IndexPath) -> SFSymbolCategory.Symbol? {
        guard let section = sectionItem(at: indexPath),
            section.symbols.count > indexPath.item else {
                return nil
        }
        return section.symbols[indexPath.item]
    }
}

// MARK: Notification

extension CategoryCollectionViewDataSource {
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

extension CategoryCollectionViewDataSource {
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

