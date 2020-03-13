//
//  CategoryHeader.swift
//  SFSymbolsCollectionUsingNewAPI
//
//  Created by Shinzan Takata on 2020/03/13.
//  Copyright © 2020 shiz. All rights reserved.
//

import UIKit

class CategoryHeader: UICollectionReusableView {
    static let reuseIdentifier = "CategoryHeader"

    lazy var iconImageView: UIImageView = {
        let imageView = UIImageView()
        return imageView
    }()

    lazy var nameLabel: UILabel = {
        let label = UILabel()
        label.textColor = .black
        label.font = UIFont.boldSystemFont(ofSize: 40)
        label.numberOfLines = 0
        return label
    }()

    lazy var bottomSeparator: UIView = {
        let view = UIView()
        view.backgroundColor = .systemGray
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

            nameLabel.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: 8),
            nameLabel.centerYAnchor.constraint(equalTo: self.centerYAnchor),


            bottomSeparator.bottomAnchor.constraint(equalTo: self.bottomAnchor),
            bottomSeparator.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 8),
            bottomSeparator.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -8),
            bottomSeparator.heightAnchor.constraint(equalToConstant: 1),
        ])
    }

    func configure(_ symbol: SFSymbolCategory) {
        iconImageView.image = UIImage(systemName: symbol.categoryIconName)?.withRenderingMode(.alwaysOriginal)
        nameLabel.text = symbol.name
    }
}
