//
//  LocalizedDateFormatter.swift
//  CalendarView
//
//  Created by Dhanuka, Tejas | ECMPD on 2020/07/21.
//  Copyright © 2020 Tejas Dhanuka. All rights reserved.
//

import Foundation

// MARK: - Formatter shortcuts

public class LocalizedDateFormatter {
    class var gmt: Bool { return false }
   
    // Stadard Date Formatters
    public static func long(_ components: [LocalizedDateFormatterComponent] = [.date], language: Language = .current) -> DateFormatter {
        return LongLocalizedDateFormatter.instance.dateFormatter(for: language, gmt: gmt, components: components)
    }
    public static func middle(_ components: [LocalizedDateFormatterComponent] = [.date], language: Language = .current) -> DateFormatter {
        return MiddleLocalizedDateFormatter.instance.dateFormatter(for: language, gmt: gmt, components: components)
    }
    public static func short(_ components: [LocalizedDateFormatterComponent] = [.date], language: Language = .current) -> DateFormatter {
        return ShortLocalizedDateFormatter.instance.dateFormatter(for: language, gmt: gmt, components: components)
    }
    
    public class Gmt: LocalizedDateFormatter {
        override class var gmt: Bool { return true }
    }
}

// MARK: Localized Date Formatter Protocol

private struct LocalizedDateFormatterKeys {
    static var formatterAssociatedKey = "LocalizedDateFormatterKeys.associated.formatter"
}

public enum LocalizedDateFormatterComponent {
    case date, time
    case year, month, day
}

class LocalizedDateFormatterStorage {
    var formatters: [String: DateFormatter] = [:]
}

public protocol LocalizedDateFormatterProvider: DefaultAssociatedObjectHolder {
    static var instance: LocalizedDateFormatterProvider { get }
    func plainFormat(for language: Language, components: [LocalizedDateFormatterComponent]) -> String?
    func year(for language: Language) -> String
    func month(for language: Language) -> String
    func day(for language: Language) -> String
    func hour(for language: Language) -> String?
    func minute(for language: Language) -> String?
    func seconds(for language: Language) -> String?
    func timeSuffix(for language: Language) -> String?
}

public extension LocalizedDateFormatterProvider {
    static var formatter: DateFormatter {
        return instance.dateFormatter()
    }
    
    internal var formatterStorage: LocalizedDateFormatterStorage {
        getDefaultAssociatedObject(key: &LocalizedDateFormatterKeys.formatterAssociatedKey) {
            LocalizedDateFormatterStorage()
        }
    }
    
    func dateFormatter(for language: Language = .current, gmt: Bool = false, locale: Locale = Locale.current, components: [LocalizedDateFormatterComponent] = [.date]) -> DateFormatter {
        if let storedFormatter = storedFormatter(gmt: gmt, components: components) {
            return storedFormatter
        }

        let formatter = DateFormatter()
        formatter.calendar = locale.calendar
        
        if let plainFormatterTemplate = plainFormat(for: language, components: components) {
            formatter.dateFormat = plainFormatterTemplate
        } else {
            let template = formatWithComponents(components, language: language)
            formatter.dateFormat = DateFormatter.dateFormat(fromTemplate: template, options: 0, locale: locale)
        }
        
        formatterStorage.formatters[storageKey(gmt: gmt, components: components)] = formatter
        
        return formatter
    }
    
    private func storageKey(gmt: Bool, components: [LocalizedDateFormatterComponent]) -> String {
        var key = ""
        
        if components.contains(.date) {
            key += "-date"
        }
        if components.contains(.time) {
            key += "-time"
        }
        if components.contains(.year) {
            key += "-year"
        }
        if components.contains(.month) {
            key += "-month"
        }
        if components.contains(.day) {
            key += "-day"
        }
        if gmt {
            key += "-GMT"
        }
        
        return key
    }
    
    private func storedFormatter(gmt: Bool, components: [LocalizedDateFormatterComponent]) -> DateFormatter? {
        formatterStorage.formatters[storageKey(gmt: gmt, components: components)]
    }
    
