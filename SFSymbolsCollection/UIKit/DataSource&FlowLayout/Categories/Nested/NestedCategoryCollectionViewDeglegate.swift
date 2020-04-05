//
//  NestedCategoryCollectionViewDeglegate.swift
//  SFSymbolsCollection
//
//  Created by Shinzan Takata on 2020/04/03.
//  Copyright © 2020 shiz. All rights reserved.
//

import UIKit

final class NestedCategoryCollectionViewDeglegate: NSObject, UICollectionViewDelegateFlowLayout {
    var didSelectItemAt: ((IndexPath) -> Void)?

    private let numberOfItemsPerRow: CGFloat
    private let interItemSpacing: CGFloat

    init(numberOfItemsPerRow: CGFloat, interItemSpacing: CGFloat = 0) {
        self.numberOfItemsPerRow = numberOfItemsPerRow
        self.interItemSpacing = interItemSpacing
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let maxWidth = collectionView.bounds.width
        let totalSpacing = interItemSpacing * numberOfItemsPerRow
        let itemWidth = (maxWidth - totalSpacing) / numberOfItemsPerRow

        return CGSize(width: itemWidth, height: itemWidth)
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return interItemSpacing
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return interItemSpacing
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: false)
        didSelectItemAt?(indexPath)
    }
}
