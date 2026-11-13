var passed = 0
func check(_ condition: @autoclosure () -> Bool, _ message: String) {
    precondition(condition(), message)
    passed += 1
}
func setup() -> (NativeIncomingCallManager, CXProvider, Call) {
    let manager = NativeIncomingCallManager()
    let provider = CXProvider.latest!
    let call = Call()
    manager.onCallStateChanged(core: Core.get(), call: call, state: .PushIncomingReceived)
    return (manager, provider, call)
}
// Report at the push stage, and update rather than duplicate when INVITE arrives.
do {
    let (manager, provider, call) = setup()
    check(provider.reports.count == 1, "Push must immediately report an incoming call")
    provider.complete()
    call.state = .IncomingReceived
    manager.onCallStateChanged(core: Core.get(), call: call, state: call.state)
    check(provider.reports.count == 1, "INVITE must reuse push call UUID")
    let answer = CXAnswerCallAction(call: provider.reports[0])
    manager.provider(provider, perform: answer)
    check(call.accepted && answer.fulfilled, "Answer must accept the real SIP call")
}
// Answer before registration/INVITE must be retained, not prematurely fulfilled.
do {
    let (manager, provider, call) = setup()
    provider.complete()
    let answer = CXAnswerCallAction(call: provider.reports[0])
    manager.provider(provider, perform: answer)
    check(!answer.fulfilled && !call.accepted, "Wait for the SIP INVITE")
    call.state = .IncomingReceived
    manager.onCallStateChanged(core: Core.get(), call: call, state: call.state)
    check(answer.fulfilled && call.accepted, "Accept when INVITE finally arrives")
}
// Caller cancels while the system is still asynchronously presenting the call.
do {
    let (manager, provider, call) = setup()
    manager.onCallStateChanged(core: Core.get(), call: call, state: .End)
    check(provider.endings.isEmpty, "Do not end a call before report completion")
    provider.complete()
    check(provider.endings.count == 1 && provider.endings[0].1 == .unanswered, "Dismiss canceled ringing call")
    manager.onCallStateChanged(core: Core.get(), call: call, state: .Released)
    check(provider.endings.count == 1, "End/Released must not report termination twice")
}
// A failed SIP accept must not tell iOS that answering succeeded.
do {
    let (manager, provider, call) = setup()
    provider.complete()
    call.state = .IncomingReceived
    call.acceptSucceeds = false
    manager.onCallStateChanged(core: Core.get(), call: call, state: call.state)
    let answer = CXAnswerCallAction(call: provider.reports[0])
    manager.provider(provider, perform: answer)
    check(answer.failed && !answer.fulfilled && call.terminated, "Failed SIP answer must fail CallKit action")
}
// Synchronous SIP callbacks during system hangup must not double-end the call.
do {
    let (manager, provider, call) = setup()
    provider.complete()
    call.state = .IncomingReceived
    call.onTerminate = { manager.onCallStateChanged(core: Core.get(), call: call, state: .End) }
    let end = CXEndCallAction(call: provider.reports[0])
    manager.provider(provider, perform: end)
    check(end.fulfilled && call.declined, "System decline must decline SIP")
    check(provider.endings.count == 1, "Synchronous termination must not double-report")
}
// Accepted on another household device must clear the system UI with that reason.
do {
    let (manager, provider, call) = setup()
    provider.complete()
    call.callLog?.status = .AcceptedElsewhere
    manager.onCallStateChanged(core: Core.get(), call: call, state: .End)
    check(provider.endings.last?.1 == .answeredElsewhere, "Track answered elsewhere")
}
// SIP/push timeout cancels a pending answer.
do {
    let (manager, provider, call) = setup()
    provider.complete()
    let answer = CXAnswerCallAction(call: provider.reports[0])
    manager.provider(provider, perform: answer)
    manager.onCallStateChanged(core: Core.get(), call: call, state: .Error)
    check(answer.failed && provider.endings.last?.1 == .failed, "Timeout must clear pending answer and system UI")
}
// Focus/block-list/provider rejection must not leave an unmanaged incoming SIP call.
do {
    let (manager, provider, call) = setup()
    provider.complete(NSError(domain: "CallKit", code: 1))
    withExtendedLifetime(manager) {
        check(call.declined, "Presentation rejection must decline the local SIP branch")
    }
}
// System reset must terminate pending calls and relinquish audio.
do {
    let (manager, provider, call) = setup()
    provider.complete()
    manager.providerDidReset(provider)
    check(call.terminated && !Core.get().audioActivated, "Provider reset cleans calls and audio")
}
// A global mode change is deferred until the next launch, with opt-out as the default.
do {
    let prefs = CorePreferences()
    check(!prefs.nativeIncomingCalls, "Missing preference must default to the legacy workflow")
    prefs.nativeIncomingCalls = true
    check(CorePreferences.nativeIncomingCallsEnabledForThisLaunch, "Enabled preference applies on launch")
    prefs.nativeIncomingCalls = false
    check(CorePreferences.nativeIncomingCallsEnabledForThisLaunch, "Changing the switch must not change an in-flight launch")
}
// Outgoing call audio must not depend on a Call-ID already being assigned.
do {
    let manager = NativeIncomingCallManager()
    let call = Call()
    call.callLog = nil
    Core.get().callkitEnabled = true
    manager.onCallStateChanged(core: Core.get(), call: call, state: .OutgoingInit)
    check(!Core.get().callkitEnabled, "Keep outgoing audio handling when Call-ID is not yet available")
}
// Account flags use the launch selection, including after the user changes the switch.
do {
    let account = Account()
    account.configurePushNotificationParameters()
    check(account.params!.pushNotificationAllowed && !account.params!.remotePushNotificationAllowed, "Native launch selects VoIP transport")
    check(account.params!.pushNotificationConfig!.voipToken == "test-voip-token", "Preserve SDK VoIP token")
    check(account.params!.contactUriParameters.contains("custom=keep"), "Preserve unrelated contact parameters")
    check(account.registrations == 1, "Refresh account registration after selecting transport")
}
print("Passed \(passed) native incoming-call state-machine assertions")
