import Foundation

extension String {
	static let email = Languages.tr("EMAIL")
	static let password = Languages.tr("PASSWORD")
	static let confirmPassword = Languages.tr("CONFIRM_PASSWORD")
	static let login = Languages.tr("LOG_IN")
	static let register = Languages.tr("REGISTER")
	static let loginCTA = Languages.tr("LOG_IN_CTA")
	static let registerCTA = Languages.tr("REGISTER_CTA")
	static let home = Languages.tr("HOME")
	static let hello = Languages.tr("HELLO")
	static let faceID = Languages.tr("FACE_ID")
	static let touchID = Languages.tr("TOUCH_ID")
	static let authWithBiometrics = Languages.tr("AUTHENTICATE_WITH_TOUCH_ID")
	static let no = Languages.tr("NO")
	static let automaticSignIn = Languages.tr("ENABLE_AUTOMATIC_SIGN_IN")
	static func enroll(_ arg: String) -> String {
		Languages.tr("BIOMETRICS_QUESTION_MESSAGE", [arg])
	}

	static func helloName(_ arg: String) -> String {
		Languages.tr("HELLO_NAME", [arg])
	}

	static let close = Languages.tr("CLOSE")
	static let cancel = Languages.tr("CANCEL")
	static let signInWithGoogle = Languages.tr("SIGN_IN_WITH_GOOGLE")
	static let signInWithApple = Languages.tr("SIGN_IN_WITH_APPLE")
	static let signup = Languages.tr("SIGN_UP")
	static let signUpWithGoogle = Languages.tr("SIGN_UP_WITH_GOOGLE")
	static let signUpWithApple = Languages.tr("SIGN_UP_WITH_APPLE")
	static let signUpWithYourEmail = Languages.tr("SIGN_UP_WITH_YOUR_EMAIL")
	static let signInWithYourEmail = Languages.tr("SIGN_IN_WITH_YOUR_EMAIL")
	static let forgotPassword = Languages.tr("FORGOT_PASSWORD")
	static let signin = Languages.tr("SIGN_IN")
	static let signInModal = Languages.tr("SIGN_IN_MODAL")
	static let save = Languages.tr("SAVE")
	static let welcomeBack = Languages.tr("WELCOME_BACK")
	static let resetMessage = Languages.tr("WE_WILL_EMAIL_YOU_A_LINK_TO_RESET_YOUR_PASSWORD")
	// Profile stats
	static let today = Languages.tr("TODAY")
	static let wk = Languages.tr("WK")
	static let mo = Languages.tr("MO")
	static let yr = Languages.tr("YR")
	static let high = Languages.tr("HIGH")
	static let low = Languages.tr("LOW")
	static let dailyAverage = Languages.tr("DAILY_AVERAGE")
	static let monthlyAverage = Languages.tr("MONTHLY_AVERAGE")
	static let weeklyAverage = Languages.tr("WEEKLY_AVERAGE")
	static let yearlyAverage = Languages.tr("YEARLY_AVERAGE")
	static let weight = Languages.tr("WEIGHT")
	static let activity = Languages.tr("ACTIVITY")
	static let bloodPressure = Languages.tr("BLOOD_PRESSURE")
	static let restingHR = Languages.tr("RESTING_HEART_RATE")
	static let heartRate = Languages.tr("HEART_RATE")

	// Onboarding
	static let slide1Title = Languages.tr("SLIDE_1_TITLE")
	static let slide2Title = Languages.tr("SLIDE_2_TITLE")
	static let slide3Title = Languages.tr("SLIDE_3_TITLE")
	static let alreadyHaveAccount = Languages.tr("ALREADY_HAVE_ACCOUNT")
	static let acceptingTSPP = Languages.tr("BY_REGISTERING_I_ACCEPT_THE_TERMS_OF_SERVICES_AND_PRIVACY_POLICY")
	static let signupmsg = Languages.tr("SIGN_UP_FOR_ALFRED_WITH_YOUR_EMAIL")

