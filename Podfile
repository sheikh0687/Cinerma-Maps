# Uncomment the next line to define a global platform for your project
# platform :ios, '12.0'

target 'Cinerama Maps' do
  # Comment the next line if you don't want to use dynamic frameworks
  use_frameworks!

  # Pods for Cinerama Maps

pod 'Parchment'

pod 'Cosmos'

pod 'OTPFieldView'

pod 'SDWebImage/WebP'

pod 'Alamofire', '~> 4.9.1'

pod 'DropDown'

pod 'IQKeyboardManagerSwift', '6.3.0'

pod 'GoogleMaps'
pod 'GooglePlaces'
pod 'Google-Maps-iOS-Utils'

pod 'InputMask'
pod 'SwiftyJSON'

pod 'SVGKit'

pod 'Firebase/Core'
pod 'Firebase/Messaging'
pod 'Firebase/Storage'

pod 'BenefitPay-iOS'

pod 'NMLocalizedPhoneCountryView'

pod 'R.swift'

end

post_install do |installer|
  installer.pods_project.targets.each do |target|
    # Fix libarclite_xxx.a file not found.
    target.build_configurations.each do |config|
      config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = '13.0'
    end
  end
end
