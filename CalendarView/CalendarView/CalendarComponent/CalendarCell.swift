//
//  CalendarCell.swift
//  CalendarView
//
//  Created by Dhanuka, Tejas | ECMPD on 2020/07/16.
//  Copyright © 2020 Tejas Dhanuka. All rights reserved.
//

import Foundation
import UIKit

class NCell: UICollectionViewCell {
    
}

public class CalendarCell: UICollectionViewCell {
    public enum State {
        case firstDaySelected
        case selected
        case lastDaySelected
        case selectedInTheMiddle
        case hiddenSelectedInTheMiddle
        case unselected
        case hidden
        case today
        case disabled
    }
    
    public private(set) lazy var dateLabel: UILabel = {
        let label = UILabel().noAutoresizingMask()
        label.alignText(alignment: .center)
        return label
    }()
    public private(set) lazy var dateBackgroundView: UIView = UIView().noAutoresizingMask()
    public private(set) lazy var dateHighlightView: UIView = UIView().noAutoresizingMask()
    private(set) var date: Date = Date()
    private(set) var state: State = .unselected
    var styler: CalendarCellStyler?
    private var isFirstLayout = true
    var isSelectable: Bool {
        state != .disabled && state != .hidden && state != .hiddenSelectedInTheMiddle
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    public override func layoutSubviews() {
        super.layoutSubviews()
        if isFirstLayout {
            styler?.styleOnLayout(cell: self, state: state)
            isFirstLayout = false
        }
    }
    override public var isHighlighted: Bool {
        didSet {
            styler?.setHighlighted(cell: self, isHighlighted)
        }
    }
    
    func setDate(_ date: Date, state: State) {
        self.date = date
        self.state = state
        let dayComponent = Calendar.current.dateComponents([.day], from: date)
        dateLabel.text = "\(dayComponent.day ?? 1)"
        styler?.style(cell: self, state: state)
    }
    
    private func setupView() {
        contentView.addSubview(dateBackgroundView)
        contentView.addSubview(dateHighlightView)
        contentView.addSubview(dateLabel)
        dateBackgroundView.edgesAnchorEqualTo(view: contentView).activate()
        dateHighlightView.edgesAnchorEqualTo(view: contentView).activate()
        dateLabel.edgesAnchorEqualTo(view: contentView).activate()
    }
}

public protocol CalendarCellStyler {
    /**
     Styles the cell immediately after its state changes
     */
    func style(cell: CalendarCell, state: CalendarCell.State)
    
    /**
     Styles the cell the first time after its layout has been set
     */
    func styleOnLayout(cell: CalendarCell, state: CalendarCell.State)
    
    /**
     Styles the cell when it is highlighted
     */
    func setHighlighted(cell: CalendarCell, _ highlighted: Bool)
}

public struct DefaultCalendarCellStyler: CalendarCellStyler {
    public struct Style {
        let textColor: UIColor
        let selectedTextColor: UIColor
        let middleDateRangeTextColor: UIColor
        let accent: UIColor
        let disabledTextColor: UIColor
        let todaySelectionColor: UIColor
        let middleDateRangeColor: UIColor
        let font: UIFont
        let highlightBackgroundColor: UIColor
        
        public init(textColor: UIColor,
            selectedTextColor: UIColor,
            middleDateRangeTextColor: UIColor,
            accent: UIColor,
            disabledTextColor: UIColor,
            todaySelectionColor: UIColor,
            middleDateRangeColor: UIColor,
            font: UIFont,
            highlightBackgroundColor: UIColor) {
            self.textColor = textColor
            self.selectedTextColor = selectedTextColor
            self.middleDateRangeTextColor = middleDateRangeTextColor
            self.accent = accent
            self.disabledTextColor = disabledTextColor
            self.todaySelectionColor = todaySelectionColor
            self.middleDateRangeColor = middleDateRangeColor
            self.font = font
            self.highlightBackgroundColor = highlightBackgroundColor
        }
    }
    
    let style: Style
    let padding: CGFloat = 2
    
    public init(style: Style) {
        self.style = style
    }
    
