//
//  CalendarView.swift
//  CalendarView
//
//  Created by Dhanuka, Tejas | ECMPD on 2020/07/16.
//  Copyright © 2020 Tejas Dhanuka. All rights reserved.
//

import UIKit
import Foundation

public protocol CalendarViewDelegate: AnyObject {
    func calendarDidChangeSelection(_ selection: CalendarView.Selection)
}

public struct CalendarViewStyle {
    let calendarCellStyler: CalendarCellStyler
    let calendarHeaderStyle: CalendarHeaderStyle
    let cellSize: CGFloat?
    
    public init(calendarCellStyler: CalendarCellStyler,
        calendarHeaderStyle: CalendarHeaderStyle,
        cellSize: CGFloat?) {
        self.calendarCellStyler = calendarCellStyler
        self.calendarHeaderStyle = calendarHeaderStyle
        self.cellSize = cellSize
    }
}

public class CalendarView: UICollectionView {
    public struct Selection: Hashable {
        public var startDate: Date?
        public var endDate: Date?
        
        public init(startDate: Date? = Date(),
            endDate: Date? = Date()) {
            self.startDate = startDate
            self.endDate = endDate
        }
    }
    
    // MARK: - Properties
    
    let calendarCellIdentifier = "CalendarCellIdentifier"
    let headerIdentifier = "HeaderIdentifier"
    let startYear: Int
    let startMonth: Int
    let numberOfYears: Int
    let startDate: Date
    let hidesDatesFromOtherMonth: Bool
    let disabledBeforeToday: Bool
    public private(set) var selection = Selection()
    let today = Date().dateWithoutTime()
    let style: CalendarViewStyle?
    weak var calendarDelegate: CalendarViewDelegate?
    var cellSize: CGFloat {
        style?.cellSize ?? (UIScreen.main.bounds.width / 7 - 20)
    }
    var scrollToIndexPath: IndexPath?
    
    // MARK: - Init
    
    public init(startYear: Int? = nil, startMonth: Int? = nil, numberOfYears: Int = 1, hidesDatesFromOtherMonth: Bool = false, disabledBeforeToday: Bool = true, style: CalendarViewStyle? = nil) {
        self.startYear = startYear ?? CalendarView.currentYear
        self.startMonth = startMonth ?? CalendarView.currentMonth
        self.numberOfYears = numberOfYears
        self.startDate = Date(year: self.startYear, month: self.startMonth, day: 1)
        self.hidesDatesFromOtherMonth = hidesDatesFromOtherMonth
        self.disabledBeforeToday = disabledBeforeToday
        self.style = style
        
        let layout = UICollectionViewFlowLayout()
        let cellSize = style?.cellSize ?? (UIScreen.main.bounds.width / 7 - 20)
        layout.itemSize = CGSize(width: cellSize, height: cellSize)
        layout.scrollDirection = .vertical
        layout.minimumLineSpacing = 0
        layout.minimumInteritemSpacing = 0
        layout.headerReferenceSize = CGSize(width: 0, height: 40)
        super.init(frame: .zero, collectionViewLayout: layout)
        
        setupView()
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Override
    
    override public var intrinsicContentSize: CGSize {
        let size = super.intrinsicContentSize
        return CGSize(width: cellSize * 7, height: size.height)
    }
    
    public override func layoutSubviews() {
        super.layoutSubviews()
        if let scrollToIndexPath = scrollToIndexPath {
            scrollToItem(at: scrollToIndexPath, at: .centeredVertically, animated: false)
            self.scrollToIndexPath = nil
        }
    }
    
    // MARK: - Public methods
    
    func setDateSelection(_ selection: Selection) {
        self.selection = selection
        reloadData()
    }
    
    func scrollToSelectionOnAppear() {
        guard let selectedDate = selection.startDate else { return }
        
        let monthDifference = startDate.monthDifference(toDate: selectedDate)
        let firstDayOfSelectedMonth = startDate.dateByAddingMonths(monthDifference)
        let dayDifferenceFromStartOfMonth = firstDayOfSelectedMonth.dayDifference(toDate: selectedDate)
        scrollToIndexPath = IndexPath(row: dayDifferenceFromStartOfMonth, section: monthDifference)
    }
    
    // MARK: - Private methods
    
    private static var currentYear: Int {
        Calendar.current.dateComponents([.year], from: Date()).year ?? 2000
    }
    private static var currentMonth: Int {
        Calendar.current.dateComponents([.month], from: Date()).month ?? 1
    }
    private func setupView() {
        backgroundColor = .clear
        register(CalendarCell.self, forCellWithReuseIdentifier: calendarCellIdentifier)
        register(CalendarHeader.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: headerIdentifier)
        dataSource = self
        delegate = self
    }
    private func dateForIndexPath(_ indexPath: IndexPath) -> Date {
        let firstDayOfMonth = startDate.dateByAddingMonths(indexPath.section).dateWithoutTime()
        let daysOfLastMonth = ( firstDayOfMonth.weekday() - Calendar.current.firstWeekday)
        let day = indexPath.row - daysOfLastMonth
        let date = firstDayOfMonth.dateByAddingDays(day)
        return date
    }
}

extension CalendarView: UICollectionViewDataSource {
    public func numberOfSections(in collectionView: UICollectionView) -> Int {
        numberOfYears * 12 - (startMonth - 1)
    }
    
    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        let firstDayOfMonth = startDate.dateByAddingMonths(section)
        let numberOfDaysWithPreviousMonth = ( firstDayOfMonth.numberOfDaysInMonth() + firstDayOfMonth.weekday() - Calendar.current.firstWeekday )
        let daysInIncompleteWeek = numberOfDaysWithPreviousMonth % 7
        
