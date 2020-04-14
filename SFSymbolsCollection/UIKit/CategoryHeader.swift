//
//  CategoryHeader.swift
//  SFSymbolsCollection
//
//  Created by Shinzan Takata on 2020/03/13.
//  Copyright © 2020 shiz. All rights reserved.
//

import UIKit

final class CategoryHeader: UICollectionReusableView {
    static let height: CGFloat = 80
    static let reuseIdentifier = String(describing: CategoryHeader.self)

    private let iconImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.tintColor = .label
        return imageView
    }()

    private let nameLabel: UILabel = {
        let label = UILabel()
        label.textColor = .label
        label.font = .preferredFont(forTextStyle: .largeTitle)
        label.adjustsFontForContentSizeCategory = true
        label.numberOfLines = 0
        return label
    }()

    private let bottomSeparator: UIView = {
        let view = UIView()
        view.backgroundColor = .systemGray
        view.setContentHuggingPriority(.defaultHigh + 1, for: .vertical)
        return view
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setup() {
        addSubview(iconImageView)
        addSubview(nameLabel)
        addSubview(bottomSeparator)

        iconImageView.translatesAutoresizingMaskIntoConstraints = false
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        bottomSeparator.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            iconImageView.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 8),
            iconImageView.trailingAnchor.constraint(equalTo: nameLabel.leadingAnchor, constant: -8),
            iconImageView.centerYAnchor.constraint(equalTo: self.centerYAnchor),
            iconImageView.heightAnchor.constraint(equalToConstant: 44),
            iconImageView.widthAnchor.constraint(equalTo: iconImageView.heightAnchor),

            nameLabel.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -8),
            nameLabel.centerYAnchor.constraint(equalTo: self.centerYAnchor),

            bottomSeparator.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 8),
            bottomSeparator.bottomAnchor.constraint(equalTo: self.bottomAnchor),
            bottomSeparator.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 8),
            bottomSeparator.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -8),
            bottomSeparator.heightAnchor.constraint(equalToConstant: 1),
        ])
    }

    func configure(_ category: SFSymbolCategory) {
        iconImageView.image = UIImage(systemName: category.iconName)?
            .withRenderingMode(.alwaysTemplate)
        nameLabel.text = category.name
    }
}

#if DEBUG
import SwiftUI

extension CategoryHeader: UIViewRepresentable {
    func makeUIView(context: Context) -> CategoryHeader {
        let header = CategoryHeader()
        header.configure(.init(iconName: "mic", name: "communication",
                               symbols: [.init(name: "mic", isFavorite: false)]))
        return header
    }
    func updateUIView(_ uiView: CategoryHeader, context: Context) {
    }
}

struct CategoryHeaderPreview: PreviewProvider {
    static var previews: some View {
        Preview(self.content)
            .previewLayout(.fixed(width: UIScreen.main.bounds.width,
                                  height: CategoryHeader.height))
    }

    private static var content: some View {
        CategoryHeader()
    }
}
#endif
