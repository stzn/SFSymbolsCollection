//
//  CatgoriesViewController.swift
//  SFSymbolsCollection
//
//  Created by Shinzan Takata on 2020/03/13.
//  Copyright © 2020 shiz. All rights reserved.
//

import UIKit

final class CategoriesViewController: UIViewController {
    lazy var collectionView: UICollectionView = {
        UICollectionView(frame: .zero,
                         collectionViewLayout: UICollectionViewFlowLayout())
    }()

    private let dataSource: CategoryCollectionViewDataSource
    private let delegate = CategoryCollectionViewDeglegate(numberOfItemsPerRow: 4, interItemSpacing: 8)
    private let frame: CGRect
    private let store: FavoriteSymbolStore
    init(frame: CGRect, store: FavoriteSymbolStore) {
        self.frame = frame
        self.store = store
        self.dataSource = CategoryCollectionViewDataSource(store: store)
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func loadView() {
        super.loadView()
        view = UIView(frame: frame)
        view.backgroundColor = .white
        setupNavigationBar()
        setupCollectionView()
    }

    private func setupNavigationBar() {
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Favorite", style: .plain, target: self, action: #selector(goToFavoriteList))
    }

    @objc func goToFavoriteList() {
        let favoriteVC = FavoritesViewController(frame: view.bounds, store: store)
        navigationController?.pushViewController(favoriteVC, animated: true)
    }

    private func setupCollectionView() {
        collectionView.backgroundColor = .white
        collectionView.dataSource = dataSource
        collectionView.delegate = delegate
        delegate.didSelectItemAt = didSelectItem
        collectionView.register(CategoryCell.self,
                                forCellWithReuseIdentifier: CategoryCell.reuseIdentifier)
        collectionView.register(CategoryHeader.self,
                                forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
                                withReuseIdentifier: CategoryHeader.reuseIdentifier)

        view.addSubview(collectionView)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            collectionView.topAnchor.constraint(equalTo: view.topAnchor),
            collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
        ])
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        dataSource.reloadData()
        collectionView.reloadData()
    }

    func didSelectItem(at indexPath: IndexPath) {
        guard let category = dataSource.sectionItem(at: indexPath),
            let symbol = dataSource.cellItem(at: indexPath) else {
            return
        }

        let input = SymbolViewController.Input(category: FavoriteSymbolKey(iconName: category.iconName, categoryName: category.name),
                                               symbol: symbol, store: store)
        let symbolVC = SymbolViewController(frame: view.bounds, input: input)
        navigationController?.pushViewController(symbolVC, animated: true)
    }
}
