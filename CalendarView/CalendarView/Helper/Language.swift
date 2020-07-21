//
//  Language.swift
//  CalendarView
//
//  Created by Dhanuka, Tejas | ECMPD on 2020/07/21.
//  Copyright © 2020 Tejas Dhanuka. All rights reserved.
//

import Foundation

public enum Language: String {
    
    // Language codes based on World Readiness
    case en = "en"
    case enUS = "en-US"             // English (US)
    case enSG = "en-SG"             // English (SG)
    case enAU = "en-AU"             // English (AU)
    case enCA = "en-CA"             // English (CA)
    case enUK = "en-GB"             // English (GB)
    case enPH = "en-PH"             // English (PH)
    case enIN = "en-IN"             // English (IN)
    case enMY = "en-MY"             // English (MY)
    case enJP = "en-JP"             // English (JP)
    case enKR = "en-KR"             // English (Korea)
    case enCN = "en-CN"             // English (China)
    case enTW = "en-TW"             // English (Taiwan)
    case enHK = "en-HK"             // English (Hongkong)
    case enMO = "en-MO"             // English (Macao)
    case ja = "ja"                  // Japanese
    case zhHant = "zh-Hant"         // Chinese (Traditional, Default)
    case zhHans = "zh-Hans"         // Chinese (Simplified, China)
    case zhHantTW = "zh-Hant-TW"    // Chinese (Traditional, Taiwan)
    case zhHantHK = "zh-HK"         // Chinese (Traditional, HongKong)
    case zhHantMO = "zh-Hant-MO"    // Chinese (Traditional, Macao)
    case ko = "ko"                  // Korean
    case th = "th"                  // Thai
    case id = "id"                  // Indian
    case fr = "fr"                  // French
    case de = "de"                  // German
    case it = "it"                  // Italian
    case vi = "vi"                  // Vietnamese
    case es = "es"                  // Spanish
    case ms = "ms"                  // Malaysia
    case fil = "fil"                // Phillippines
    
    // MARK: Properties
    
    private static let defaultUnlocalizedLanguages: [String: Language] = [
        "zh-Hant": .zhHantTW
    ]
    
    // MARK: Public methods
    
    public static var current: Language {
        let preferredLanguages = Locale.preferredLanguages
        if preferredLanguages.count == 0 { return defaultLanguage }
        
        let preferredLanguage = preferredLanguages.first ?? ""
        return Language(rawValue: preferredLanguage) ??
            languageForStrippedCode(languageCode: languageCodeByStrippingLocale(originalLanguageCode: preferredLanguage)) ??
            defaultLanguage
    }
    public static func language(forCode code: String, transform: LanguageTransform) -> Language {
        return transform.languageCode(externalCode: code)
    }
    public static func externalCode(forLanguage language: Language, transform: LanguageTransform) -> String {
        return transform.externalCode(languageCode: language)
    }
    
    // MARK: Private methods
    
    private static var defaultLanguage: Language {
        return .en
    }
    private static func languageCodeByStrippingLocale(originalLanguageCode: String) -> String {
        var components = originalLanguageCode.split(separator: "-")
        components.removeLast()
        
        return components.joined(separator: "-")
    }
    private static func languageForStrippedCode(languageCode: String) -> Language? {
        return Language(rawValue: languageCode) ?? defaultUnlocalizedLanguages[languageCode]
    }
}

public protocol LanguageTransform {
    func languageCode(externalCode: String) -> Language
    func externalCode(languageCode: Language) -> String
}

public class BackendLanguageTransform: LanguageTransform {
    public init() {}
    
    let languageMapper: [String: Language] = [
        "zh-hk": .zhHantHK,
        "zh-tw": .zhHantTW,
        "ja": .ja,
        "en-us": .enUS,
        "th": .th,
        "zh-cn": .zhHans,
        "en-sg": .enSG,
        "en": .enUS,
        "en-au": .enAU,
        "id-id": .id,
        "en-ca": .enCA,
        "en-br": .enUK,
        "fr-fr": .fr,
        "zh-mo": .zhHantMO,
        "de": .de,
        "it": .it,
        "vi": .vi,
        "es": .es
    ]
    
    public func languageCode(externalCode: String) -> Language {
        return languageMapper[externalCode] ?? .enUS
    }
    
    public func externalCode(languageCode: Language) -> String {
        if languageCode == .enUS {
            return "en"
        }
        
        for key in languageMapper.keys where languageMapper[key] == languageCode {
            return key
        }
        return "en"
    }
}
