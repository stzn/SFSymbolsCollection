//
//  NestedCategoryCollectionViewDataSource.swift
//  SFSymbolsCollection
//
//  Created by Shinzan Takata on 2020/04/03.
//  Copyright © 2020 shiz. All rights reserved.
//

import UIKit

final class NestedCategoryCollectionViewDataSource: NSObject, UICollectionViewDataSource {
    private var symbols: [SFSymbolCategory.Symbol]
    
    init(symbols: [SFSymbolCategory.Symbol]) {
        self.symbols = symbols
        super.init()
        addNotifications()
    }

    deinit {
        removeNotifications()
    }

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
        guard let symbol = cellItem(at: indexPath) else {
            return UICollectionViewCell()
        }
        cell.configure(symbol)
        return cell
    }

    func cellItem(at indexPath: IndexPath) -> SFSymbolCategory.Symbol? {
        guard symbols.count > indexPath.item else {
            return nil
        }
        return symbols[indexPath.item]
    }
}

// MARK: Notification

extension NestedCategoryCollectionViewDataSource {
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

extension NestedCategoryCollectionViewDataSource {
    private func configureSymbol(from symbol: SFSymbolCategory.Symbol, isFavorite: Bool) {
        symbols = symbols.map { symbol -> SFSymbolCategory.Symbol in
            var symbol = symbol
            if let index = symbols.firstIndex(where: { $0.name == symbol.name }) {
                symbol = SFSymbolCategory.Symbol(name: symbols[index].name, isFavorite: true)
                return symbol
            } else {
                return symbol
            }
        }
    }
}
