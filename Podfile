# Uncomment the next line to define a global platform for your project
install! 'cocoapods', :integrate_targets => true

platform :ios, '14.0'

def common_pods_for_target
  pod 'Alamofire', '4.9.1'
  pod 'CodableAlamofire', '1.1.2'
  pod 'SVProgressHUD', '2.2.5'
  pod 'EasyPeasy', '1.9.0'
  pod 'UIColor_Hex_Swift', '5.1.0'
  pod 'Charts', '3.4.0'
  pod 'BonMot', '5.5'
  pod 'GoogleSignIn', '5.0.2'
  pod 'Firebase/Auth', '6.31.0'
  pod 'IQKeyboardManagerSwift', '6.5.5'
  pod 'Firebase/Crashlytics', '6.31.0'
end

target 'alfred-ios' do
  platform :ios, '14.0'
  use_frameworks!
  
  common_pods_for_target
end


target 'AlfrediOSTests' do
  platform :ios, '14.0'
  use_frameworks!
  
  common_pods_for_target
end

# XCode 12 support, will remove when new cocoapods is released
post_install do |installer|
  installer.pods_project.targets.each do |target|
    target.build_configurations.each do |config|
      config.build_settings.delete 'IPHONEOS_DEPLOYMENT_TARGET'
    end
  end
end
