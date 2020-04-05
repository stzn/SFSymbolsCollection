//
//  FavoriteCollectionViewDiffableDataSource.swift
//  SFSymbolsCollection
//
//  Created by Shinzan Takata on 2020/03/29.
//  Copyright © 2020 shiz. All rights reserved.
//

import UIKit

final class FavoriteCollectionViewDiffableDataSource: UICollectionViewDiffableDataSource<FavoriteSymbolKey, SFSymbolCategory.Symbol> {
    private var symbols: FavoriteSymbols = [:] {
        didSet {
            updateSnapshot()
        }
    }

    private var sections: [FavoriteSymbolKey] {
        symbols.keys.sorted()
    }

    private let store: FavoriteSymbolStore

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
            header.configure(section.toSFSymbolCategory())
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
        DispatchQueue.main.async {
            self.apply(initialSnapshot, animatingDifferences: false)
        }
    }

    func reloadData(completion: (()-> Void)? = nil) {
        store.get { result in
            DispatchQueue.main.async { [weak self] in
                if let symbols = try? result.get() {
                    self?.symbols = symbols
                }
                completion?()
            }
        }
    }

    func deleteFavorites(collectionView: UICollectionView, completion: @escaping (Result<Void, Error>) -> Void) {
        guard let indexPaths = collectionView.indexPathsForSelectedItems else {
            return
        }

        let symbols = collectDeleteSymbols(indexPaths: indexPaths)
        store.delete(symbols) { result in
            DispatchQueue.main.async { [weak self] in
                if case .failure = result {
                    completion(result)
                    return
                }
                self?.reloadData {
                    completion(result)
                }
            }
        }
    }

    private func collectDeleteSymbols(indexPaths: [IndexPath]) -> FavoriteSymbols {
        indexPaths.reduce(into: [:]) { result, indexPath in
            let section = self.sections[indexPath.section]
            let indexes = indexPaths.filter { $0.section == indexPath.section }
            let symbols = indexes.compactMap(self.itemIdentifier(for:))
            result.merge([section: symbols]) { $1 }
        }
    }
}
