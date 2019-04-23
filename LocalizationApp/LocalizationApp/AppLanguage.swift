//
//  AppLanguage.swift
//  LocalizationApp
//
//  Created by Chethan on 22/04/19.
//  Copyright © 2019 Chethan. All rights reserved.
//

import Foundation
import UIKit

// Enum lists the localization languages supported by the app
enum SupportedLocalizationLanguage: String {
    case english = "en"
    case arabic = "ar"
    
    func isRTL() -> Bool {
        switch self {
        case .english:
            return false
        case .arabic:
            return true
        }
    }
}

// MARK: - Localizer
// Uses method swizzling to support in-app language change
class Localizer: NSObject {
    class func performIntitalSetup() {
        MethodSwizzleForClassName(Bundle.self, originalSelector: #selector(Bundle.localizedString(forKey:value:table:)), overrideSelector: #selector(Bundle.specialLocalizedStringForKey(_:value:table:)))
        MethodSwizzleForClassName(UIApplication.self, originalSelector: #selector(getter: UIApplication.userInterfaceLayoutDirection), overrideSelector: #selector(getter: UIApplication.customUserInterfaceLayoutDirection))
        
        // Setting preferred lang to set semanticContentAttribute on every launch
        PreferredLanguage.setCurrentLanguageTo(PreferredLanguage.currentLanguage())
    }
}

extension UIApplication {
    class func isRTL() -> Bool{
        return UIApplication.shared.userInterfaceLayoutDirection == .rightToLeft
    }
    
    @objc var customUserInterfaceLayoutDirection : UIUserInterfaceLayoutDirection {
        get {
            var layoutDirection = UIUserInterfaceLayoutDirection.leftToRight
            if let supportedLanguage = SupportedLocalizationLanguage(rawValue: PreferredLanguage.currentLanguage()), supportedLanguage.isRTL() {
                layoutDirection = .rightToLeft
            }
            
            return layoutDirection
        }
    }
}

extension Bundle {
    @objc func specialLocalizedStringForKey(_ key: String, value: String?, table tableName: String?) -> String {
        if self == Bundle.main {
            let resourcePath = Bundle.main.path(forResource: PreferredLanguage.currentLanguageFull(), ofType: "lproj") ??
                Bundle.main.path(forResource: PreferredLanguage.currentLanguage(), ofType: "lproj") ??
                Bundle.main.path(forResource: "Base", ofType: "lproj")
            
            if let resourcePath = resourcePath,
                let bundle = Bundle(path: resourcePath) {
                return (bundle.specialLocalizedStringForKey(key, value: value, table: tableName))
            }
            
            // If not found, return original key
            return key
        } else {
            return (self.specialLocalizedStringForKey(key, value: value, table: tableName))
        }
    }
}

/// Exchange the implementation of two methods of the same Class
func MethodSwizzleForClassName(_ className: AnyClass, originalSelector: Selector, overrideSelector: Selector) {
    if let originalMethod: Method = class_getInstanceMethod(className, originalSelector),let overridenMethod: Method = class_getInstanceMethod(className, overrideSelector) {
        if (class_addMethod(className, originalSelector, method_getImplementation(overridenMethod), method_getTypeEncoding(overridenMethod))) {
            class_replaceMethod(className, overrideSelector, method_getImplementation(originalMethod), method_getTypeEncoding(originalMethod));
        } else {
            method_exchangeImplementations(originalMethod, overridenMethod);
        }
    }

}

// MARK: - PreferredLanguage
// This class defines handy methods to get/set current selected language
class PreferredLanguage {
    
    private static let CurrentLanguageKey = "CurrentLanguage"
    
    class func setInitialPreferredLanguageIfNotSet() { // If preferred language is not set, read system language
        if currentLanguage().isEmpty {
            if let languages = UserDefaults.standard.object(forKey: "AppleLanguages") as? NSArray,
                let firstLang = languages.firstObject as? String {
                setCurrentLanguageTo(firstLang)
            } else {
                setCurrentLanguageTo(SupportedLocalizationLanguage.english.rawValue)
            }
        }
    }
    
    // Returns current language without locale
    class func currentLanguage() -> String {
        let current = currentLanguageFull()
        let endIndex = current.startIndex
        return current.characters.count > 2 ? current.substring(to: current.index(endIndex, offsetBy: 2)) : current
    }
    
    // Returns current language with locale if present
    class func currentLanguageFull() -> String {
        let languageArray = UserDefaults.standard.object(forKey: CurrentLanguageKey) as? NSArray
        let current = languageArray?.firstObject as? String
        return current ?? ""
    }
    
    // Use this method to change preferred language in app.
    class func setCurrentLanguageTo(_ language: String) {
        let userDefaults = UserDefaults.standard
        userDefaults.set([language], forKey: CurrentLanguageKey)
        userDefaults.synchronize()
        
        if let supportedLocalizationLanguage = SupportedLocalizationLanguage(rawValue: language) {
            let semanticContentAttribute: UISemanticContentAttribute = supportedLocalizationLanguage.isRTL() ?
                .forceRightToLeft :
                .forceLeftToRight
            UIView.appearance().semanticContentAttribute = semanticContentAttribute
        }
    }
    
    class var isRTL: Bool {
        if let supportedLanguage = SupportedLocalizationLanguage(rawValue: PreferredLanguage.currentLanguage()), supportedLanguage.isRTL() {
            return true
        }
        
        return false
    }
}