        let numberOfItemsInSection = daysInIncompleteWeek == 0 ? numberOfDaysWithPreviousMonth : numberOfDaysWithPreviousMonth + 7 - daysInIncompleteWeek
        return numberOfItemsInSection
    }
    
    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: calendarCellIdentifier, for: indexPath) as? CalendarCell else {
            return UICollectionViewCell()
        }
        
        let firstDayOfMonth = startDate.dateByAddingMonths(indexPath.section).dateWithoutTime()
        let daysOfLastMonth = ( firstDayOfMonth.weekday() - Calendar.current.firstWeekday)
        let day = indexPath.row - daysOfLastMonth
        let date = firstDayOfMonth.dateByAddingDays(day)
        let selectedStartDate = selection.startDate?.dateWithoutTime()
        let selectedEndDate = selection.endDate?.dateWithoutTime()
        
        var cellState: CalendarCell.State = .unselected
        if date == today {
            cellState = .today
        }
        if indexPath.row >= daysOfLastMonth {
            let lastDayOfMonth = firstDayOfMonth.dateByAddingDays(firstDayOfMonth.numberOfDaysInMonth() - 1)
            if date > lastDayOfMonth {
                // Next Month
                if hidesDatesFromOtherMonth {
                    if let selectedStartDate = selectedStartDate,
                        let selectedEndDate = selectedEndDate,
                        selectedStartDate <= lastDayOfMonth,
                        selectedEndDate > lastDayOfMonth {
                        cellState = .hiddenSelectedInTheMiddle
                    } else {
                        cellState = .hidden
                    }
                } else {
                    cellState = .disabled
                }
            } else {
                // This Month
                if disabledBeforeToday && date < today {
                    cellState = .disabled
                } else if date == selectedStartDate {
                    cellState = selectedEndDate != nil ? .firstDaySelected : .selected
                } else if date == selectedEndDate {
                    cellState = .lastDaySelected
                } else if let selectedStartDate = selectedStartDate,
                    let selectedEndDate = selectedEndDate,
                    (selectedStartDate...selectedEndDate).contains(date) {
                    cellState = .selectedInTheMiddle
                }
            }
        } else {
            // Previous Month
            if hidesDatesFromOtherMonth {
                if let selectedStartDate = selectedStartDate,
                    let selectedEndDate = selectedEndDate,
                    selectedEndDate >= firstDayOfMonth,
                    selectedStartDate < firstDayOfMonth {
                    cellState = .hiddenSelectedInTheMiddle
                } else {
                    cellState = .hidden
                }
            } else {
                cellState = .disabled
            }
        }
        
        cell.styler = style?.calendarCellStyler
        cell.setDate(date, state: cellState)
        
        return cell
    }
    public func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        guard let header = collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: headerIdentifier, for: indexPath) as? CalendarHeader else {
            return UICollectionReusableView()
        }
        
        if header.style == nil {
            if let headerStyle = style?.calendarHeaderStyle {
                header.setupStyle(style: headerStyle)
            }
        }
        let firstDayOfMonth = startDate.dateByAddingMonths(indexPath.section)
        header.setDate(firstDayOfMonth)
        
        return header
    }
}

extension CalendarView: UICollectionViewDelegate {
    public func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let cell = collectionView.cellForItem(at: indexPath) as? CalendarCell, cell.isSelectable else {
            return
        }
        
        let date = dateForIndexPath(indexPath)
        if selection.startDate == nil {
            selection.startDate = date
        } else if selection.endDate != nil {
            selection.startDate = date
            selection.endDate = nil
        } else {
            if let selectedStartDate = selection.startDate?.dateWithoutTime() {
                if date < selectedStartDate {
                    selection.startDate = date
                } else if date == selectedStartDate {
                    return
                }
                else {
                    selection.endDate = date
                }
            }
        }
        reloadData()
        calendarDelegate?.calendarDidChangeSelection(selection)
    }
}

extension CalendarView: UICollectionViewDelegateFlowLayout {
    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let side = bounds.width / 7
        return CGSize(width: side, height: side)
    }
}