    public func style(cell: CalendarCell, state: CalendarCell.State) {
        styleCell(cell: cell, state: state)
    }
    public func styleOnLayout(cell: CalendarCell, state: CalendarCell.State) {
        styleCell(cell: cell, state: state)
        cell.dateLabel.font = style.font
    }
    public func setHighlighted(cell: CalendarCell, _ highlighted: Bool) {
        if !cell.isSelectable {
            return
        }
        
        if highlighted {
            cell.dateHighlightView.layer.addSublayer(highlightLayer(rect: cell.bounds))
        } else {
            cell.dateHighlightView.layer.sublayers?.first?.removeFromSuperlayer()
        }
    }
    
    // MARK: - Private methods
    
    private func styleCell(cell: CalendarCell, state: CalendarCell.State) {
        if let subLayers = cell.dateBackgroundView.layer.sublayers {
            for subLayer in subLayers {
                subLayer.removeFromSuperlayer()
            }
        }
        switch state {
        case .firstDaySelected:
            cell.dateLabel.textColor = style.selectedTextColor
            cell.dateBackgroundView.layer.addSublayer(firstDaySquareLayer(rect: cell.bounds))
            cell.dateBackgroundView.layer.addSublayer(selectedCircleLayer(rect: cell.bounds))
        case .selected:
            cell.dateLabel.textColor = style.selectedTextColor
            cell.dateBackgroundView.layer.addSublayer(selectedCircleLayer(rect: cell.bounds))
        case .lastDaySelected:
            cell.dateLabel.textColor = style.selectedTextColor
            cell.dateBackgroundView.layer.addSublayer(lastDaySquareLayer(rect: cell.bounds))
            cell.dateBackgroundView.layer.addSublayer(selectedCircleLayer(rect: cell.bounds))
        case .hiddenSelectedInTheMiddle:
            cell.dateLabel.textColor = .clear
            cell.dateBackgroundView.layer.addSublayer(middleSquareLayer(rect: cell.bounds))
        case .selectedInTheMiddle:
            cell.dateLabel.textColor = style.middleDateRangeTextColor
            cell.dateBackgroundView.layer.addSublayer(middleSquareLayer(rect: cell.bounds))
        case .unselected:
            cell.dateLabel.textColor = style.textColor
        case .hidden:
            cell.dateLabel.textColor = .clear
        case .today:
            cell.dateLabel.textColor = style.textColor
            cell.dateBackgroundView.layer.addSublayer(todayLayer(rect: cell.bounds))
        case .disabled:
            cell.dateLabel.textColor = style.disabledTextColor
        }
    }
    private func circleLayer(rect: CGRect) -> CAShapeLayer {
        let layer = CAShapeLayer()
        let path = UIBezierPath(ovalIn: rect.insetBy(dx: padding, dy: padding))
        layer.path = path.cgPath
        return layer
    }
    private func selectedCircleLayer(rect: CGRect) -> CAShapeLayer {
        let layer = circleLayer(rect: rect)
        layer.fillColor = style.accent.cgColor
        return layer
    }
    private func highlightLayer(rect: CGRect) -> CAShapeLayer {
        let layer = circleLayer(rect: rect)
        layer.fillColor = style.highlightBackgroundColor.cgColor
        return layer
    }
    private func firstDaySquareLayer(rect: CGRect) -> CAShapeLayer {
        let layer = CAShapeLayer()
        let path = UIBezierPath(rect: CGRect(x: rect.width / 2, y: padding, width: rect.width / 2, height: rect.height - (padding * 2)))
        layer.path = path.cgPath
        layer.fillColor = style.middleDateRangeColor.cgColor
        return layer
    }
    private func lastDaySquareLayer(rect: CGRect) -> CAShapeLayer {
        let layer = CAShapeLayer()
        let path = UIBezierPath(rect: CGRect(x: 0, y: padding, width: rect.width / 2, height: rect.height - (padding * 2)))
        layer.path = path.cgPath
        layer.fillColor = style.middleDateRangeColor.cgColor
        return layer
    }
    private func middleSquareLayer(rect: CGRect) -> CAShapeLayer {
        let layer = CAShapeLayer()
        let path = UIBezierPath(rect: CGRect(x: 0, y: padding, width: rect.width, height: rect.height - (padding * 2)))
        layer.path = path.cgPath
        layer.fillColor = style.middleDateRangeColor.cgColor
        return layer
    }
    private func todayLayer(rect: CGRect) -> CAShapeLayer {
        let layer = circleLayer(rect: rect)
        layer.strokeColor = style.todaySelectionColor.cgColor
        layer.lineWidth = 1
        layer.fillColor = nil
        return layer
    }
}