	// Sign up
	static let invalidConfirmationEmail = Languages.tr("FAILED_TO_CONFIRM_EMAIL")
	static let invalidText = Languages.tr("INVALID_TEXT")
	static let invalidTextMsg = Languages.tr("TEXT_SHOULD_NOT_CONTAIN_SPECIAL_CHARACTERS_OR_NUMBERS")
	static let signUpFailed = Languages.tr("SIGN_UP_FAILED")
	static let failedSendLink = Languages.tr("FAILED_SEND_LINK")
	static let invalidInput = Languages.tr("INVALID_INPUT")
	static let emptyPickerField = Languages.tr("FIELDS_CANNOT_BE_EMPTY")
	static let appleHealthSelect = Languages.tr("SELECT_DEVICES")
	static let appleSelectMessage = Languages.tr("SELECT_DEVICES_MESSAGE")
	static let appleHealthImport = Languages.tr("IMPORT_DATA")
	static let appleImportMessage = Languages.tr("IMPORT_DATA_MESSAGE")
	static let synced = Languages.tr("SYNCED")
	static let done = Languages.tr("DONE")
	static let importingHealthData = Languages.tr("IMPORTING_HEALTH_DATA")
	static let justASec = Languages.tr("JUST_A_SEC")
	static let uploadHealthDataFailed = Languages.tr("UPLOAD_HEALTH_DATA_FAILED")
	static let importHealthDataFailed = Languages.tr("IMPORT_HEALTH_DATA_FAILED")
	static let sendLink = Languages.tr("SEND_LINK")
	static let emailSent = Languages.tr("EMAIL_SENT")
	static let checkMail = Languages.tr("CHECK_MAIL")
	static func sentEmailAtSignIn(_ arg: String) -> String {
		Languages.tr("SENT_EMAIL_AT_SIGN_IN", [arg])
	}

	static func sentEmailAtSignUp(_ arg: String) -> String {
		Languages.tr("SENT_EMAIL_AT_SIGN_UP", [arg])
	}

	static let openMailApp = Languages.tr("OPEN_MAIL_APP")
	static let welcome = Languages.tr("WELCOME")
	static let successfulSignUp = Languages.tr("SUCCESSFUL_SIGN_UP")
	static let successfulSignIn = Languages.tr("SUCCESSFUL_SIGN_IN")
	static let continueProfile = Languages.tr("CONTINUE_PROFILE")

	//  - Profile
	static let myProfile = Languages.tr("MY_PROFILE")
	static let gender = Languages.tr("GENDER_IDENTITY")
	static let sex = Languages.tr("SEX")
	static let male = Languages.tr("MALE")
	static let female = Languages.tr("FEMALE")
	static let trans = Languages.tr("TRANS")
	static let cis = Languages.tr("CIS")
	static let next = Languages.tr("NEXT")
	static let information = Languages.tr("THIS_INFORMATION_HELPS_US_PROVIDE_CUSTOM_RECOMMENDATIONS")
	static let dob = Languages.tr("DATE_OF_BIRTH")
	static let height = Languages.tr("HEIGHT")
	static let invalidOption = Languages.tr("INVALID_OPTION")
	static let selectGender = Languages.tr("PLEASE_SELECT_GENDER")

	// Sign In
	static let longResetMessage = Languages.tr("IF_YOUR_ACCOUNT_IS_ASSOCIATED_WITH_THIS_EMAIL_ADDRESS_YOU_WILL_RECEIVE_AN_EMAIL_TO_RESET_YOUR_PASSWORD_IF_YOU_DON'T_PLEASE_TRY_ANOTHER_EMAIL_ADDRESS")
	static let backToSignIn = Languages.tr("BACK_TO_SIGN_IN")
	static let invalidEmail = Languages.tr("INVALID_EMAIL_ADDRESS")
	static let invalidPw = Languages.tr("INVALID_PASSWORD")
	static let enterEmail = Languages.tr("PLEASE_ENTER_EMAIL_ADDRESS")
	static let enterPw = Languages.tr("PLEASE_ENTER_PASSWORD")
	static let ok = Languages.tr("OK")
	static let signInFailed = Languages.tr("SIGN_IN_FAILED")

