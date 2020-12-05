# PODFILE_PATH=../../../master-gitosis/linphone-sdk/ioslinhome/linphone-sdk.podspec pod install

platform :ios, '12.4'
source "https://gitlab.linphone.org/BC/public/podspec.git"
source "https://github.com/CocoaPods/Specs.git"

# App
def app_pods
	if ENV['PODFILE_PATH'].nil?
		pod 'linphone-sdk', '~> 4.5.0-alpha.266+0b55767'
	else
		pod 'linphone-sdk', :path => ENV['PODFILE_PATH']  # loacl sdk
	end
	#pod 'linphone-sdk/basic-frameworks', :path => 'linphone-sdk'
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
	if ENV['PODFILE_PATH'].nil?
		pod 'linphone-sdk', '~> 4.5.0-alpha.266+0b55767'
	else
		pod 'linphone-sdk', :path => ENV['PODFILE_PATH']  # loacl sdk
	end
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
	# strip bitcode fom linphone-sdk
	#system('find Pods/linphone-sdk -name "*.framework" -exec echo -n "{}/" \; -exec basename {} .framework  \;  > libs && while read lib; do  xcrun bitcode_strip -r $lib  -o $lib; done < libs && rm libs')
end

