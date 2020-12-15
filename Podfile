# Uncomment the next line to define a global platform for your project
install! 'cocoapods', :integrate_targets => true

platform :ios, '14.0'

def firebase_pods
  pod 'GoogleSignIn'
end

def common_pods_for_target
  pod 'SVProgressHUD'
  pod 'IQKeyboardManagerSwift'
end

target 'alfred-ios' do
  platform :ios, '14.0'
  use_frameworks!

  firebase_pods
  common_pods_for_target
end

target 'AlfrediOSTests' do
  platform :ios, '14.0'
  use_frameworks!

  firebase_pods
  common_pods_for_target
end

target 'AlfredCore' do
  platform :ios, '14.0'
  use_frameworks!

  firebase_pods
end

target 'AlfredCoreTests' do
  platform :ios, '14.0'
  use_frameworks!

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
