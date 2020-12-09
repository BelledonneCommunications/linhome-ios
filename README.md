[![pipeline status](https://gitlab.linphone.org/BC/private/linhome-ios/badges/master/pipeline.svg)](https://gitlab.linphone.org/BC/private/linhome-ios/commits/master)


Linhome is an open source software designed to communicate via voice and video with door entry devices.
The Linhome application has been developed to meet the emerging needs of intercom and video monitoring system developers to leverage a robust, secure and interoperable open source VoIP solution to build their own mobile application.

General description is available from [Linhome web site](https://www.linhome.org)

### License

Copyright © Belledonne Communications

Linhome is dual licensed, and is available either :

 - under a [GNU/GPLv3 license](https://www.gnu.org/licenses/gpl-3.0.en.html), for free (open source). Please make sure that you understand and agree with the terms of this license before using it (see LICENSE file for details).

 - under a proprietary license, for a fee, to be used in closed source applications. Contact

[Belledonne Communications](https://www.linhome.org/contact/) for any question about costs and services.

### Documentation

- Supported features and RFCs from the underlying Liblinphone library : https://www.linphone.org/technical-corner/liblinphone


# How can I contribute?

Thanks for asking! We love pull requests from everyone. Depending on what you want to do, you can help us improve Linhome in
various ways:


## Report bugs and submit patchs

If you want to dig through Linhome code or report a bug, please read `CONTRIBUTING.md` first. You should also read this `README` entirely ;-).

## How to be a beta tester ?

Enter the Beta :
- Download TestFlight from the App Store and log in it with your apple-id
-Tap the public link on your iOS device. The public link : https://testflight.apple.com/join/8c958Kq0
-Touch View in TestFlight or Start Testing. You can also touch Accept, Install, or Update for Linhome app.
-And voilà ! You can update your beta version with the same public link when a new one is available

Send a crash report :
 - It is done automatically by TestFlight

Report a bug :
 - Open Linhome
 - Go to Settings —> Send logs
 - An email to linhome-ios@belledonne-communications.com is created with your logs attached
 - Fill in the bug description with :
	* What you were doing
	* What happened
	* What you were expecting
	* Approximately when the bug happened
 - Change the object to [Beta test - Bug report]
 - Send the mail

# Building the application

## Building the app

The app depends on a single git submodule that holds the shared information with iOS App that is the Theme (images, colors, fonts, etc) and the texts and translations of the app. 
So after cloning the repository make sure you run : 
```
git submodule update --init --recursive
```
The application will automatically collect the appropriate information from the shared submodule as part of the gradle build script.


If you don't have CocoaPods already, you can download and install it using :
```
	sudo gem install cocoapods
```
**If you alreadly have Cocoapods, make sur that the version is higher than 1.7.5**.

- Install the app's dependencies with cocoapods first:
```
	pod install
```
  It will download the linphone-sdk from our gitlab repository so you don't have to build anything yourself.
- Then open `linhome.xcworkspace` file (**NOT linhome.xcodeproj**) with XCode to build and run the app.

# Limitations and known bugs

* Video capture will not work in simulator (not implemented in it).


# Using a local linphone SDK

- Clone the linphone-sdk repository from out gitlab:
```
   git clone https://gitlab.linphone.org/BC/public/linphone-sdk.git --recursive
```

- Follow the instructions in the linphone-sdk/README file to build the SDK.

- Rebuild the project:
```
   PODFILE_PATH=<path to linphone-sdk-ios> pod install
```
  where <path to linphone-sdk-ios> is your build directory of the linphone-sdk project, containing the `linphone-sdk.podspec` file and a `linphone-sdk` ouptut directory comprising built frameworks and resources.

- Then open linhome.xcworkspace with Xcode to build and run the app.
