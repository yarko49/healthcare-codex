# Uncomment the next line to define a global platform for your project
install! 'cocoapods', :integrate_targets => true

platform :ios, '14.0'

def firebase_pods
  pod 'GoogleSignIn', '5.0.2'
  pod 'Firebase/Auth', '6.31.0'
  pod 'Firebase/Crashlytics', '6.31.0'
end

def networking_pods
  pod 'Alamofire', '4.9.1'
  pod 'CodableAlamofire', '1.1.2'
end

def common_pods_for_target
  pod 'SVProgressHUD', '2.2.5'
  pod 'IQKeyboardManagerSwift', '6.5.5'
end

target 'alfred-ios' do
  platform :ios, '14.0'
  use_frameworks!

  firebase_pods
  networking_pods
  common_pods_for_target
end

target 'AlfrediOSTests' do
  platform :ios, '14.0'
  use_frameworks!

  networking_pods
  firebase_pods
  common_pods_for_target
end

target 'AlfredCore' do
  platform :ios, '14.0'
  use_frameworks!

  networking_pods
  firebase_pods
end

target 'AlfredCoreTests' do
  platform :ios, '14.0'
  use_frameworks!

  networking_pods
  firebase_pods
end

# XCode 12 support, will remove when new cocoapods is released
post_install do |installer|
  installer.pods_project.targets.each do |target|
    target.build_configurations.each do |config|
      config.build_settings.delete 'IPHONEOS_DEPLOYMENT_TARGET'
    end
  end
end
