//
//  NSLayoutConstraint+Extensions.swift
//  99reddits
//
//  Created by Pietro Rea on 10/2/17.
//  Copyright © 2017 99 reddits. All rights reserved.
//

import UIKit

extension UIView {
    func matchParentSize() {
        guard let superview = superview else {
            return
        }

        translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([self.leadingAnchor.constraint(equalTo: superview.leadingAnchor),
                                     self.topAnchor.constraint(equalTo: superview.topAnchor),
                                     self.trailingAnchor.constraint(equalTo: superview.trailingAnchor),
                                     self.bottomAnchor.constraint(equalTo: superview.bottomAnchor)])
    }
}
