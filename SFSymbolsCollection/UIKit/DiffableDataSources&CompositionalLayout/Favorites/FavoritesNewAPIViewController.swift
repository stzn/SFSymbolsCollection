//
//  FavoritesNewAPIViewController.swift
//  SFSymbolsCollection
//
//  Created by Shinzan Takata on 2020/03/29.
//  Copyright © 2020 shiz. All rights reserved.
//

import UIKit

final class FavoritesNewAPIViewController: UIViewController {
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

    private let sectionHeaderElementKind = "section-header-element-kind"
    private var categories = SFSymbolCategory.loadJSONFile()
    private var dataSource: FavoriteCollectionViewDiffableDataSource!
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
        navigationItem.rightBarButtonItem = editButtonItem
        setupCollectionView()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        dataSource.reloadData()
    }

    private func setupCollectionView() {
        collectionView.backgroundColor = .white
        collectionView.delegate = self
        collectionView.register(FavoriteSymbolCell.self,
                                forCellWithReuseIdentifier: FavoriteSymbolCell.reuseIdentifier)
        collectionView.register(CategoryHeader.self,
                                forSupplementaryViewOfKind: sectionHeaderElementKind,
                                withReuseIdentifier: CategoryHeader.reuseIdentifier)

        view.addSubview(collectionView)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            collectionView.topAnchor.constraint(equalTo: view.topAnchor),
            collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
        ])

        collectionView.collectionViewLayout = configureLayout()
        dataSource = FavoriteCollectionViewDiffableDataSource(
            collectionView: collectionView, store: store)
    }
}

// MARK: Edit Mode

extension FavoritesNewAPIViewController {
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

    @objc func deleteFavorites() {
        dataSource.deleteFavorites(collectionView: collectionView) { [weak self] _ in
            self?.isEditing.toggle()
        }
    }

    @objc func cancelEdit() {
        setEditing(false, animated: true)
    }
}

// MARK: Layout

extension FavoritesNewAPIViewController {
    func configureLayout() -> UICollectionViewCompositionalLayout {
        let size = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .absolute(80))
        let item = NSCollectionLayoutItem(layoutSize: size)
        let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .absolute(80))
        let group = NSCollectionLayoutGroup.vertical(layoutSize: groupSize, subitems: [item])
        let section = NSCollectionLayoutSection(group: group)

        let headerSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
                                                heightDimension: .absolute(CategoryHeader.height))
        let sectionHeader = NSCollectionLayoutBoundarySupplementaryItem(
            layoutSize: headerSize,
            elementKind: sectionHeaderElementKind, alignment: .top)
        section.boundarySupplementaryItems = [sectionHeader]
        section.interGroupSpacing = 10
        section.contentInsets = NSDirectionalEdgeInsets(top: 8, leading: 0, bottom: 8, trailing: 0)
        return UICollectionViewCompositionalLayout(section: section)
    }
}

// MARK: UICollectionViewDelegate

extension FavoritesNewAPIViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let cell = collectionView.cellForItem(at: indexPath) as? FavoriteSymbolCell, isEditing else {
            return
        }
        cell.isSelected.toggle()
    }
}

