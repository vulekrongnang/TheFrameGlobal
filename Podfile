# Uncomment the next line to define a global platform for your project
platform :ios, '14.0'

def shared_pods
 # Comment the next line if you don't want to use dynamic frameworks
 # Rx swift
 pod 'RxSwift', '~> 5'
 pod 'RxCocoa', '~> 5'
 pod "RxGesture"
 #RxBus
 pod 'RxBus'
 #Snap Kit
 pod 'SnapKit', '~> 5.6.0'
 # handle keybroad
 pod 'IQKeyboardManagerSwift'
 
 pod 'SPPermissions/Camera'
 pod 'SPPermissions/Microphone'
 pod 'SPPermissions/PhotoLibrary'
 
 pod 'YPImagePicker'
 
 pod 'DatePickerDialog'
end

target 'The Frame' do
  # Comment the next line if you don't want to use dynamic frameworks
  use_frameworks!
  shared_pods
  # Pods for The Frame

end

post_install do |installer|
    installer.generated_projects.each do |project|
          project.targets.each do |target|
              target.build_configurations.each do |config|
                  config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = '14.0'
               end
          end
   end
end
