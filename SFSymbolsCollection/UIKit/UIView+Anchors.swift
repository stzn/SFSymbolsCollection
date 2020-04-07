//
//  UIView+Anchors.swift
//  SFSymbolsCollection
//
//  Created by Shinzan Takata on 2020/04/05.
//  Copyright © 2020 shiz. All rights reserved.
//

import UIKit

extension UIView {
    func pinEdgesTo(_ view: UIView, constant: CGFloat = .zero) {
        translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            topAnchor.constraint(equalTo: view.topAnchor, constant: constant),
            leftAnchor.constraint(equalTo: view.leftAnchor, constant: constant),
            bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -constant),
            rightAnchor.constraint(equalTo: view.rightAnchor, constant: -constant),
        ])
    }
}
