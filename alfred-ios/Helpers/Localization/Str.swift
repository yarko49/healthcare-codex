import Foundation

internal enum Str {
    internal static let email = Languages.tr("EMAIL")
    internal static let password = Languages.tr("PASSWORD")
    internal static let confirmPassword = Languages.tr("CONFIRM_PASSWORD")
    internal static let confirmEmailAddress = Languages.tr("CONFIRM_EMAIL_ADDRESS")
    internal static let login = Languages.tr("LOG_IN")
    internal static let register = Languages.tr("REGISTER")
    internal static let loginCTA = Languages.tr("LOG_IN_CTA")
    internal static let registerCTA = Languages.tr("REGISTER_CTA")
    internal static let home = Languages.tr("HOME")
    internal static let hello = Languages.tr("HELLO")
    internal static func helloName(_ arg: String) -> String {
        return Languages.tr("HELLO_NAME", [arg])
    }
    internal static let close = Languages.tr("CLOSE")
    internal static let cancel = Languages.tr("CANCEL")
    internal static let signInWithGoogle = Languages.tr("SIGN_IN_WITH_GOOGLE")
    internal static let signInWithApple = Languages.tr("SIGN_IN_WITH_APPLE")
    internal static let signup = Languages.tr("SIGN_UP")
    internal static let signInWithYourEmail = Languages.tr("SIGN_IN_WITH_YOUR_EMAIL")
    internal static let forgotPassword = Languages.tr("FORGOT_PASSWORD")
    internal static let signin = Languages.tr("SIGN_IN")
    internal static let save = Languages.tr("SAVE")
    internal static let welcomeBack = Languages.tr("WELCOME_BACK")
    internal static let resetMessage = Languages.tr("WE_WILL_EMAIL_YOU_A_LINK_TO_RESET_YOUR_PASSWORD")
    // Profile stats
    internal static let today = Languages.tr("TODAY")
    internal static let wk = Languages.tr("WK")
    internal static let mo = Languages.tr("MO")
    internal static let yr = Languages.tr("YR")
    internal static let high = Languages.tr("HIGH")
    internal static let low = Languages.tr("LOW")
    internal static let dailyAverage = Languages.tr("DAILY_AVERAGE")
    internal static let monthlyAverage = Languages.tr("MONTHLY_AVERAGE")
    internal static let weeklyAverage = Languages.tr("WEEKLY_AVERAGE")
    internal static let yearlyAverage = Languages.tr("YEARLY_AVERAGE")
    internal static let weight = Languages.tr("WEIGHT")
    internal static let activity = Languages.tr("ACTIVITY")
    internal static let bloodPressure = Languages.tr("BLOOD_PRESSURE")
    internal static let restingHR = Languages.tr("RESTING_HEART_RATE")
    internal static let heartRate = Languages.tr("HEART_RATE")
    
    // Onboarding
    internal static let slide1Title = Languages.tr("SLIDE_1_TITLE")
    internal static let slide1Desc = Languages.tr("SLIDE_1_DESC")
    internal static let slide2Title = Languages.tr("SLIDE_2_TITLE")
    internal static let slide2Desc = Languages.tr("SLIDE_2_DESC")
    internal static let slide3Title = Languages.tr("SLIDE_3_TITLE")
    internal static let slide3Desc = Languages.tr("SLIDE_3_DESC")
    internal static let alreadyHaveAccount = Languages.tr("ALREADY_HAVE_ACCOUNT")
    internal static let acceptingTSPP = Languages.tr("BY_REGISTERING_I_ACCEPT_THE_TERMS_OF_SERVICES_AND_PRIVACY_POLICY")
    internal static let signupmsg = Languages.tr("SIGN_UP_FOR_ALFRED_WITH_YOUR_EMAIL")
    
    // Sign up
    internal static let invalidConfirmationEmail = Languages.tr("FAILED_TO_CONFIRM_EMAIL")
     
    //  - Profile
    internal static let myProfile = Languages.tr("MY_PROFILE")
    internal static let gender = Languages.tr("GENDER_IDENTITY")
    internal static let sex = Languages.tr("SEX")
    internal static let male = Languages.tr("MALE")
    internal static let female = Languages.tr("FEMALE")
    internal static let trans = Languages.tr("TRANS")
    internal static let cis = Languages.tr("CIS")
    internal static let next = Languages.tr("NEXT")
    internal static let information = Languages.tr("THIS_INFORMATION_HELPS_US_PROVIDE_CUSTOM_RECOMMENDATIONS")
    internal static let dob = Languages.tr("DATE_OF_BIRTH")
    internal static let height = Languages.tr("HEIGHT")
    
