//
//  NestedCategoriesViewController.swift
//  SFSymbolsCollection
//
//  Created by Shinzan Takata on 2020/04/03.
//  Copyright © 2020 shiz. All rights reserved.
//

import UIKit

final class NestedCategoriesViewController: UIViewController {
    private let tableView: UITableView = {
        UITableView(frame: .zero, style: .grouped)
    }()

    private var dataSource: CategoriesTableViewDataSource!
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
        view.backgroundColor = .systemBackground
        setupNavigationBar()
        setupTableView()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        dataSource.reloadData { [weak self] in
            self?.tableView.reloadData()
        }
    }

    private func setupNavigationBar() {
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Favorite", style: .plain, target: self, action: #selector(goToFavoriteList))
    }

    @objc func goToFavoriteList() {
        let favoriteVC = FavoritesViewController(frame: view.bounds, store: store)
        navigationController?.pushViewController(favoriteVC, animated: true)
    }

    private func setupTableView() {
        tableView.backgroundColor = .systemBackground
        tableView.register(CategoryTableViewCell.self, forCellReuseIdentifier: CategoryTableViewCell.identifier)
        dataSource = CategoriesTableViewDataSource(store: store)
        tableView.dataSource = dataSource
        tableView.delegate = self
        tableView.separatorStyle = .none
        tableView.tableFooterView = UIView()
        dataSource.didSelectItem = didSelectItem

        view.addSubview(tableView)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.topAnchor.constraint(equalTo: view.topAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
        ])
    }

    func didSelectItem(category: SFSymbolCategory, symbol: SFSymbolCategory.Symbol) {
        let input = SymbolViewController.Input(category: FavoriteSymbolKey(iconName: category.iconName, categoryName: category.name),
                                               symbol: symbol, store: store)
        let symbolVC = SymbolViewController(frame: view.bounds, input: input)
        navigationController?.pushViewController(symbolVC, animated: true)
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return tableView.bounds.width / CategoryTableViewCell.numberOfItemsPerRow
    }
}

extension NestedCategoriesViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        guard let category = dataSource.sectionItem(at: IndexPath(item: 0, section: section)) else {
            return nil
        }
        let header = CategoryHeader()
        header.configure(category)
        return header
    }

    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return CategoryHeader.height
    }
}

