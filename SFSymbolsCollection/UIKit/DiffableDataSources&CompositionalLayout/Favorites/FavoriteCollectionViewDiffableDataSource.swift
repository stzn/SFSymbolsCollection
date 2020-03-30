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

        let group = DispatchGroup()
        let queue = DispatchQueue(label: "queue")
        var error: Error?
        indexPaths.forEach { indexPath in
            group.enter()
            queue.async(group: group) {
                let section = self.sections[indexPath.section]
                guard let symbol = self.itemIdentifier(for: indexPath) else {
                    return
                }
                self.store.delete(section, symbol: symbol) { result in
                    if case .failure(let err) = result {
                        error = err
                    }
                    group.leave()
                }
            }
        }

        group.notify(queue: .main) { [weak self] in
            if let error = error {
                completion(.failure(error))
                return
            }
            self?.reloadData {
                completion(.success(()))
            }
        }
    }
}
