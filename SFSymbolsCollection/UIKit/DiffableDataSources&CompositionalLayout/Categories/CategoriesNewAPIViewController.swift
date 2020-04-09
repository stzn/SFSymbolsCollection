//
//  CategoriesNewAPIViewController.swift
//  SFSymbolsCollection
//
//  Created by Shinzan Takata on 2020/03/13.
//  Copyright © 2020 shiz. All rights reserved.
//

import UIKit

final class CategoriesNewAPIViewController: UIViewController {
    private let collectionView: UICollectionView = {
        UICollectionView(frame: .zero,
                         collectionViewLayout: UICollectionViewFlowLayout())
    }()

    private let sectionHeaderElementKind = "section-header-element-kind"
    private var dataSource: CategoryCollectionViewDiffableDataSource!
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
        setupCollectionView()
    }
    
    private func setupNavigationBar() {
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Favorite", style: .plain, target: self, action: #selector(goToFavoriteList))
    }

    @objc func goToFavoriteList() {
        let favoriteVC = FavoritesNewAPIViewController(frame: view.bounds, store: store)
        navigationController?.pushViewController(favoriteVC, animated: true)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        dataSource.reloadData()
    }

    private func setupCollectionView() {
        collectionView.backgroundColor = .systemBackground
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
        collectionView.delegate = self
        dataSource = CategoryCollectionViewDiffableDataSource(
            collectionView: collectionView, store: store)
    }

    func configureLayout() -> UICollectionViewCompositionalLayout {
        let size = NSCollectionLayoutSize(widthDimension: .fractionalWidth(0.25), heightDimension: .fractionalHeight(1.0))
        let item = NSCollectionLayoutItem(layoutSize: size)
        let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .fractionalWidth(0.25))
        // Change if want grid style layout
//        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
//        let section = NSCollectionLayoutSection(group: group)

        // behave like nested UICollectionView
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitem: item, count: 4)
        let section = NSCollectionLayoutSection(group: group)
        section.orthogonalScrollingBehavior = .continuous

        let headerSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
                                                heightDimension: .absolute(CategoryHeader.height))
        let sectionHeader = NSCollectionLayoutBoundarySupplementaryItem(
            layoutSize: headerSize,
            elementKind: sectionHeaderElementKind, alignment: .top)
        section.boundarySupplementaryItems = [sectionHeader]
        section.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 0, bottom: 8, trailing: 0)
        return UICollectionViewCompositionalLayout(section: section)
    }
}

// MARK: UICollectionViewDelegate

extension CategoriesNewAPIViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: false)

        let category = dataSource.snapshot().sectionIdentifiers[indexPath.section]
        guard let symbol = dataSource.itemIdentifier(for: indexPath) else {
            return
        }

        let input = SymbolViewController.Input(category: FavoriteSymbolKey(iconName: category.iconName, categoryName: category.name),
                                               symbol: symbol, store: store)
        let symbolVC = SymbolViewController(frame: view.bounds, input: input)
        navigationController?.pushViewController(symbolVC, animated: true)
    }
}

#if DEBUG
import SwiftUI

extension CategoriesNewAPIViewController: UIViewControllerRepresentable {
    func makeUIViewController(context: Context) -> CategoriesNewAPIViewController {
        CategoriesNewAPIViewController(frame: UIScreen.main.bounds, store: InMemoryFavoriteSymbolStore())
    }

    func updateUIViewController(_ uiViewController: CategoriesNewAPIViewController, context: Context) {

    }
}

struct CategoriesNewAPIViewControllerPreviews: PreviewProvider {
    static let devices = [
        "iPhone SE",
        "iPhone 11",
        "iPad Pro (11-inch) (2nd generation)",
    ]

    static var previews: some View {
        Group {
            ForEach(devices, id: \.self) { name in
                Group {
                    self.content
                        .previewDevice(PreviewDevice(rawValue: name))
                        .previewDisplayName(name)
                        .colorScheme(.light)
                    self.content
                        .previewDevice(PreviewDevice(rawValue: name))
                        .previewDisplayName(name)
                        .colorScheme(.dark)
                }
            }
        }
    }

    private static var content: CategoriesNewAPIViewController {
        CategoriesNewAPIViewController(frame: UIScreen.main.bounds,
                                 store: InMemoryFavoriteSymbolStore())
    }
}
#endif
