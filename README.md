# foresight-allie-ios

### Dependencies

* [Xcode](https://developer.apple.com/support/xcode/)  >= 12.0
* [Cocoapods](https://cocoapods.org/) >= 1.9.3

### Run

1. Clone this repo
2. Open a shell and navigate to project root folder
3. We use the Cocoapods dependency manager, so you will need to install the necessary pods before compiling the application : Run `pod install`

### Configure

The application leverages an `Environment.xcconfig`  file to configure relevant environment settings pertaining to URLs, API Keys, etc and a `GoogleService-Info.plist`  file that holds URLs and IDs as well that ensure the project's configuration with Firebase. These files are in the `.gitignore` . An `Environment.xcconfig.example` is provided instead of the `Environment.xcconfrig`. To configure the repo locally:

1.  Run `cp Environment.xcconfig.example Environment.xcconfig`
2.  Edit `Environment.xcconfig` and provide the necessary values (if unknown contact Ops or Engineering)

### Compile 

1. Open Allie.xcworkspace file using Xcode
2. Compile and Run on desired simulator ( iOS version 12.0 and above)

### Architecture 

The project is setup using the Coordinator design pattern which provides an encapsulation of navigation logic and dependency injection.


