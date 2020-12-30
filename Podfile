# Uncomment the next line to define a global platform for your project
platform :ios, '14.0'

target 'Alfred' do
  # Comment the next line if you don't want to use dynamic frameworks
  use_frameworks!

  pod 'GoogleSignIn'

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
      config.build_settings['ALWAYS_EMBED_SWIFT_STANDARD_LIBRARIES'] = 'NO'
    end
  end
end

