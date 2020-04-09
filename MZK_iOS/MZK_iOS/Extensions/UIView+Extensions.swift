//
//  UIView+Extensions.swift
//  MZK_iOS
//
//  Created by Ondrej Vyhlidal on 15/09/2019.
//  Copyright © 2019 Ondrej Vyhlidal. All rights reserved.
//

import UIKit

extension UIView {

    // MARK: - Properties

    static var nibName: String {
        return String(describing: self)
    }

    // MARK: - Constraints

    func addSubview(_ view: UIView?, constraints: [NSLayoutConstraint]) {
        guard let view = view else {
            return
        }
        addSubview(view)
        view.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate(constraints)
    }

    func addSubviewWithConstraintsToCenter(_ view: UIView?) {
        guard let view = view else {
            return
        }
        addSubview(view, constraints: [
            view.centerXAnchor.constraint(equalTo: centerXAnchor),
            view.centerYAnchor.constraint(equalTo: centerYAnchor)
            ])
    }

    func addSubviewWithConstraintsToEdges(_ view: UIView?) {
        guard let view = view else {
            return
        }
        addSubview(view, constraints: [
            view.topAnchor.constraint(equalTo: topAnchor),
            view.rightAnchor.constraint(equalTo: rightAnchor),
            view.bottomAnchor.constraint(equalTo: bottomAnchor),
            view.leftAnchor.constraint(equalTo: leftAnchor)
            ])
    }
}
