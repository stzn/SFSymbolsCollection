//
//  FavoriteSymbolTableCell.swift
//  SFSymbolsCollection
//
//  Created by Shinzan Takata on 2020/04/05.
//  Copyright © 2020 shiz. All rights reserved.
//

import UIKit

final class FavoriteSymbolTableCell: UITableViewCell {
    static let height: CGFloat = 88
    static let reuseIdentifier = String(describing: FavoriteSymbolTableCell.self)

    private let containerView: UIStackView = {
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.distribution = .fill
        return stack
    }()

    private let symbolImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.tintColor = .label
        return imageView
    }()

    private let nameLabel: UILabel = {
        let label = UILabel()
        label.font = .preferredFont(forTextStyle: .title1)
        label.adjustsFontForContentSizeCategory = true
        label.textColor = .label
        label.textAlignment = .left
        label.numberOfLines = 0
        return label
    }()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
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

    private func setupView() {
        contentView.backgroundColor = .systemBackground

        containerView.addArrangedSubview(symbolImageView)
        containerView.addArrangedSubview(nameLabel)
        contentView.addSubview(containerView)
        containerView.pinEdgesTo(contentView)

        NSLayoutConstraint.activate([
            symbolImageView.widthAnchor.constraint(
                equalTo: contentView.widthAnchor, multiplier: 0.2),
        ])
    }

    func configure(_ symbol: SFSymbolCategory.Symbol) {
        symbolImageView.image = UIImage(systemName: symbol.name)?
            .withRenderingMode(.alwaysTemplate)
        nameLabel.text = symbol.name
    }
}

#if DEBUG
import SwiftUI

extension FavoriteSymbolTableCell: UIViewRepresentable {
    func makeUIView(context: Context) -> FavoriteSymbolTableCell {
        let cell = FavoriteSymbolTableCell()
        cell.configure(.init(name: "mic", isFavorite: false))
        return cell
    }

    func updateUIView(_ uiView: FavoriteSymbolTableCell, context: Context) {
    }
}

struct FavoriteSymbolTableCellPreview: PreviewProvider {
    static var previews: some View {
        Preview(self.content)
            .previewLayout(
                .fixed(
                    width: UIScreen.main.bounds.width,
                    height: FavoriteSymbolTableCell.height))
    }

    private static var content: some View {
        FavoriteSymbolTableCell()
    }
}
#endif
