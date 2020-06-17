import Foundation

enum Language: String {
    case en
    
    static var allLanguages: Array<Language> {
        return [.en]
    }
}


class LanguageManager {
    
    private struct Defaults {
        static let keyCurrentLanguage = "KeyCurrentLanguage"
    }
    
    static let shared:LanguageManager = LanguageManager()
    
    static var appLanguages: Array<Language> = Language.allLanguages
    
    var languageCode: String {
        get {
            return language.rawValue
        }
    }
    
    var currentLanguage:Language {
        get {
            var currentLanguage = UserDefaults.standard.object(forKey: Defaults.keyCurrentLanguage)
            if currentLanguage == nil {
                currentLanguage = Locale.preferredLanguages[0]
            }
            
            if let currentLanguage = currentLanguage as? String,
                let lang = Language(rawValue: currentLanguage.truncate(length: 2)) {
                return lang
            }
            return Language.en
        }
    }
    
    func switchToLanguage(_ lang:Language, notify:Bool = false) {
        language = lang
    }
    
    func clearLanguages() {
        UserDefaults.standard.setValue(nil, forKey:Defaults.keyCurrentLanguage)
    }
    
    private var localeBundle:Bundle?
    
    func getLocalBundle() -> Bundle {
        if let bundle = localeBundle {
            return bundle
        } else {
            return .main
        }
    }
    
    fileprivate var language: Language = Language.en {
        didSet {
            let currentLanguage = language.rawValue
            UserDefaults.standard.setValue(currentLanguage, forKey:Defaults.keyCurrentLanguage)
            UserDefaults.standard.synchronize()
            
            setLocaleWithLanguage(currentLanguage)
        }
    }
    
    // MARK: - LifeCycle
    
    private init() {
        prepareDefaultLocaleBundle()
    }
    
    //MARK: - Private
    
    private func prepareDefaultLocaleBundle() {
        var currentLanguage = UserDefaults.standard.object(forKey: Defaults.keyCurrentLanguage)
        if currentLanguage == nil {
            currentLanguage = Locale.preferredLanguages[0]
        }
        
        if let currentLanguage = currentLanguage as? String {
            updateCurrentLanguageWithName(currentLanguage)
        }
    }
    
    private func updateCurrentLanguageWithName(_ languageName: String) {
        if let lang = Language(rawValue: languageName) {
            language = lang
        }
    }
    
    private func setLocaleWithLanguage(_ selectedLanguage: String) {
        if let pathSelected = Bundle.main.path(forResource: selectedLanguage, ofType: "lproj"),
            let bundleSelected = Bundle(path: pathSelected)  {
            localeBundle = bundleSelected
        } else if let pathDefault = Bundle.main.path(forResource: Language.en.rawValue, ofType: "lproj"),
            let bundleDefault = Bundle(path: pathDefault) {
            localeBundle = bundleDefault
        }
    }
}

extension String {
    func truncate(length: Int, trailing: String = "") -> String {
        return (self.count > length) ? self.prefix(length) + trailing : self
    }
}
