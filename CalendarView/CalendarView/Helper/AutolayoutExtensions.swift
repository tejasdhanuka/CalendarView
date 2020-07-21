//
//  AutolayoutExtensions.swift
//  CalendarView
//
//  Created by Dhanuka, Tejas | ECMPD on 2020/07/16.
//  Copyright © 2020 Tejas Dhanuka. All rights reserved.
//

import Foundation
import UIKit

public enum TextAlignment {
    case leading, center, trailing
}

public extension UIView {
    
    /**
     Returns an instance of `Self` with auto resizing
     masks turned off.
     */
    func noAutoresizingMask() -> Self {
        translatesAutoresizingMaskIntoConstraints = false
        return self
    }
    
    /**
     Creates layout constrains for all 4 edges of a `view`,
     and makes it match to the provided view.
     Optionally specify if you want edges to constraint to safe
     anchors.
     */
    func edgesAnchorEqualTo(view: UIView, safeLeft: Bool = false, safeTop: Bool = false, safeRight: Bool = false, safeBottom: Bool = false) -> [NSLayoutConstraint] {
        [topAnchor.constraint(equalTo: safeTop ? view.safeTopAnchor : view.topAnchor),
         leftAnchor.constraint(equalTo: safeLeft ? view.safeAreaLayoutGuide.leftAnchor : view.leftAnchor),
         bottomAnchor.constraint(equalTo: safeBottom ? view.safeBottomAnchor : view.bottomAnchor),
         rightAnchor.constraint(equalTo: safeRight ? view.safeAreaLayoutGuide.rightAnchor : view.rightAnchor)]
    }
    
    /**
     Returns the safe area bottom anchor.
     If not available, returns the bottom anchor.
     */
    var safeBottomAnchor: NSLayoutYAxisAnchor {
        if #available(iOS 11.0, *) {
            return safeAreaLayoutGuide.bottomAnchor
        } else {
            return bottomAnchor
        }
    }
    
    /**
     Returns the safe area top anchor.
     If not available, returns the top anchor.
     */
    var safeTopAnchor: NSLayoutYAxisAnchor {
        if #available(iOS 11.0, *) {
            return safeAreaLayoutGuide.topAnchor
        } else {
            return topAnchor
        }
    }
}

public extension Array where Element: NSLayoutConstraint {
    /**
     Activates all layout constraints inside the array.
     */
    @discardableResult func activate() -> Array {
        forEach { $0.isActive = true }
        return self
    }
}

extension UILabel {
    func alignText(alignment: TextAlignment) {
        let layoutDirection = UIView.userInterfaceLayoutDirection(for: semanticContentAttribute)
        switch alignment {
        case .leading:
            textAlignment = .natural
        case .center:
            textAlignment = .center
        case .trailing:
            textAlignment = (layoutDirection == .leftToRight) ? .right : .left
        }
    }
}
