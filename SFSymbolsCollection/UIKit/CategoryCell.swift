//
//  CategoryCell.swift
//  SFSymbolsCollection
//
//  Created by Shinzan Takata on 2020/03/13.
//  Copyright © 2020 shiz. All rights reserved.
//

import UIKit

final class CategoryCell: UICollectionViewCell {
    static let reuseIdentifier = String(describing: CategoryCell.self)

    private let iconImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.tintColor = .label
        return imageView
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setup() {
        contentView.addSubview(iconImageView)

        iconImageView.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            iconImageView.topAnchor.constraint(equalTo: contentView.topAnchor),
            iconImageView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            iconImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            iconImageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
        ])
    }

    func configure(_ symbol: SFSymbolCategory.Symbol) {
        iconImageView.image = UIImage(systemName: symbol.name)?
            .withRenderingMode(.alwaysTemplate)
    }
}

#if DEBUG
import SwiftUI

extension CategoryCell: UIViewRepresentable {
    func makeUIView(context: Context) -> CategoryCell {
        let cell = CategoryCell()
        cell.configure(.init(name: "mic", isFavorite: false))
        return cell
    }

    func updateUIView(_ uiView: CategoryCell, context: Context) {
    }
}

struct CategoryCellPreview: PreviewProvider {
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
                        .previewLayout(.sizeThatFits)
                        .previewDevice(PreviewDevice(rawValue: name))
                        .previewDisplayName(name)
                        .colorScheme(.light)
                    self.content
                        .previewLayout(.sizeThatFits)
                        .previewDevice(PreviewDevice(rawValue: name))
                        .previewDisplayName(name)
                        .colorScheme(.dark)
                }
            }
        }
    }

    private static var content: some View {
        CategoryCell()
    }
}
#endif
