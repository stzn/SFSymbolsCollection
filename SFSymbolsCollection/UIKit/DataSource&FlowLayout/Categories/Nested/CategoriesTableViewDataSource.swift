//
//  CategoriesTableViewDataSource.swift
//  SFSymbolsCollection
//
//  Created by Shinzan Takata on 2020/04/03.
//  Copyright © 2020 shiz. All rights reserved.
//

import UIKit

final class CategoriesTableViewDataSource: NSObject, UITableViewDataSource {
    var didSelectItem: ((SFSymbolCategory, SFSymbolCategory.Symbol) -> Void)?

    private var categories: [SFSymbolCategory] = []
    private let store: FavoriteSymbolStore

    init(store: FavoriteSymbolStore) {
        self.store = store
        super.init()
    }

    func reloadData(completion: @escaping () -> Void) {
        store.get { [weak self] result in
            guard let self = self, let favorites = try? result.get() else {
                return
            }
            self.configureSymbols(from: favorites)
            DispatchQueue.main.async {
                completion()
            }
        }
    }

    func numberOfSections(in tableView: UITableView) -> Int {
        return categories.count
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: CategoryTableViewCell.identifier, for: indexPath) as? CategoryTableViewCell else {
            return UITableViewCell()
        }

        cell.didSelectItemAt = { [weak self] indexPath in
            guard let self = self, let category = self.sectionItem(at: indexPath),
                let symbol = self.cellItem(at: indexPath) else {
                return
            }
            self.didSelectItem?(category, symbol)
        }
        cell.configure(symbols: categories[indexPath.section].symbols, at: indexPath.section)
        return cell
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

// MARK: Data Configuration

extension CategoriesTableViewDataSource {
    func configureSymbols(from favorites: FavoriteSymbols) {
        categories = SFSymbolCategory.loadJSONFile()
        guard favorites.isEmpty else {
            return
        }
        categories = categories.map { category -> SFSymbolCategory in
            var category = category
            if let index = findMatchIndex(category: category, favorites: favorites) {
                category.symbols[index] = SFSymbolCategory.Symbol(name: category.symbols[index].name, isFavorite: true)
                return category
            } else {
                return category
            }
        }
    }

    private func findMatchIndex(category: SFSymbolCategory, favorites: FavoriteSymbols) -> Int? {
        guard let favorite = findFavoriteSymbol(category: category, favorites: favorites) else {
            return nil
        }
        return findIndex(symbols: category.symbols, favorites: favorite.value)
    }

    private func findFavoriteSymbol(category: SFSymbolCategory, favorites: FavoriteSymbols) -> FavoriteSymbols.Element? {
        favorites.first(where: { $0.key.iconName == category.iconName && $0.key.categoryName == category.name } )
    }

    private func findIndex(symbols: [SFSymbolCategory.Symbol], favorites: [SFSymbolCategory.Symbol]) -> Int? {
        return symbols.firstIndex(where: { symbol in favorites.contains(where: { symbol.name == $0.name }) })
    }
}