	// Reset Password
	static let error = Languages.tr("ERROR")
	static let emailFailed = Languages.tr("FAILED_TO_SEND_VERIFICATION_EMAIL_THE_ACCOUNT_MAY_HAVE_BEEN_DELETED_OR_DOES_NOT_EXIST")

	// Profile
	static let edit = Languages.tr("EDIT")
	static let profile = Languages.tr("PROFILE")
	static let healthy = Languages.tr("HEALTHY")
	static let heavy = Languages.tr("HEAVY")
	static let obese = Languages.tr("OBESE")
	static let light = Languages.tr("LIGHT")
	static let moderate = Languages.tr("MODERATE")
	static let vigorous = Languages.tr("VIGOROUS")
	static let normal = Languages.tr("NORMAL")
	static let elevated = Languages.tr("ELEVATED")
	static let hypertension1 = Languages.tr("HYPERTENSION_(STAGE_1)")
	static let hypertension2 = Languages.tr("HYPERTENSION_(STAGE_2)")
	static let hypercrisis = Languages.tr("HYPERTENSION_CRISIS")
	static let years = Languages.tr("YEARS")

	// Today

	static let now = Languages.tr("NOW")
	static let yesterday = Languages.tr("YESTERDAY")
	static let getMoreInformation = Languages.tr("GET_MORE_INFORMATION")
	static func sysDia(_ p1: Int, _ p2: Int) -> String {
		Languages.tr("SYS_DIA", [p1, p2])
	}

	static func lbsDec(_ p1: Int, _ p2: Int) -> String {
		Languages.tr("LBS_DEC", [p1, p2])
	}

	static func lbs(_ p1: Int) -> String {
		Languages.tr("LBS", [p1])
	}

	static func feet(_ p1: Int, _ p2: Int) -> String {
		Languages.tr("FEET", [p1, p2])
	}

	static let goalWeight = Languages.tr("GOAL_WEIGHT")
	static let defaultWeight = Languages.tr("DEFAULT_WEIGHT")
	static let defaultHeight = Languages.tr("DEFAULT_HEIGHT")
	static let defaultTime = Languages.tr("DEFAULT_TIME")
	static let defaultDate = Languages.tr("DEFAULT_DATE")
	static let inches = Languages.tr("INCHES")
	static let date = Languages.tr("DATE")
	static let time = Languages.tr("TIME")
	static let lb = Languages.tr("LB")
	static let ft = Languages.tr("FEET")
	static let dia = Languages.tr("DIA")
	static let sys = Languages.tr("SYS")
	static let add = Languages.tr("ADD")
	static let completeSurvey = Languages.tr("COMPLETE_SURVEY")
	static let weightUnit = Languages.tr("WEIGHT_UNIT")
	static let heightUnit = Languages.tr("HEIGHT_UNIT")
	static let pressureUnit = Languages.tr("PRESSURE_UNIT")
	static let enterBP = Languages.tr("ENTER_BP")
	static let enterWeight = Languages.tr("ENTER_WEIGHT")

	// Settings
	static let settings = Languages.tr("SETTINGS")
	static let logout = Languages.tr("LOG_OUT")
	static let accountDetails = Languages.tr("ACCOUNT_DETAILS")
	static let myDevices = Languages.tr("DEVICES")
	static let notifications = Languages.tr("NOTIFICATIONS")
	static let systemAuthorization = Languages.tr("SYSTEM_AUTHORIZATION")
	static let feedback = Languages.tr("FEEDBACK")
	static let privacyPolicy = Languages.tr("PRIVACY_POLICY")
	static let termsOfService = Languages.tr("TERMS_OF_SERVICE")
	static let support = Languages.tr("SUPPORT")
	static let troubleShoot = Languages.tr("TROUBLESHOOT")
	static func version(_ arg: String) -> String {
		Languages.tr("VERSION", [arg])
	}

