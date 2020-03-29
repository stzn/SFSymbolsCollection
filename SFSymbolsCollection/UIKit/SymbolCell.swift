//
//  SymbolCell.swift
//  SFSymbolsCollection
//
//  Created by Shinzan Takata on 2020/03/28.
//  Copyright © 2020 shiz. All rights reserved.
//

import UIKit

final class SymbolCell: UICollectionViewCell {
    static let reuseIdentifier = String(describing: SymbolCell.self)

    lazy var symbolImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        return imageView
    }()

    lazy var nameLabel: UILabel = {
        let label = UILabel()
        label.font = .preferredFont(forTextStyle: .title1)
        label.textAlignment = .left
        label.numberOfLines = 0
        return label
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        symbolImageView.image = nil
        nameLabel.text = nil
    }

    func configure(_ symbol: SFSymbolCategory.Symbol) {
        symbolImageView.image = UIImage(systemName: symbol.name)?.withRenderingMode(.alwaysOriginal)
        nameLabel.text = symbol.name
    }

    private func setupView() {
        contentView.addSubview(symbolImageView)
        contentView.addSubview(nameLabel)
        symbolImageView.translatesAutoresizingMaskIntoConstraints = false
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            symbolImageView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            symbolImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 8),
            symbolImageView.widthAnchor.constraint(equalTo: contentView.widthAnchor, multiplier: 0.2),
            nameLabel.leadingAnchor.constraint(equalTo: symbolImageView.trailingAnchor, constant: 12),
            nameLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -8),
            nameLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
        ])
    }
}
