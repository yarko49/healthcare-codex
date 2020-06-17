import Foundation

internal enum Str {
    internal static let email = Languages.tr("EMAIL")
    internal static let password = Languages.tr("PASSWORD")
    internal static let confirmPassword = Languages.tr("CONFIRM_PASSWORD")
    internal static let login = Languages.tr("LOG_IN")
    internal static let register = Languages.tr("REGISTER")
    internal static let logout = Languages.tr("LOG_OUT")
    internal static let loginCTA = Languages.tr("LOG_IN_CTA")
    internal static let registerCTA = Languages.tr("REGISTER_CTA")
    internal static let home = Languages.tr("HOME")
    internal static let hello = Languages.tr("HELLO")
    internal static let settings = Languages.tr("SETTINGS")
    internal static func helloName(_ arg: String) -> String {
        return Languages.tr("HELLO_NAME", [arg])
    }
    internal static let close = Languages.tr("CLOSE")
}

