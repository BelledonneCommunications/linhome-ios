# Optional native iOS incoming calls

Settings → **Native iOS incoming calls** selects an experimental CallKit incoming-call mode for the entire app. It is **off by default**, including for existing installations with no saved preference. Restart Linhome after changing the switch. The running process keeps its launch-time selection so changing the setting cannot change transports during an active call.

With the option off, Linhome retains its notification/early-video-preview workflow. With it on, incoming SIP calls use iOS's native answer/decline interface. After answering, open/unlock Linhome to use the existing video and configured door-opening buttons. Those buttons are not added to Apple's system call screen. Video preview before answering is not requested in native mode. Outgoing calls retain Linhome's existing UI and audio handling.

## Implementation

The CallKit provider/UUID mapping, SIP answer/end handling and audio-session callbacks follow Belledonne's Linphone iOS implementation:

- `Classes/Swift/ProviderDelegate.swift` and `Classes/Swift/CallManager.swift` at Linphone commit `8f4a80500e120b68a77a459325ebd47228d8020d` (`release/5.0`).
- https://github.com/BelledonneCommunications/linphone-iphone/tree/8f4a80500e120b68a77a459325ebd47228d8020d/Classes/Swift

The main app's existing liblinphone SDK owns PushKit registration. No second `PKPushRegistry` is created. The app attaches its call delegate and starts the main core during launch, including a background launch. The delegate stays attached while the app is backgrounded. A `PushIncomingReceived` event reports the call immediately; the subsequent SIP INVITE updates the same UUID. If the user answers before the INVITE arrives, the action remains pending until there is a real SIP call to accept. The SDK's push-call timeout clears calls whose INVITE never arrives.

Native mode configures accounts for VoIP-only pushes, rather than sending both a VoIP call and the legacy video notification. It reuses master's account push-configuration method and SDK-managed tokens. At each launch it selects VoIP notification flags in native mode, or restores master's remote-notification flags in legacy mode. Existing non-push contact URI parameters are preserved.

The preference uses the app group's `UserDefaults`; the settings text can be overridden with `settings_native_incoming_calls` and `settings_native_incoming_calls_description` in the shared theme. English, French, German and Polish fallback strings are included. Shared-theme translations should follow the project's translation workflow.

## Service and signing prerequisites

The SIP proxy/push service must understand the SDK's VoIP APNs parameters and be provisioned for the application's VoIP topic and signing environment. A custom build needs its own valid app group, bundle ID, team configuration and push credentials. Enabling the switch alone cannot add missing server-side support. Motion alerts and monitoring events must remain ordinary notifications, never VoIP pushes.

App Store deployment and any changes to Belledonne's production push service remain with the maintainers. This PR does not change server configuration.

## Validation recorded during preparation

- `python3 tests/test-native-incoming-calls.py`: deterministic Swift tests using framework/SDK doubles. Exercises immediate reporting, duplicate prevention, answer-before-INVITE, cancellation-before-report-completion, accept failure, reentrant hangup, answered elsewhere, timeout, provider rejection/reset, opt-out default, launch-scoped selection, and outgoing calls before Call-ID allocation.
- Modified Swift sources passed the Swift parser.
- Xcode project plist validation passed; the new manager belongs only to the main application target.
- An arm64 iPhone build against the official 5.4.123 SDK passed in a separate Personal Team test variant. That variant rebuilds the Swift wrapper locally and omits push capabilities, app groups and notification extensions; those build adaptations are not part of the contribution.
- A foreground call to a physical iPhone passed: the user confirmed the native iOS incoming-call screen, answering and audible test tones over SRTP; the SIP server confirmed an established call. The Personal Team variant must retain the `voip` background-mode declaration for CallKit even though APNs registration is disabled.
- A second foreground call presented a configured door-entry device identity as the caller. After answering through CallKit, the user confirmed Linhome recognized that device and displayed its action buttons. The actions were not executed, and this audio-only test does not validate video.
- Real PushKit delivery and the full SIP/media matrix remain unverified. Keep this contribution in draft until those checks pass.

## Required integration checks before merge

1. Build all three targets with master's SDK 5.4 Swift package; verify the shared core delivers `PushIncomingReceived` on the main queue and provides a nonempty Call-ID.
2. Upgrade an existing installation without enabling the switch. Confirm locked/background notifications, early video, accept/decline, recording, history and door actions behave as before.
3. Enable the option and restart. Check REGISTER parameters use the correct `apns`/`apns.dev` VoIP topic/token and do not request legacy remote call notifications. Cover a Linhome account and an external SIP account with the Linhome push gateway.
4. Test real calls while the app is foregrounded, backgrounded and not running: native ringing, device display name, answer, decline, microphone, speaker/Bluetooth, video after opening the app and each configured door action.
5. Test answering before registration completes, network loss/no INVITE, caller cancel before/after CallKit reporting, timeout, duplicate push, another endpoint answering/declining, Focus filtering and provider reset. Confirm no stuck or duplicate system call and no artificial call for a non-call event.
6. Check outgoing calls and interruption by cellular calls. Confirm their audio works, including outgoing creation before a SIP Call-ID exists.
7. Change the switch during a call: current launch must retain its mode. Disable and restart: master's remote-notification flags and notification preview must return. Check notifications already in flight while changing modes.
8. Complete the repository's contributor license agreement requirement before integration.
