# PODFILE_PATH=../../../master-gitosis/linphone-sdk/ioslinhome/linphone-sdk.podspec pod install

platform :ios, '12.4'
source "https://gitlab.linphone.org/BC/public/podspec.git"
source "https://github.com/CocoaPods/Specs.git"

def linpod
	if ENV['PODFILE_PATH'].nil?
		pod 'linphone-sdk', '4.5.0'
	else
		pod 'linphone-sdk', :path => ENV['PODFILE_PATH']  # loacl sdk : PODFILE_PATH=<Path to>/linphone-sdk.podspec  pod install
	end
end

# App
def app_pods
	linpod
	pod 'IQKeyboardManager'
	pod 'PocketSVG'
	pod 'Zip'
	pod 'SVProgressHUD'
	pod 'SwiftSVG'
	pod 'DropDown'
	pod 'SnapKit'
	pod 'Firebase/Analytics'
	pod 'Firebase/Crashlytics'
	pod 'MarqueeLabel'
end

target 'Linhome' do
	use_frameworks!
	app_pods
end

# Extensions
def ext_pods
	linpod
	pod 'Zip'
	pod 'PocketSVG'
	pod 'Firebase/Analytics'
	pod 'Firebase/Crashlytics'
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
	end
end

