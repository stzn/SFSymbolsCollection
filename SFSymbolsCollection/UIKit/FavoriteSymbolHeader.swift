//
//  FavoriteSymbolHeader.swift
//  SFSymbolsCollection
//
//  Created by Shinzan Takata on 2020/04/05.
//  Copyright © 2020 shiz. All rights reserved.
//

import UIKit

final class FavoriteSymbolHeader: UITableViewHeaderFooterView {
    static let height: CGFloat = 80
    static let reuseIdentifier = String(describing: FavoriteSymbolHeader.self)

    private let containerView: UIView = {
        let view = UIView()
        view.backgroundColor = .systemBackground
        return view
    }()

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
        return view
    }()

    override init(reuseIdentifier: String?) {
        super.init(reuseIdentifier: reuseIdentifier)
        setup()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setup() {
        containerView.addSubview(iconImageView)
        containerView.addSubview(nameLabel)
        containerView.addSubview(bottomSeparator)

        iconImageView.translatesAutoresizingMaskIntoConstraints = false
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        bottomSeparator.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            iconImageView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 8),
            iconImageView.trailingAnchor.constraint(equalTo: nameLabel.leadingAnchor, constant: -8),
            iconImageView.centerYAnchor.constraint(equalTo: containerView.centerYAnchor),
            iconImageView.heightAnchor.constraint(equalToConstant: 44),
            iconImageView.widthAnchor.constraint(equalTo: iconImageView.heightAnchor),

            nameLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -8),
            nameLabel.centerYAnchor.constraint(equalTo: containerView.centerYAnchor),

            bottomSeparator.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 8),
            bottomSeparator.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -8),
            bottomSeparator.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 8),
            bottomSeparator.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -8),
            bottomSeparator.heightAnchor.constraint(equalToConstant: 1),
        ])

        addSubview(containerView)
        containerView.translatesAutoresizingMaskIntoConstraints = false
        containerView.pinEdgesTo(self)
    }

    func configure(_ category: SFSymbolCategory) {
        iconImageView.image = UIImage(systemName: category.iconName)?.withRenderingMode(.alwaysTemplate)
        nameLabel.text = category.name
    }
}

#if DEBUG
import SwiftUI

extension FavoriteSymbolHeader: UIViewRepresentable {
    func makeUIView(context: Context) -> FavoriteSymbolHeader {
        let header = FavoriteSymbolHeader()
        header.configure(.init(iconName: "mic", name: "communication",
                               symbols: [.init(name: "mic", isFavorite: false)]))
        return header
    }
    func updateUIView(_ uiView: FavoriteSymbolHeader, context: Context) {
    }
}

struct FavoriteSymbolHeaderPreview: PreviewProvider {
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
                        .previewLayout(.fixed(width: UIScreen.main.bounds.width,
                                              height: FavoriteSymbolHeader.height))
                        .previewDevice(PreviewDevice(rawValue: name))
                        .previewDisplayName(name)
                        .colorScheme(.light)
                    self.content
                        .previewLayout(.fixed(width: UIScreen.main.bounds.width,
                                              height: FavoriteSymbolHeader.height))
                        .previewDevice(PreviewDevice(rawValue: name))
                        .previewDisplayName(name)
                        .colorScheme(.dark)
                }
            }
        }
    }

    private static var content: some View {
        FavoriteSymbolHeader()
    }
}
#endif
