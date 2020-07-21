//
//  ViewController.swift
//  CalendarView
//
//  Created by Dhanuka, Tejas | ECMPD on 2020/07/16.
//  Copyright © 2020 Tejas Dhanuka. All rights reserved.
//

import UIKit
import Foundation

class ViewController: UIViewController, CalendarViewDelegate {
    
    private var calendarView: CalendarView!
    private var weekdaysStackView: UIStackView!
    private var separatorView: UIView!
    
    var calendarStyle: CalendarViewStyle = {
        let cellStyle = DefaultCalendarCellStyler.Style(textColor: UIColor.black,
                                                        selectedTextColor: UIColor.white,
                                                        middleDateRangeTextColor: UIColor.white,
                                                        accent: UIColor.red,
                                                        disabledTextColor: UIColor.gray,
                                                        todaySelectionColor: UIColor.darkGray,
                                                        middleDateRangeColor: UIColor.red.withAlphaComponent(0.5),
                                                        font: UIFont.systemFont(ofSize: 15),
                                                        highlightBackgroundColor: UIColor.lightGray)
        let cellStyler = DefaultCalendarCellStyler(style: cellStyle)
        let headerStyle = CalendarHeaderStyle(textColor: UIColor.black,
                                              font: UIFont.systemFont(ofSize: 18.0, weight: .bold),
                                              dateFormatter: LocalizedDateFormatter.middle([.year, .month]))
        let style = CalendarViewStyle(calendarCellStyler: cellStyler,
                                      calendarHeaderStyle: headerStyle,
                                      cellSize: nil)
        return style
    }()
    
    private var daysOfWeek: [String] {
        if Calendar.current.firstWeekday == 2 {
            return ["Mon",
                    "Tue",
                    "Wed",
                    "Thu",
                    "Fri",
                    "Sat",
                    "Sun"
            ]
        } else if Calendar.current.firstWeekday == 7 {
            return ["Sat",
                    "Sun",
                    "Mon",
                    "Tue",
                    "Wed",
                    "Thu",
                    "Fri"
            ]
        } else {
            return ["Sun",
                    "Mon",
                    "Tue",
                    "Wed",
                    "Thu",
                    "Fri",
                    "Sat"
            ]
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
    }
    
    private func setupView() {
        addWeekdaysView()
        addSeparatorView()
        addCalendarView()
    }
    
    private func addWeekdaysView() {
        
        var viewsArray = [UIView]()
        for day in daysOfWeek {
            let dayView = UIView().noAutoresizingMask()
            dayView.backgroundColor = UIColor.red.withAlphaComponent(0.5)
            NSLayoutConstraint.activate([dayView.widthAnchor.constraint(equalToConstant: 33.0)])
            
            let label = UILabel().noAutoresizingMask()
            label.text = day
            label.font = UIFont.systemFont(ofSize: 14.0,weight: .bold)
            label.textAlignment = .center
            dayView.addSubview(label)
            
            NSLayoutConstraint.activate([label.centerXAnchor.constraint(equalTo: dayView.centerXAnchor),
                                         label.centerYAnchor.constraint(equalTo: dayView.centerYAnchor),
                                         label.widthAnchor.constraint(equalToConstant: 33)
            ])
            viewsArray.append(dayView)
        }
        
        weekdaysStackView = UIStackView(arrangedSubviews: viewsArray).noAutoresizingMask()
        weekdaysStackView.axis = .horizontal
        weekdaysStackView.distribution = .fillEqually
        weekdaysStackView.spacing = 1.0
        view.addSubview(weekdaysStackView)
        
        // autolayout constraint
        NSLayoutConstraint.activate([weekdaysStackView.topAnchor.constraint(equalTo: view.topAnchor, constant: 30),
                                     weekdaysStackView.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 8),
                                     weekdaysStackView.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -8),
                                     weekdaysStackView.heightAnchor.constraint(equalToConstant: 25)])
    }
    
    private func addSeparatorView() {
        separatorView = UIView().noAutoresizingMask()
        separatorView.backgroundColor = UIColor.red
        
        view.addSubview(separatorView)
        // autolayout constraint
        NSLayoutConstraint.activate([separatorView.topAnchor.constraint(equalTo: weekdaysStackView.bottomAnchor),
                                     separatorView.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 8),
                                     separatorView.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -8),
                                     separatorView.heightAnchor.constraint(equalToConstant: 1)])
    }
    
    private func addCalendarView() {
        calendarView = CalendarView.init(numberOfYears: 2, hidesDatesFromOtherMonth: true, disabledBeforeToday: true, style: calendarStyle).noAutoresizingMask()
        calendarView.calendarDelegate = self
        let selectedDates: CalendarView.Selection = CalendarView.Selection(startDate: Date(), endDate: nil)
        calendarView.setDateSelection(selectedDates)
        view.addSubview(calendarView)
        
        let layoutGuide = view.safeAreaLayoutGuide
        NSLayoutConstraint.activate([
            calendarView.topAnchor.constraint(equalTo: separatorView.bottomAnchor, constant: 2.0),
            calendarView.leftAnchor.constraint(equalTo: layoutGuide.leftAnchor, constant: 8.0),
            calendarView.rightAnchor.constraint(equalTo: layoutGuide.rightAnchor, constant: -8.0),
            calendarView.bottomAnchor.constraint(equalTo: layoutGuide.bottomAnchor, constant: -8.0)
        ])
    }
    
    func calendarDidChangeSelection(_ selection: CalendarView.Selection) {
        print(selection)
    }
}

