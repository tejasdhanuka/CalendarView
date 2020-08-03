//
//  ViewController.swift
//  CalendarView
//
//  Created by Dhanuka, Tejas | ECMPD on 2020/07/16.
//  Copyright © 2020 Tejas Dhanuka. All rights reserved.
//

import UIKit
import Foundation

class ViewController: UIViewController, CalendarViewDelegate, UIPickerViewDelegate, UIPickerViewDataSource, UITextFieldDelegate {
    
    private var calendarView: CalendarView!
    private var weekdaysStackView: UIStackView!
    private var separatorView: UIView!
    private var calendarContainerView: UIView!
    private var yearTextField: UITextField!
    private var yearPickerView: UIPickerView!
    
    var years : [String] {
        var years = [String]()
        for i in (1921..<2020).reversed() {
            years.append("\(i)")
        }
        return years
    }
    
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
        setupDatePickerView()
        setupCalendarContainerView()
    }
    
    private func setupDatePickerView() {
        yearPickerView = UIPickerView().noAutoresizingMask()
        yearTextField = UITextField().noAutoresizingMask()
        view.addSubview(yearPickerView)
        view.addSubview(yearTextField)
        
        // autolayout constraint
        NSLayoutConstraint.activate([yearTextField.topAnchor.constraint(equalTo: view.topAnchor, constant: 40.0),
                                     yearTextField.leftAnchor.constraint(equalTo: view.leftAnchor),
                                     yearTextField.rightAnchor.constraint(equalTo: view.rightAnchor),
                                     yearTextField.heightAnchor.constraint(equalToConstant: 20.0)])
        
        // autolayout constraint
        NSLayoutConstraint.activate([yearPickerView.topAnchor.constraint(equalTo: yearTextField.bottomAnchor),
                                     yearPickerView.leftAnchor.constraint(equalTo: view.leftAnchor),
                                     yearPickerView.rightAnchor.constraint(equalTo: view.rightAnchor),
                                     yearTextField.heightAnchor.constraint(equalToConstant: 240.0)])
        
        yearTextField.delegate = self
        yearTextField.text = years[0]
        yearTextField.textAlignment = .center
        
        yearPickerView.delegate = self
        yearPickerView.isHidden = true
    }
    
    private func setupCalendarContainerView() {
        calendarContainerView = UIView().noAutoresizingMask()
        view.addSubview(calendarContainerView)
        // autolayout constraint
        NSLayoutConstraint.activate([calendarContainerView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
                                     calendarContainerView.leftAnchor.constraint(equalTo: view.leftAnchor),
                                     calendarContainerView.rightAnchor.constraint(equalTo: view.rightAnchor),
                                     calendarContainerView.heightAnchor.constraint(equalToConstant: 420.0)])
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
        calendarContainerView.addSubview(weekdaysStackView)
        
        // autolayout constraint
        NSLayoutConstraint.activate([weekdaysStackView.topAnchor.constraint(equalTo: calendarContainerView.topAnchor, constant: 30),
                                     weekdaysStackView.leftAnchor.constraint(equalTo: calendarContainerView.leftAnchor, constant: 8),
                                     weekdaysStackView.rightAnchor.constraint(equalTo: calendarContainerView.rightAnchor, constant: -8),
                                     weekdaysStackView.heightAnchor.constraint(equalToConstant: 25)])
    }
    
    private func addSeparatorView() {
        separatorView = UIView().noAutoresizingMask()
        separatorView.backgroundColor = UIColor.red
        
        view.addSubview(separatorView)
        // autolayout constraint
        NSLayoutConstraint.activate([separatorView.topAnchor.constraint(equalTo: weekdaysStackView.bottomAnchor),
                                     separatorView.leftAnchor.constraint(equalTo: calendarContainerView.leftAnchor, constant: 8),
                                     separatorView.rightAnchor.constraint(equalTo: calendarContainerView.rightAnchor, constant: -8),
                                     separatorView.heightAnchor.constraint(equalToConstant: 1)])
    }
    
    private func addCalendarView() {
        calendarView = CalendarView.init(numberOfMonths: 1,
                                         hidesDatesFromOtherMonth: true,
                                         disabledBeforeToday: false,
                                         style: calendarStyle).noAutoresizingMask()
        calendarView.calendarDelegate = self
        let selectedDates: CalendarView.Selection = CalendarView.Selection(startDate: Date(), endDate: nil)
        calendarView.setDateSelection(selectedDates)
        view.addSubview(calendarView)
        
        NSLayoutConstraint.activate([
            calendarView.topAnchor.constraint(equalTo: separatorView.bottomAnchor, constant: 2.0),
            calendarView.leftAnchor.constraint(equalTo: calendarContainerView.leftAnchor, constant: 8.0),
            calendarView.rightAnchor.constraint(equalTo: calendarContainerView.rightAnchor, constant: -8.0),
            calendarView.bottomAnchor.constraint(equalTo: calendarContainerView.bottomAnchor, constant: -8.0)
        ])
    }
    
    // returns the number of 'columns' to display.
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    // returns the # of rows in each component..
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return years.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return years[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int)
    {
        yearTextField.text = years[row]
        yearPickerView.isHidden = true
    }
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        calendarView = nil
        calendarView = CalendarView.init(numberOfMonths: 2,
                                         hidesDatesFromOtherMonth: true,
                                         disabledBeforeToday: true,
                                         style: calendarStyle).noAutoresizingMask()
        yearPickerView.isHidden = false
        return false
    }
    
    func calendarDidChangeSelection(_ selection: CalendarView.Selection) {
        print(selection)
    }
}

