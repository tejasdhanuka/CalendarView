//
//  CalendarHeader.swift
//  CalendarView
//
//  Created by Dhanuka, Tejas | ECMPD on 2020/07/17.
//  Copyright © 2020 Tejas Dhanuka. All rights reserved.
//

import UIKit

class CalendarHeader: UICollectionReusableView {
    private lazy var label: UILabel = {
        let label = UILabel().noAutoresizingMask()
        label.textAlignment = .center
        return label
    }()
    private(set) var style: CalendarHeaderStyle?
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    private func setupView() {
        addSubview(label)
        label.edgesAnchorEqualTo(view: self).activate()
    }
    func setDate(_ date: Date) {
        label.text = style?.dateFormatter.string(from: date) ?? "\(date)"
    }
    func setupStyle(style: CalendarHeaderStyle) {
        self.style = style
        label.font = style.font
        label.textColor = style.textColor
    }
}

public class CalendarHeaderStyle {
    let textColor: UIColor
    let font: UIFont
    let dateFormatter: DateFormatter
    
    public init(textColor: UIColor,
        font: UIFont,
        dateFormatter: DateFormatter) {
        self.textColor = textColor
        self.font = font
        self.dateFormatter = dateFormatter
    }
}