    // Sign In
    internal static let longResetMessage = Languages.tr("IF_YOUR_ACCOUNT_IS_ASSOCIATED_WITH_THIS_EMAIL_ADDRESS_YOU_WILL_RECEIVE_AN_EMAIL_TO_RESET_YOUR_PASSWORD_IF_YOU_DON'T_PLEASE_TRY_ANOTHER_EMAIL_ADDRESS")
    internal static let backToSignIn = Languages.tr("BACK_TO_SIGN_IN")
    internal static let invalidEmail = Languages.tr("INVALID_EMAIL_ADDRESS")
    internal static let invalidPw = Languages.tr("INVALID_PASSWORD")
    internal static let enterEmail = Languages.tr("PLEASE_ENTER_EMAIL_ADDRESS")
    internal static let enterPw = Languages.tr("PLEASE_ENTER_PASSWORD")
    internal static let ok = Languages.tr("OK")

    //Profile
    internal static let edit = Languages.tr("EDIT")
    internal static let profile = Languages.tr("PROFILE")
    internal static let healthy = Languages.tr("HEALTHY")
    internal static let heavy = Languages.tr("HEAVY")
    internal static let obese = Languages.tr("OBESE")
    internal static let light = Languages.tr("LIGHT")
    internal static let moderate = Languages.tr("MODERATE")
    internal static let vigorous = Languages.tr("VIGOROUS")
    internal static let normal = Languages.tr("NORMAL")
    internal static let elevated = Languages.tr("ELEVATED")
    internal static let hypertension1 = Languages.tr("HYPERTENSION_(STAGE_1)")
    internal static let hypertension2 = Languages.tr("HYPERTENSION_(STAGE_2)")
    internal static let hypercrisis = Languages.tr("HYPERTENSION_CRISIS")
        
    // Settings
    internal static let settings = Languages.tr("SETTINGS")
    internal static let logout = Languages.tr("LOG_OUT")
    internal static let accountDetails = Languages.tr("ACCOUNT_DETAILS")
    internal static let myDevices = Languages.tr("MY_DEVICES")
    internal static let notifications = Languages.tr("NOTIFICATIONS")
    internal static let systemAuthorization = Languages.tr("SYSTEM_AUTHORIZATION")
    internal static let feedback = Languages.tr("FEEDBACK")
    internal static let privacyPolicy = Languages.tr("PRIVACY_POLICY")
    internal static let termsOfService = Languages.tr("TERMS_OF_SERVICE")
    internal static func version(_ arg: String) -> String {
        return Languages.tr("VERSION", [arg])
    }
    internal static let firstName = Languages.tr("FIRST_NAME")
    internal static let lastName = Languages.tr("LAST_NAME")
    internal static let emailAddress = Languages.tr("EMAIL_ADDRESS")
    internal static let resetPassword = Languages.tr("RESET_PASSWORD")
    internal static let send = Languages.tr("SEND")
    internal static let resetPasswordDesc = Languages.tr("RESET_PASSWORD_DESC")
    internal static let resetPasswordResponse = Languages.tr("RESET_PASSWORD_RESPONSE")
    
    // My Devices
    internal static let smartScale = Languages.tr("SMART_SCALE")
    internal static let smartBlockPressureCuff = Languages.tr("SMART_BLOCK_PRESSURE_CUFF")
    internal static let smartPedometer = Languages.tr("SMART_PEDOMETER")
    internal static let smartWatch = Languages.tr("SMART_WATCH")
    
    // My Notifications
    internal static let myNotifications = Languages.tr("MY_NOTIFICATIONS")
    internal static let activityPushNotifications = Languages.tr("ACTIVITY_PUSH_NOTIFICATIONS")
    internal static let bloodPressurePushNotifications = Languages.tr("BLOOD_PRESSURE_PUSH_NOTIFICATIONS")
    internal static let weightInPushNotifications = Languages.tr("WEIGHT_IN_PUSH_NOTIFICATIONS")
    internal static let surveyPushNotifications = Languages.tr("SURVEY_PUSH_NOTIFICATIONS")
    
    // Questionnaire
    internal static func ofParts(_ p1: Int, _ p2: Int) -> String {
        return Languages.tr("OF_PARTS", [p1,p2])
    }
    internal static func question(_ p1: Int) -> String {
        return Languages.tr("QUESTION", [p1])
    }
    internal static let previous = Languages.tr("PREVIOUS")
}

