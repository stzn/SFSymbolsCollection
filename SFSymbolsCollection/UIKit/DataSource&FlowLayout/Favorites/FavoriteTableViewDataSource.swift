//
//  FavoriteTableViewDataSource.swift
//  SFSymbolsCollection
//
//  Created by Shinzan Takata on 2020/04/06.
//  Copyright © 2020 shiz. All rights reserved.
//

import UIKit

final class FavoriteTableViewDataSource: NSObject, UITableViewDataSource {
    var sections: [FavoriteSymbolKey] {
        symbols.keys.sorted()
    }

    weak var viewController: FavoritesViewController?

    private let store: FavoriteSymbolStore
    private var symbols: FavoriteSymbols = [:]

    init(
        viewController: FavoritesViewController,
        store: FavoriteSymbolStore
    ) {
        self.viewController = viewController
        self.store = store
        super.init()
        reloadData()
    }

    func reloadData(completion: (() -> Void)? = nil) {
        store.get { [weak self] result in
            if let symbols = try? result.get() {
                self?.symbols = symbols
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
            let symbols = indexes.compactMap(self.cellItem(at:))
            result.merge([section: symbols]) { $1 }
        }
    }

    func numberOfSections(in tableView: UITableView) -> Int {
        sections.count
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard sections.count > 0 else {
            return 0
        }
        return symbols[sections[section]]?.count ?? 0
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard
            let cell = tableView.dequeueReusableCell(
                withIdentifier: FavoriteSymbolTableCell.reuseIdentifier, for: indexPath)
                as? FavoriteSymbolTableCell,
            let symbol = cellItem(at: indexPath)
        else {
            return UITableViewCell()
        }
        cell.configure(symbol)
        return cell
    }

    func tableView(
        _ tableView: UITableView, viewForSupplementaryElementOfKind kind: String,
        at indexPath: IndexPath
    ) -> UITableViewHeaderFooterView {
        guard
            let header = tableView.dequeueReusableHeaderFooterView(
                withIdentifier: FavoriteSymbolHeader.reuseIdentifier) as? FavoriteSymbolHeader,
            sections.count > 0
        else {
            return UITableViewHeaderFooterView(frame: .zero)
        }
        let section = sections[indexPath.section]
        header.configure(
            SFSymbolCategory(iconName: section.iconName, name: section.categoryName, symbols: []))
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
            symbols.count > indexPath.item
        else {
            return nil
        }
        return symbols[indexPath.item]
    }

    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }

    func tableView(
        _ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle,
        forRowAt indexPath: IndexPath
    ) {
        switch editingStyle {
        case .delete:
            deleteFavorites(at: [indexPath]) { [viewController] result in
                if case .failure = result {
                    return
                }
                viewController?.tableView.reloadData()
                viewController?.setEditing(false, animated: false)
            }
        default:
            break
        }
    }
}