	static let firstName = Languages.tr("FIRST_NAME")
	static let lastName = Languages.tr("LAST_NAME")
	static let emailAddress = Languages.tr("EMAIL_ADDRESS")
	static let resetPassword = Languages.tr("RESET_PASSWORD")
	static let send = Languages.tr("SEND")
	static let resetPasswordDesc = Languages.tr("RESET_PASSWORD_DESC")
	static let resetPasswordResponse = Languages.tr("RESET_PASSWORD_RESPONSE")
	static let notNow = Languages.tr("NOT_NOW")
	static let activate = Languages.tr("ACTIVATE")

	// My Devices
	static let smartScale = Languages.tr("SMART_SCALE")
	static let smartBloodPressureCuff = Languages.tr("SMART_BLOCK_PRESSURE_CUFF")
	static let smartPedometer = Languages.tr("SMART_PEDOMETER")
	static let smartWatch = Languages.tr("SMART_WATCH")

	// My Notifications
	static let myNotifications = Languages.tr("MY_NOTIFICATIONS")
	static let activityPushNotifications = Languages.tr("ACTIVITY_PUSH_NOTIFICATIONS")
	static let bloodPressurePushNotifications = Languages.tr("BLOOD_PRESSURE_PUSH_NOTIFICATIONS")
	static let weightInPushNotifications = Languages.tr("WEIGHT_IN_PUSH_NOTIFICATIONS")
	static let surveyPushNotifications = Languages.tr("SURVEY_PUSH_NOTIFICATIONS")

	// My profile
	static let createPatientFailed = Languages.tr("CREATE_PATIENT_FAILED")
	static let createProfileFailed = Languages.tr("CREATE_PROFILE_FAILED")
	static let createBundleFailed = Languages.tr("CREATE_BUNDLE_FAILED")

	// My profile stats
	static let noEntriesFoundToday = Languages.tr("NO_HEALTH_DATA_FOUND_TODAY")
	static let noEntriesFoundRange = Languages.tr("NO_HEALTH_DATA_FOUND_RANGE")
	static let bpElevated = Languages.tr("BLOOD_PRESSURE_ELEVATED")
	static let bpHigh = Languages.tr("BLOOD_PRESSURE_HIGH")
	static let bpHigh2 = Languages.tr("BLOOD_PRESSURE_HIGH_2")
	static let bpCrisis = Languages.tr("BLOOD_PRESSURE_CRISIS")
	static let belowNormal = Languages.tr("BELOW_NORMAL")
	static let onTrack = Languages.tr("ON_TRACK")
	static let notNormal = Languages.tr("NOT_NORMAL")
	static let weeklyAvg = Languages.tr("WEEKLY_AVG")
	static let monthlyAvg = Languages.tr("MONTHLY_AVG")
	static let yearlyAvg = Languages.tr("YEARLY_AVG")
	static let weekTotal = Languages.tr("WEEK_TOTAL")
	static let monthTotal = Languages.tr("MONTH_TOTAL")
	static let yearTotal = Languages.tr("YEAR_TOTAL")

	// Questionnaire
	static func ofParts(_ p1: Int, _ p2: Int) -> String {
		Languages.tr("OF_PARTS", [p1, p2])
	}

	static func question(_ p1: Int) -> String {
		Languages.tr("QUESTION", [p1])
	}

	static let previous = Languages.tr("PREVIOUS")
	static let submit = Languages.tr("SUBMIT")
	static let thankYou = Languages.tr("THANK_YOU")
	static let surveySubmit = Languages.tr("SURVEY_SUBMIT")
}
