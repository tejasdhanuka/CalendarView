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
    
    var calendarStyle: CalendarViewStyle = {
        let cellStyle = DefaultCalendarCellStyler.Style(textColor: UIColor.red,
                                                        selectedTextColor: UIColor.blue,
                                                        middleDateRangeTextColor: UIColor.systemPink,
                                                        accent: UIColor.red,
                                                        disabledTextColor: UIColor.gray,
                                                        todaySelectionColor: UIColor.darkGray,
                                                        middleDateRangeColor: UIColor.yellow,
                                                        font: UIFont.systemFont(ofSize: 15),
                                                        highlightBackgroundColor: UIColor.green)
        let cellStyler = DefaultCalendarCellStyler(style: cellStyle)
        let headerStyle = CalendarHeaderStyle(textColor: UIColor.red,
                                              font: UIFont.systemFont(ofSize: 10),
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
        addCalendarView()
    }
    
    private func addWeekdaysView() {
        var viewsArray = [UIView]()
        
        for day in daysOfWeek {
            let dayView = UIView().noAutoresizingMask()
            NSLayoutConstraint.activate([dayView.widthAnchor.constraint(equalToConstant: 33.0)])
            
            let label = UILabel().noAutoresizingMask()
            label.text = day
            label.font = UIFont.systemFont(ofSize: 12.0)
            label.textAlignment = .center
            dayView.addSubview(label)
            
            NSLayoutConstraint.activate([label.topAnchor.constraint(equalTo: dayView.topAnchor),
                                         label.leftAnchor.constraint(equalTo: dayView.leftAnchor),
                                         label.bottomAnchor.constraint(equalTo: dayView.bottomAnchor),
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
        NSLayoutConstraint.activate([weekdaysStackView.topAnchor.constraint(equalTo: view.topAnchor, constant: 20),
                                     weekdaysStackView.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 8),
                                     weekdaysStackView.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -8),
                                     weekdaysStackView.heightAnchor.constraint(equalToConstant: 14)])
    }
    
    private func addCalendarView() {
        calendarView = CalendarView.init(numberOfYears: 2, hidesDatesFromOtherMonth: true, disabledBeforeToday: true, style: calendarStyle).noAutoresizingMask()
        calendarView.calendarDelegate = self
        let selectedDates: CalendarView.Selection = CalendarView.Selection(startDate: Date(), endDate: Date())
        calendarView.setDateSelection(selectedDates)
        view.addSubview(calendarView)
        let layoutGuide = view.safeAreaLayoutGuide

        NSLayoutConstraint.activate([
            calendarView.topAnchor.constraint(equalTo: weekdaysStackView.bottomAnchor),
            calendarView.leftAnchor.constraint(equalTo: layoutGuide.leftAnchor, constant: 8.0),
            calendarView.rightAnchor.constraint(equalTo: layoutGuide.rightAnchor, constant: -8.0),
            calendarView.bottomAnchor.constraint(equalTo: layoutGuide.bottomAnchor, constant: -8.0)
        ])
    }
    
    func calendarDidChangeSelection(_ selection: CalendarView.Selection) {
        print(selection)
    }
}

