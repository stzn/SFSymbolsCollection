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
        imageView.tintColor = .label
        return imageView
    }()

    private let symbolNameLabel: UILabel = {
        let label = UILabel()
        label.font = .preferredFont(forTextStyle: .title1)
        label.adjustsFontForContentSizeCategory = true
        label.textColor = .label
        label.textAlignment = .center
        label.numberOfLines = 0
        label.setContentHuggingPriority(.init(249), for: .vertical)
        return label
    }()

    private lazy var favoriteButton: UIButton = {
        let button = UIButton(type: .system)
        button.backgroundColor = .systemBlue
        button.setTitle(addToFavorite, for: .normal)
        button.titleLabel?.font = .preferredFont(forTextStyle: .headline)
        button.titleLabel?.adjustsFontForContentSizeCategory = true
        button.setTitleColor(.white, for: .normal)
        button.contentEdgeInsets = UIEdgeInsets(top: 8, left: 8, bottom: 8, right: 8)
        button.layer.cornerRadius = 8
        button.addTarget(self, action: #selector(toggleFavorite(_:)), for: .touchUpInside)
        return button
    }()

    // MARK: code view

    private lazy var codeView: UIView = {
        let view = UIView()
        view.layer.borderWidth = 1
        view.layer.cornerRadius = 8
        return view
    }()

    private let codeContainerView: UIStackView = {
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.distribution = .fillProportionally
        stack.spacing = 8
        return stack
    }()

    private let codeLabel: UILabel = {
        let label = UILabel()
        label.font = .preferredFont(forTextStyle: .body)
        label.adjustsFontForContentSizeCategory = true
        label.textColor = .label
        label.textAlignment = .center
        label.numberOfLines = 0
        return label
    }()

    private lazy var copyButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Copy", for: .normal)
        button.titleLabel?.font = .preferredFont(forTextStyle: .body)
        button.titleLabel?.adjustsFontForContentSizeCategory = true
        button.setTitleColor(.systemBlue, for: .normal)
        button.backgroundColor = .white
        button.layer.borderWidth = 1
        button.layer.cornerRadius = 8
        button.contentEdgeInsets = UIEdgeInsets(top: 8, left: 8, bottom: 8, right: 8)
        button.addTarget(self, action: #selector(copyCode(_:)), for: .touchUpInside)
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
        view.backgroundColor = .systemBackground
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        setupData()
    }

    private func setupView() {
        setupCodeView()

        containerView.insertArrangedSubview(symbolImageView, at: 0)
        containerView.insertArrangedSubview(symbolNameLabel, at: 1)
        containerView.insertArrangedSubview(codeView, at: 2)
        containerView.insertArrangedSubview(favoriteButton, at: 3)
        view.addSubview(containerView)
        containerView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            containerView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            containerView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            symbolImageView.heightAnchor.constraint(equalTo: view.heightAnchor, multiplier: 0.5),
            favoriteButton.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.9),
        ])
        favoriteButton.isHidden = (presentingViewController != nil)

    }

    private func setupCodeView() {
        codeContainerView.insertArrangedSubview(codeLabel, at: 0)
        codeContainerView.insertArrangedSubview(copyButton, at: 1)

        codeView.addSubview(codeContainerView)
        codeContainerView.pinEdgesTo(codeView, constant: 8)
        NSLayoutConstraint.activate([
            copyButton.widthAnchor.constraint(equalTo: codeView.widthAnchor, multiplier: 0.2),
        ])
    }

    private func setupData() {
        symbolImageView.image = UIImage(systemName: symbol.name)?
            .withRenderingMode(.alwaysTemplate)
        symbolNameLabel.text = symbol.name
        let buttonTitle = symbol.isFavorite ? removeFromFavorite : addToFavorite
        favoriteButton.setTitle(buttonTitle, for: .normal)
        codeLabel.text = "UIImage(systemName: \"\(symbol.name)\")"
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        updateCurrentTraitCollection()
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

    @objc func copyCode(_ button: UIButton) {
        UIPasteboard.general.string = codeLabel.text
        showCopyDoneAlert()
    }

    private func showCopyDoneAlert() {
        let alert = UIAlertController(title: "", message: "Copy Done!", preferredStyle: .alert)
        let okActioin = UIAlertAction(title: "OK", style: .default)
        alert.addAction(okActioin)
        present(alert, animated: true)
    }
}

// MARK: Dark Mode Support

extension SymbolViewController {
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        updateCurrentTraitCollection()
    }

    private func updateCurrentTraitCollection() {
        if traitCollection.userInterfaceStyle == .dark {
            copyButton.layer.borderColor = UIColor.white.cgColor
            codeView.layer.borderColor = UIColor.white.cgColor
        } else {
            copyButton.layer.borderColor = UIColor.black.cgColor
            codeView.layer.borderColor = UIColor.black.cgColor
        }
    }
}

#if DEBUG
import SwiftUI

extension SymbolViewController: UIViewControllerRepresentable {
    func makeUIViewController(context: Context) -> SymbolViewController {
        SymbolViewController(
            frame: UIScreen.main.bounds,
            input: .init(
                category: FavoriteSymbolKey(iconName: "mic", categoryName: "mic"),
                symbol: SFSymbolCategory.Symbol(name: "mic", isFavorite: false),
                store: InMemoryFavoriteSymbolStore()))
    }

    func updateUIViewController(_ uiViewController: SymbolViewController, context: Context) {

    }
}

struct SymbolViewControllerPreview: PreviewProvider {
    static var previews: some View {
        Preview(self.content)
    }

    private static var content: SymbolViewController {
        SymbolViewController(
            frame: UIScreen.main.bounds,
            input: .init(
                category: FavoriteSymbolKey(iconName: "mic", categoryName: "mic"),
                symbol: SFSymbolCategory.Symbol(name: "mic", isFavorite: false),
                store: InMemoryFavoriteSymbolStore()))
    }
}
#endif
