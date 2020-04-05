//
//  FavoritesNewAPIViewController.swift
//  SFSymbolsCollection
//
//  Created by Shinzan Takata on 2020/04/05.
//  Copyright © 2020 shiz. All rights reserved.
//

import UIKit

final class FavoritesNewAPIViewController: UIViewController {
    let tableView: UITableView = {
        UITableView(frame: .zero, style: .grouped)
    }()

    private lazy var deleteButtonItem: UIBarButtonItem = {
        let barButton = UIBarButtonItem(
            image: UIImage(systemName: "trash"), style: .plain,
            target: self, action: #selector(deleteFavorites))
        return barButton
    }()

    private lazy var cancelButtonItem: UIBarButtonItem = {
        let barButton = UIBarButtonItem(
            image: UIImage(systemName: "xmark"), style: .plain,
            target: self, action: #selector(cancelEdit))
        return barButton
    }()

    private var dataSource: FavoriteTableViewDiffableDataSource!
    private let frame: CGRect
    private let store: FavoriteSymbolStore

    init(frame: CGRect, store: FavoriteSymbolStore) {
        self.frame = frame
        self.store = store
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func loadView() {
        super.loadView()
        view = UIView(frame: frame)
        view.backgroundColor = .white
        setupTableView()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        dataSource.reloadData { [weak self] in
            self?.configureNavigationBatButtonItems()
        }
    }

    private func setupTableView() {
        tableView.backgroundColor = .white
        tableView.delegate = self
        tableView.register(
            FavoriteSymbolTableCell.self,
            forCellReuseIdentifier: FavoriteSymbolTableCell.reuseIdentifier)
        tableView.register(
            FavoriteSymbolHeader.self,
            forHeaderFooterViewReuseIdentifier: FavoriteSymbolHeader.reuseIdentifier)
        tableView.allowsMultipleSelectionDuringEditing = true
        tableView.separatorStyle = .none

        view.addSubview(tableView)
        tableView.pinEdgesTo(view)
        dataSource = FavoriteTableViewDiffableDataSource(
            viewController: self, store: store)
    }
}

// MARK: Edit Mode

extension FavoritesNewAPIViewController {
    override func setEditing(_ editing: Bool, animated: Bool) {
        super.setEditing(editing, animated: animated)
        tableView.isEditing = editing
        configureNavigationBatButtonItems()
    }

    private func configureNavigationBatButtonItems() {
        if isEditing {
            navigationItem.rightBarButtonItems = [cancelButtonItem, deleteButtonItem]
        } else if dataSource.sections.count > 0 {
            navigationItem.rightBarButtonItems = nil
            navigationItem.rightBarButtonItem = editButtonItem
        } else {
            navigationItem.rightBarButtonItems = nil
            navigationItem.rightBarButtonItem = nil
        }
    }

    @objc func deleteFavorites() {
        guard let indexPaths = tableView.indexPathsForSelectedRows else {
            return
        }
        dataSource.deleteFavorites(at: indexPaths) { [weak self] _ in
            self?.isEditing.toggle()
        }
    }

    @objc func cancelEdit() {
        setEditing(false, animated: true)
    }
}

extension FavoritesNewAPIViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        guard let header = tableView.dequeueReusableHeaderFooterView(withIdentifier: FavoriteSymbolHeader.reuseIdentifier) as? FavoriteSymbolHeader,
            dataSource.sections.count > section
        else {
            return nil
        }
        let section = dataSource.snapshot().sectionIdentifiers[section]
        header.configure(section.toSFSymbolCategory())
        return header
    }

    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        FavoriteSymbolHeader.height
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        FavoriteSymbolTableCell.height
    }

    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
        .delete
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if !isEditing {
            tableView.deselectRow(at: indexPath, animated: false)
        }
    }
}
