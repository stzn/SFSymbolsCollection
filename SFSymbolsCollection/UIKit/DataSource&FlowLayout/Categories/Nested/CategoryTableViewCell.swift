//
//  CategoryTableViewCell.swift
//  SFSymbolsCollection
//
//  Created by Shinzan Takata on 2020/04/03.
//  Copyright © 2020 shiz. All rights reserved.
//

import UIKit

final class CategoryTableViewCell: UITableViewCell {
    static let numberOfItemsPerRow: CGFloat = 4
    static let identifier = String(describing: CategoryTableViewCell.self)

    var didSelectItemAt: ((IndexPath) -> Void)?

    private let collectionView: UICollectionView = {
        UICollectionView(frame: .zero,
                         collectionViewLayout: UICollectionViewFlowLayout())
    }()

    private var dataSource: NestedCategoryCollectionViewDataSource!
    private var delegate: NestedCategoryCollectionViewDeglegate!

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupCollectionView()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupCollectionView() {
        collectionView.backgroundColor = .systemBackground
        if let layout = collectionView.collectionViewLayout as? UICollectionViewFlowLayout {
            layout.scrollDirection = .horizontal
        }
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.register(CategoryCell.self,
                                forCellWithReuseIdentifier: CategoryCell.reuseIdentifier)
        contentView.addSubview(collectionView)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            collectionView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            collectionView.topAnchor.constraint(equalTo: contentView.topAnchor),
            collectionView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
        ])
    }

    func configure(symbols: [SFSymbolCategory.Symbol], at row: Int) {
        dataSource = NestedCategoryCollectionViewDataSource(symbols: symbols)
        collectionView.dataSource = dataSource
        delegate = NestedCategoryCollectionViewDeglegate(
            numberOfItemsPerRow: Self.numberOfItemsPerRow)
        delegate.didSelectItemAt = { [weak self] indexPath in
            self?.didSelectItemAt?(IndexPath(item: indexPath.item, section: row))
        }
        collectionView.delegate = delegate
        collectionView.tag = row
        collectionView.reloadData()
    }
}
