//
//  CalendarDateExtensions.swift
//  CalendarView
//
//  Created by Dhanuka, Tejas | ECMPD on 2020/07/17.
//  Copyright © 2020 Tejas Dhanuka. All rights reserved.
//

import Foundation

extension Date {
    init(year: Int, month: Int, day: Int) {
        self = Calendar.current.date(from: DateComponents(year: year, month: month, day: day)) ?? Date()
    }

    func dateByAddingMonths(_ months : Int) -> Date {
        var dateComponent = DateComponents()
        dateComponent.month = months
        return Calendar.current.date(byAdding: dateComponent, to: self) ?? self
    }
    
    func dateByAddingDays(_ days : Int ) -> Date {
        var dateComponent = DateComponents()
        dateComponent.day = days
        return Calendar.current.date(byAdding: dateComponent, to: self) ?? self
    }
    
    func numberOfDaysInMonth() -> Int {
        let calendar = Calendar.current
        let days = (calendar as NSCalendar).range(of: NSCalendar.Unit.day, in: NSCalendar.Unit.month, for: self)
        return days.length
    }
    
    func weekday() -> Int {
        let calendar = Calendar.current
        let dateComponent = (calendar as NSCalendar).components(.weekday, from: self)
        return dateComponent.weekday ?? 1
    }

    func dateWithoutTime() -> Date {
        let components = Calendar.current.dateComponents([.year, .month, .day], from: self)
        return Calendar.current.date(from: components) ?? Date()
    }
    
    func monthDifference(toDate date: Date) -> Int {
        let calendar = Calendar.current
        let component = calendar.dateComponents([.month], from: self, to: date)
        return component.month ?? 1
    }
    
    func dayDifference(toDate date: Date) -> Int {
        let calendar = Calendar.current
        let component = calendar.dateComponents([.day], from: self, to: date)
        return component.day ?? 1
    }
}
