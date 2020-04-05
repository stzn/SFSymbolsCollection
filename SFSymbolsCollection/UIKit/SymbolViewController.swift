//
//  SymbolViewController.swift
//  SFSymbolsCollection
//
//  Created by Shinzan Takata on 2020/03/27.
//  Copyright © 2020 shiz. All rights reserved.
//

import UIKit

final class SymbolViewController: UIViewController {
    struct Input {
        let category: FavoriteSymbolKey
        var symbol: SFSymbolCategory.Symbol
        let store: FavoriteSymbolStore
    }

    private let containerView: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.distribution = .fill
        stack.spacing = 8
        return stack
    }()

    private let symbolImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()

    private let symbolNameLabel: UILabel = {
        let label = UILabel()
        label.font = .preferredFont(forTextStyle: .title1)
        label.textAlignment = .center
        label.numberOfLines = 0
        label.setContentHuggingPriority(.init(249), for: .vertical)
        return label
    }()

    private lazy var favoriteButton: UIButton = {
        let button = UIButton(type: .system)
        button.backgroundColor = .systemBlue
        button.setTitle(addToFavorite, for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.titleLabel?.font = .preferredFont(forTextStyle: .headline)
        button.contentEdgeInsets = UIEdgeInsets(top: 8, left: 8, bottom: 8, right: 8)
        button.layer.cornerRadius = 8
        button.addTarget(self, action: #selector(toggleFavorite(_:)), for: .touchUpInside)
        return button
    }()

    private let addToFavorite = "Add to Favorite"
    private let removeFromFavorite = "Remove from Favorite"
    private let frame: CGRect
    private var input: Input
    private var category: FavoriteSymbolKey { input.category }
    private var symbol: SFSymbolCategory.Symbol {
        get { input.symbol }
        set { input.symbol = newValue }
    }
    private var store: FavoriteSymbolStore { input.store }

    init(frame: CGRect, input: Input) {
        self.frame = frame
        self.input = input
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func loadView() {
        super.loadView()
        view = UIView(frame: frame)
        view.backgroundColor = .white
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        setupData()
    }

    private func setupView() {
        containerView.insertArrangedSubview(symbolImageView, at: 0)
        containerView.insertArrangedSubview(symbolNameLabel, at: 1)
        containerView.insertArrangedSubview(favoriteButton, at: 2)
        view.addSubview(containerView)
        containerView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            containerView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            containerView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            symbolImageView.heightAnchor.constraint(equalTo: view.heightAnchor, multiplier: 0.5),
            favoriteButton.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.8),
        ])
    }

    private func setupData() {
        symbolImageView.image = UIImage(systemName: symbol.name)?.withRenderingMode(.alwaysOriginal)
        symbolNameLabel.text = symbol.name
        let buttonTitle = symbol.isFavorite ? removeFromFavorite : addToFavorite
        favoriteButton.setTitle(buttonTitle, for: .normal)
    }

    @objc func toggleFavorite(_ button: UIButton) {
        symbol.isFavorite.toggle()
        if symbol.isFavorite {
            button.setTitle(removeFromFavorite, for: .normal)
            store.save(category, symbol: symbol) { _ in }
        } else {
            button.setTitle(addToFavorite, for: .normal)
            store.delete(category, symbol: symbol) { _ in }
        }
    }
}