    private func formatWithComponents(_ components: [LocalizedDateFormatterComponent], language: Language) -> String {
        if components.count == 1 {
            if components.first == .date {
                return dateSubFormat(language: language)
            } else if components.first == .time {
                return timeSubFormat(language: language)
            }
        }
        if components.contains(.date) && components.contains(.time) {
            return "\(dateSubFormat(language: language)) \(timeSubFormat(language: language))"
        }
        
        var format = ""
        for component in components {
            switch component {
            case .year:
                format += "\(format.isEmpty ? "" : "-")\(year(for: language))"
            case .month:
                format += "\(format.isEmpty ? "" : "-")\(month(for: language))"
            case .day:
                format += "\(format.isEmpty ? "" : "-")\(day(for: language))"
            case .time:
                format += "\(format.isEmpty ? "" : " ")\(timeSubFormat(language: language))"
            default: break
            }
        }
        return format
    }
    
    private func dateSubFormat(language: Language) -> String {
        "\(year(for: language))-\(month(for: language))-\(day(for: language)))"
    }
    
    private func timeSubFormat(language: Language) -> String {
        var time = ""
        if let hourFormat = hour(for: language) {
            time += hourFormat
        }
        if let minuteFormat = minute(for: language) {
            time += ":\(minuteFormat)"
        }
        if let secondsFormat = seconds(for: language) {
            time += ":\(secondsFormat)"
        }
        if let timeSuffixFormat = timeSuffix(for: language) {
            time += " \(timeSuffixFormat)"
        }
        return time
    }
    
    func plainFormat(for language: Language, components: [LocalizedDateFormatterComponent]) -> String? {
        return nil
    }
}

// MARK: - Specialized Formatter Implementation for World Readiness

public class LongLocalizedDateFormatter: LocalizedDateFormatterProvider {
    public static let instance: LocalizedDateFormatterProvider = LongLocalizedDateFormatter()
    
    public func year(for language: Language) -> String {
        "yyyy"
    }
    public func month(for language: Language) -> String {
        switch language {
        case .zhHans, .zhHantHK, .zhHantTW, .zhHantMO, .ko, .ja:
            return "M"
        default:
            return "MMMM"
        }
    }
    public func day(for language: Language) -> String {
        switch language {
        case .zhHans, .zhHantHK, .zhHantTW, .zhHantMO, .ko, .ja, .th, .enSG, .enAU, .fr, .de, .it:
            return "d"
        default: return "dd"
        }
    }
    public func hour(for language: Language) -> String? {
        switch language {
        case .zhHantTW:
            return "hh"
        case .ko, .enSG, .enUS, .enAU, .enCA, .enPH, .vi:
            return "h"
        case .enUK, .fr, .de, .id, .it:
            return "HH"
        default:
            return "H"
        }
    }
    public func minute(for language: Language) -> String? {
        "mm"
    }
    public func seconds(for language: Language) -> String? {
        "ss"
    }
    public func timeSuffix(for language: Language) -> String? {
        switch language {
        case .zhHantTW, .ko, .enSG, .enUS, .enAU, .enCA, .enPH, .vi:
            return "tt"
        default:
            return nil
        }
    }
    public func plainFormat(for language: Language, components: [LocalizedDateFormatterComponent]) -> String? {
        if language != .ko { return nil }
        if components.count == 1 {
            if components.first == .date {
                return "Y년M월d일"
            } else if components.first == .time {
                return "tt h:mm:ss"
            }
        }
        if components.contains(.date) && components.contains(.time) {
            return "Y년M월d일 tt h:mm:ss"
        }
        
        var format = ""
        if components.contains(.year) {
            format += "Y년"
        }
        if components.contains(.month) {
            format += "M월"
        }
        if components.contains(.day) {
            format += "d일"
        }
        if components.contains(.time) {
            format += " tt h:mm:ss"
        }
        return format
    }
}

public class MiddleLocalizedDateFormatter: LocalizedDateFormatterProvider {
    public static let instance: LocalizedDateFormatterProvider = MiddleLocalizedDateFormatter()
    
