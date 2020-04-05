//
//  FavoritesViewController.swift
//  SFSymbolsCollection
//
//  Created by Shinzan Takata on 2020/03/28.
//  Copyright © 2020 shiz. All rights reserved.
//

import UIKit

final class FavoritesViewController: UIViewController {
    private let collectionView: UICollectionView = {
        UICollectionView(frame: .zero,
                         collectionViewLayout: UICollectionViewFlowLayout())
    }()

    private lazy var deleteButtonItem: UIBarButtonItem = {
        let barButton = UIBarButtonItem(image: UIImage(systemName: "trash"), style: .plain,
                                        target: self, action: #selector(deleteFavorites))
        return barButton
    }()

    private lazy var cancelButtonItem: UIBarButtonItem = {
        let barButton = UIBarButtonItem(image: UIImage(systemName: "xmark"), style: .plain,
                                        target: self, action: #selector(cancelEdit))
        return barButton
    }()
    
    private let delegate = FavoriteCollectionViewDelegate()
    private let frame: CGRect
    private let dataSource: FavoriteCollectionViewDataSource

    init(frame: CGRect, store: FavoriteSymbolStore) {
        self.frame = frame
        self.dataSource = FavoriteCollectionViewDataSource(store: store)
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func loadView() {
        super.loadView()
        view = UIView(frame: frame)
        view.backgroundColor = .white
        navigationItem.rightBarButtonItem = editButtonItem
        setupCollectionView()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        dataSource.reloadData { [weak self] in
            self?.collectionView.reloadData()
        }
    }

    private func setupCollectionView() {
        collectionView.backgroundColor = .white
        collectionView.dataSource = dataSource
        collectionView.delegate = delegate
        delegate.didSelectItemAt = setCellSelectedAt

        collectionView.register(FavoriteSymbolCell.self,
                                forCellWithReuseIdentifier: FavoriteSymbolCell.reuseIdentifier)
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
}

// MARK: Edit Mode

extension FavoritesViewController {
    override func setEditing(_ editing: Bool, animated: Bool) {
        super.setEditing(editing, animated: animated)
        if isEditing {
            navigationItem.rightBarButtonItems = [cancelButtonItem, deleteButtonItem]
        } else {
            navigationItem.rightBarButtonItems = nil
            navigationItem.rightBarButtonItem = editButtonItem
        }
        collectionView.allowsMultipleSelection = isEditing
        collectionView.indexPathsForVisibleItems.forEach {
            guard let cell = collectionView.cellForItem(at: $0) as? FavoriteSymbolCell else {
                return
            }
            cell.isEditing = isEditing

            if !isEditing {
                cell.isSelected = false
            }
        }
    }

    private func setCellSelectedAt(_ indexPath: IndexPath) {
        guard let cell = collectionView.cellForItem(at: indexPath) as? FavoriteSymbolCell, isEditing else {
            return
        }
        cell.isSelected.toggle()
    }

    @objc func deleteFavorites() {
        dataSource.deleteFavorites(collectionView: collectionView) { [weak self] result in
            if case .failure = result {
                return
            }
            self?.collectionView.reloadData()
            // if not call, can not get correct indexPaths from indexPathsForVisibleItems
            self?.collectionView.layoutIfNeeded()
            self?.isEditing.toggle()
        }
    }

    @objc func cancelEdit() {
        setEditing(false, animated: true)
    }
}
