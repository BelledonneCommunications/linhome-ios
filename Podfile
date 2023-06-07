# PODFILE_PATH=../../../master-gitosis/linphone-sdk/ioslinhome/linphone-sdk.podspec pod install

platform :ios, '11.0'
source "https://gitlab.linphone.org/BC/public/podspec.git"
source "https://github.com/CocoaPods/Specs.git"

def linphone_sdk_pod
	if ENV['PODFILE_PATH'].nil?
                pod 'linphone-sdk', '5.2.65-pre.2+5688d2a'
	else
		pod 'linphone-sdk', :path => ENV['PODFILE_PATH']  # loacl sdk : PODFILE_PATH=<Path to>/linphone-sdk.podspec  pod install
	end
end

# App
def app_pods
	linphone_sdk_pod
	pod 'IQKeyboardManager'
	pod 'PocketSVG'
	pod 'Zip'
	pod 'SVProgressHUD'
	pod 'SwiftSVG'
	pod 'DropDown'
	pod 'SnapKit'
	pod 'Firebase/Crashlytics'
	pod 'MarqueeLabel'
	pod 'DeviceGuru'
end

target 'Linhome' do
	use_frameworks!
	app_pods
end

# Extensions
def ext_pods
	linphone_sdk_pod
	pod 'Zip'
	pod 'PocketSVG'
	pod 'Firebase/Crashlytics'
	pod 'DeviceGuru'
end

target 'LinhomeContentExtension' do
	use_frameworks!
	ext_pods
end

target 'LinhomeServiceExtension' do
	use_frameworks!
	ext_pods
end

post_install do |installer|
	installer.pods_project.targets.each do |target|
		if target.name == 'SwiftSVG'
			target.build_configurations.each do |config|
				config.build_settings['SWIFT_INSTALL_OBJC_HEADER'] = 'NO'
			end
		end
		target.build_configurations.each do |config|
      			config.build_settings.delete 'IPHONEOS_DEPLOYMENT_TARGET'
			config.build_settings['GCC_PREPROCESSOR_DEFINITIONS'] = '$(inherited) POCKETSVG_DISABLE_FILEWATCH=1'
    		end	
	end
end
