//
//  CategoriesNewAPIViewController.swift
//  SFSymbolsCollectionUsingNewAPI
//
//  Created by Shinzan Takata on 2020/03/13.
//  Copyright © 2020 shiz. All rights reserved.
//

import UIKit

final class CategoriesNewAPIViewController: UIViewController {
    private let sectionHeaderElementKind = "section-header-element-kind"

    private let symbols = SFSymbolCategory.loadJSONFile()

    lazy var collectionView: UICollectionView = {
        UICollectionView(frame: .zero,
                         collectionViewLayout: UICollectionViewFlowLayout())
    }()

    var dataSource: UICollectionViewDiffableDataSource<SFSymbolCategory, SFSymbolCategory.Symbol>!

    override func viewDidLoad() {
        super.viewDidLoad()
        setupCollectionView()
    }

    private func setupCollectionView() {
        collectionView.backgroundColor = .white
        collectionView.register(CategoryCell.self,
                                forCellWithReuseIdentifier: CategoryCell.reuseIdentifier)
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
        configureDataSource()
    }

    func configureLayout() -> UICollectionViewCompositionalLayout {
        let size = NSCollectionLayoutSize(widthDimension: .fractionalWidth(0.25), heightDimension: .fractionalHeight(1.0))
        let item = NSCollectionLayoutItem(layoutSize: size)
        let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .fractionalWidth(0.25))
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
        let section = NSCollectionLayoutSection(group: group)

        let headerSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
                                                heightDimension: .estimated(CategoryHeader.height))
        let sectionHeader = NSCollectionLayoutBoundarySupplementaryItem(
            layoutSize: headerSize,
            elementKind: sectionHeaderElementKind, alignment: .top)
        section.boundarySupplementaryItems = [sectionHeader]
        section.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 0, bottom: 8, trailing: 0)
        return UICollectionViewCompositionalLayout(section: section)
    }

    func configureDataSource() {
        dataSource = UICollectionViewDiffableDataSource(collectionView: collectionView) { collectionView, indexPath, symbol -> UICollectionViewCell? in
            guard let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: CategoryCell.reuseIdentifier, for: indexPath) as? CategoryCell else {
                    return nil
            }
            cell.configure(symbol)
            return cell
        }

        dataSource.supplementaryViewProvider = { [weak self] (collectionView, kind, indexPath) -> UICollectionReusableView? in
            guard let self = self,
                let header = collectionView.dequeueReusableSupplementaryView(
                    ofKind: kind,
                    withReuseIdentifier: CategoryHeader.reuseIdentifier, for: indexPath) as? CategoryHeader else {
                        return nil
            }
            guard self.symbols.count > indexPath.section else {
                return nil
            }

            let category = self.symbols[indexPath.section]
            header.configure(category)
            return header
        }

        var initialSnapshot = NSDiffableDataSourceSnapshot<SFSymbolCategory, SFSymbolCategory.Symbol>()
        for symbol in symbols {
            initialSnapshot.appendSections([symbol])
            initialSnapshot.appendItems(symbol.symbols)
        }
        dataSource.apply(initialSnapshot)
    }
}
