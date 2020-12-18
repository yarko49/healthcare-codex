# Uncomment the next line to define a global platform for your project

platform :ios, '14.0'

def firebase_pods
  pod 'GoogleSignIn'
end

def common_pods_for_target
  pod 'SVProgressHUD'
  pod 'IQKeyboardManagerSwift'
end

target 'Alfred' do
  # Comment the next line if you don't want to use dynamic frameworks
  use_frameworks!

  # Pods for Alfred
  firebase_pods
  common_pods_for_target

  target 'AlfredTests' do
    inherit! :search_paths
    # Pods for testing
  end
end

# XCode 12 support, will remove when new cocoapods is released
post_install do |installer|
  installer.pods_project.targets.each do |target|
    target.build_configurations.each do |config|
      config.build_settings.delete 'IPHONEOS_DEPLOYMENT_TARGET'
    end
  end
end