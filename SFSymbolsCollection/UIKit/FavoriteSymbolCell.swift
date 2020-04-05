//
//  FavoriteSymbolCell.swift
//  SFSymbolsCollection
//
//  Created by Shinzan Takata on 2020/03/28.
//  Copyright © 2020 shiz. All rights reserved.
//

import UIKit

final class FavoriteSymbolCell: UICollectionViewCell {
    static let reuseIdentifier = String(describing: FavoriteSymbolCell.self)

    var isEditing: Bool = false {
        didSet {
            checkboxImageView.isHidden = !isEditing
        }
    }

    private let symbolImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        return imageView
    }()

    private let nameLabel: UILabel = {
        let label = UILabel()
        label.font = .preferredFont(forTextStyle: .title1)
        label.textAlignment = .left
        label.numberOfLines = 0
        return label
    }()

    private let checkboxImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(systemName: "checkmark.circle", withConfiguration: UIImage.SymbolConfiguration(scale: .large))
        imageView.isHidden = true
        return imageView
    }()

    override var isSelected: Bool {
        didSet {
            let systemName = isEditing && isSelected ? "checkmark.circle.fill" : "checkmark.circle"
            checkboxImageView.image = UIImage(systemName: systemName, withConfiguration: UIImage.SymbolConfiguration(scale: .large))
            checkboxImageView.isHidden = !isEditing
        }
    }

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
        contentView.addSubview(checkboxImageView)
        symbolImageView.translatesAutoresizingMaskIntoConstraints = false
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        checkboxImageView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            symbolImageView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            symbolImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 8),
            symbolImageView.widthAnchor.constraint(equalTo: contentView.widthAnchor, multiplier: 0.2),
            nameLabel.leadingAnchor.constraint(equalTo: symbolImageView.trailingAnchor, constant: 12),
            nameLabel.trailingAnchor.constraint(equalTo: checkboxImageView.leadingAnchor, constant: 8),
            nameLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            checkboxImageView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            checkboxImageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -8),
        ])
    }
}
