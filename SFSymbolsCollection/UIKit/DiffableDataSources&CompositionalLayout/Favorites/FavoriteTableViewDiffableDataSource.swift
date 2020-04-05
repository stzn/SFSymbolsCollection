//
//  FavoriteTableViewDiffableDataSource.swift
//  SFSymbolsCollection
//
//  Created by Shinzan Takata on 2020/04/05.
//  Copyright © 2020 shiz. All rights reserved.
//

import UIKit

final class FavoriteTableViewDiffableDataSource: UITableViewDiffableDataSource<
    FavoriteSymbolKey, SFSymbolCategory.Symbol
>
{
    var sections: [FavoriteSymbolKey] {
        symbols.keys.sorted()
    }

    weak var viewController: UIViewController?

    private var symbols: FavoriteSymbols = [:] {
        didSet {
            updateSnapshot()
        }
    }

    private let store: FavoriteSymbolStore

    init(viewController: FavoritesNewAPIViewController, store: FavoriteSymbolStore) {
        self.viewController = viewController
        self.store = store
        super.init(tableView: viewController.tableView) {
            tableView, indexPath, symbol -> UITableViewCell? in
            guard
                let cell = tableView.dequeueReusableCell(
                    withIdentifier: FavoriteSymbolTableCell.reuseIdentifier, for: indexPath)
                    as? FavoriteSymbolTableCell
            else {
                return nil
            }
            cell.configure(symbol)
            return cell
        }
        updateSnapshot()
    }

    private func updateSnapshot() {
        var initialSnapshot = NSDiffableDataSourceSnapshot<
            FavoriteSymbolKey, SFSymbolCategory.Symbol
        >()
        for section in sections {
            initialSnapshot.appendSections([section])
            initialSnapshot.appendItems(symbols[section, default: []])
        }
        DispatchQueue.main.async {
            self.apply(initialSnapshot, animatingDifferences: false)
        }
    }

    func reloadData(completion: (() -> Void)? = nil) {
        store.get { result in
            if let symbols = try? result.get() {
                self.symbols = symbols
            }
            DispatchQueue.main.async {
                completion?()
            }
        }
    }

    func deleteFavorites(
        at indexPaths: [IndexPath], completion: @escaping (Result<Void, Error>) -> Void
    ) {
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
            guard sections.count > indexPath.section else {
                return
            }
            let section = self.sections[indexPath.section]
            let indexes = indexPaths.filter { $0.section == indexPath.section }
            let symbols = indexes.compactMap(self.itemIdentifier(for:))
            result.merge([section: symbols]) { $1 }
        }
    }

    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }

    override func tableView(
        _ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle,
        forRowAt indexPath: IndexPath
    ) {
        switch editingStyle {
        case .delete:
            deleteFavorites(at: [indexPath]) { [viewController] result in
                if case .failure = result {
                    return
                }
                viewController?.setEditing(false, animated: false)
            }
        default:
            break
        }
    }
}