    public func year(for language: Language) -> String {
        "yyyy"
    }
    public func month(for language: Language) -> String {
        switch language {
        case .zhHans, .zhHantHK, .zhHantTW, .zhHantMO, .ko, .ja:
            return "M"
        default:
            return "MMM"
        }
    }
    public func day(for language: Language) -> String {
        switch language {
        case .zhHans, .zhHantHK, .zhHantTW, .zhHantMO, .ko, .ja, .fr, .it:
            return "d"
        default: return "dd"
        }
    }
    public func hour(for language: Language) -> String? {
        switch language {
        case .zhHantTW:
            return "hh"
        case .ko, .enSG, .enUS, .enAU, .enCA, .enPH, .vi:
            return "h"
        case .enUK, .fr, .de, .id, .it:
            return "HH"
        default:
            return "H"
        }
    }
    public func minute(for language: Language) -> String? {
        "mm"
    }
    public func seconds(for language: Language) -> String? {
        nil
    }
    public func timeSuffix(for language: Language) -> String? {
        switch language {
        case .zhHantTW, .ko, .enSG, .enUS, .enAU, .enCA, .enPH, .vi:
           return "tt"
        default:
           return nil
        }
    }
    public func plainFormat(for language: Language, components: [LocalizedDateFormatterComponent]) -> String? {
        if language != .ko { return nil }
        if components.count == 1 {
            if components.first == .date {
                return "Y년M월d일"
            } else if components.first == .time {
                return "tt h:mm"
            }
        }
        if components.contains(.date) && components.contains(.time) {
            return "Y년M월d일 tt h:mm"
        }
        
        var format = ""
        if components.contains(.year) {
            format += "Y년"
        }
        if components.contains(.month) {
            format += "M월"
        }
        if components.contains(.day) {
            format += "d일"
        }
        if components.contains(.time) {
            format += " tt h:mm"
        }
        return format
    }
}

public class ShortLocalizedDateFormatter: LocalizedDateFormatterProvider {
    public static let instance: LocalizedDateFormatterProvider = ShortLocalizedDateFormatter()
    
    public func year(for language: Language) -> String {
        "yyyy"
    }
    public func month(for language: Language) -> String {
        switch language {
        case .zhHans, .zhHantHK, .zhHantTW, .th, .enUS, .enSG, .zhHantMO, .fil:
            return "M"
        default:
            return "MM"
        }
    }
    public func day(for language: Language) -> String {
        switch language {
        case .zhHans, .zhHantHK, .zhHantTW, .th, .enUS, .enSG, .enAU, .zhHantMO, .de, .fil:
            return "d"
        default: return "dd"
        }
    }
    public func hour(for language: Language) -> String? {
        switch language {
        case .zhHantTW:
            return "hh"
        case .ko, .enSG, .enUS, .enAU, .enCA, .enPH, .vi:
            return "h"
        case .enUK, .fr, .de, .id, .it:
            return "HH"
        default:
            return "H"
        }
    }
    public func minute(for language: Language) -> String? {
        "mm"
    }
    public func seconds(for language: Language) -> String? {
        nil
    }
    public func timeSuffix(for language: Language) -> String? {
        switch language {
        case .zhHantTW, .ko, .enSG, .enUS, .enAU, .enCA, .enPH, .vi:
           return "tt"
        default:
           return nil
        }
    }
}

// MARK: - Other formats

public class CreditCardDateFormatter {
    public static let formatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "MM/YY"
        return formatter
    }()
}

public class ServerDateFormatter {
    class var gmt: Bool { return false }
    
    public static let instance = formatter(format: "yyyy-MM-dd'T'HH:mm:ss")
    public static let timeHMOnlyInstance = formatter(format: "HH:mm")
    public static let timeOnlyInstance = formatter(format: "HH:mm:ss")
    public static let dateOnlyInstance = formatter(format: "yyyy-MM-dd")
    public static let isoInstance = ISO8601DateFormatter()
    
    private static func formatter(format: String) -> DateFormatter {
        let formatter = DateFormatter()
        if gmt {
            formatter.timeZone = TimeZone(secondsFromGMT: 0)
        }
        formatter.dateFormat = format
        return formatter
    }
    
    public class Gmt: ServerDateFormatter {
        override class var gmt: Bool { return true }
    }
}
