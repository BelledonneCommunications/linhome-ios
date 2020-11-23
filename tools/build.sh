xcodebuild archive -scheme Lindoor -archivePath ./lindoor.xcarchive -configuration Release -workspace ./lindoor.xcworkspace -UseModernBuildSystem=YES
xcodebuild -exportArchive -archivePath  ./lindoor.xcarchive -exportPath ./lindoor.ipa -exportOptionsPlist ./lindoor-adhoc.plist -allowProvisioningUpdates -UseModernBuildSystem=YES
