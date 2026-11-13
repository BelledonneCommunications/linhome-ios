// Test doubles for deterministic state-machine tests; not an iOS/SDK integration test.
import Foundation

class CXProviderConfiguration {
    var supportsVideo = false
    var maximumCallGroups = 1
    var maximumCallsPerCallGroup = 1
    var supportedHandleTypes = Set<CXHandle.HandleType>()
    init(localizedName: String) {}
}
class CXHandle {
    enum HandleType { case generic }
    init(type: HandleType, value: String) {}
}
class CXCallUpdate {
    var remoteHandle: CXHandle?
    var localizedCallerName: String?
    var hasVideo = false
    var supportsHolding = true
    var supportsGrouping = true
    var supportsUngrouping = true
    var supportsDTMF = true
}
enum CXCallEndedReason { case answeredElsewhere, declinedElsewhere, failed, remoteEnded, unanswered }
protocol CXProviderDelegate {}
class CXProvider {
    static var latest: CXProvider!
    var reports = [UUID]()
    var endings = [(UUID, CXCallEndedReason)]()
    var completions = [(Error?) -> Void]()
    init(configuration: CXProviderConfiguration) { Self.latest = self }
    func setDelegate(_ delegate: CXProviderDelegate, queue: DispatchQueue?) {}
    func reportNewIncomingCall(with uuid: UUID, update: CXCallUpdate, completion: @escaping (Error?) -> Void) {
        reports.append(uuid); completions.append(completion)
    }
    func reportCall(with uuid: UUID, updated: CXCallUpdate) {}
    func reportCall(with uuid: UUID, endedAt: Date, reason: CXCallEndedReason) { endings.append((uuid, reason)) }
    func complete(_ error: Error? = nil) {
        completions.removeFirst()(error)
        RunLoop.main.run(until: Date().addingTimeInterval(0.01))
    }
}
class CXAction {
    var fulfilled = false
    var failed = false
    func fulfill() { fulfilled = true }
    func fail() { failed = true }
}
class CXCallAction: CXAction {
    let callUUID: UUID
    init(call: UUID) { callUUID = call }
}
class CXAnswerCallAction: CXCallAction {}
class CXEndCallAction: CXCallAction {}
class CXSetMutedCallAction: CXCallAction { var isMuted = false }
class AVAudioSession {}
class Address {
    var displayName: String? = "Front door"
    func asStringUriOnly() -> String { "sip:door@example.org" }
}
class CallLog {
    enum Status { case Missed, Success, AcceptedElsewhere, DeclinedElsewhere }
    var callId = "call-1"
    var status = Status.Missed
}
class CallParams { var videoEnabled = true }
class Call {
    enum State { case PushIncomingReceived, IncomingReceived, IncomingEarlyMedia, Connected, StreamsRunning, End, Error, Released, OutgoingInit, Updating }
    enum Reason { case Busy, Declined }
    var callLog: CallLog? = CallLog()
    var remoteAddress: Address? = Address()
    var remoteParams: CallParams? = CallParams()
    var state = State.PushIncomingReceived
    var accepted = false
    var terminated = false
    var declined = false
    var acceptSucceeds = true
    var onTerminate: (() -> Void)?
    func extendedAccept(core: Core) -> Bool { accepted = acceptSucceeds; return acceptSucceeds }
    func decline(reason: Reason) throws { declined = true; onTerminate?() }
    func terminate() throws { terminated = true; onTerminate?() }
}
class Core {
    static let instance = Core()
    static func get() -> Core { instance }
    var accountList = [SDKAccount]()
    var config: Config? = Config()
    var pushNotificationEnabled: Bool? = false
    var pushIncomingCallTimeout = 30
    static func runsInsideExtension() -> Bool { false }
    var callkitEnabled = true
    var micEnabled = true
    var audioActivated = false
    func configureAudioSession() {}
    func activateAudioSession(activated: Bool) { audioActivated = activated }
}
class Device { var name = "Front door" }
class DeviceStore {
    static let it = DeviceStore()
    func findDeviceByAddress(address: Address) -> Device? { Device() }
}
class Texts { static let appName = "Linhome"; static func get(_ key: String) -> String { key } }
class Log { static func warn(_ message: String) {}; static func error(_ message: String) {} }

// In-memory preferences keep these tests isolated from the developer's real app group.
class UserDefaults {
    private var values: [String: Any] {
        get { Self.storage[suite] ?? [:] }
        set { Self.storage[suite] = newValue }
    }
    convenience init?(suiteName: String) { self.init(); suite = suiteName }
    private var suite = ""
    private static var storage = [String: [String: Any]]()
    func bool(forKey key: String) -> Bool { values[key] as? Bool ?? false }
    func object(forKey key: String) -> Any? { values[key] }
    func dictionary(forKey key: String) -> [String: Any]? { values[key] as? [String: Any] }
    func set(_ value: Any?, forKey key: String) { values[key] = value }
    func removeObject(forKey key: String) { values.removeValue(forKey: key) }
}
class Config {
    static let appGroupName = "test.linhome"
    static let teamID = "TESTTEAM"
    static let pushProvider = "apns.dev"
    static let pushNotificationsInterval = 30
    var failsSync = false
    func sync() throws {
        if failsSync { throw NSError(domain: "test.persistence", code: 1) }
    }
}
class PushConfig {
    var provider = ""
    var remotePushInterval = ""
    var voipToken: String? = "test-voip-token"
    var teamId = ""
    var bundleIdentifier = ""
    func clone() -> PushConfig {
        let result = PushConfig(); result.provider = provider
        result.teamId = teamId; result.bundleIdentifier = bundleIdentifier
        result.remotePushInterval = remotePushInterval; result.voipToken = voipToken
        return result
    }
}
class SDKAccountParams {
    var identityAddress: Address? = Address()
    var contactUriParameters = "pn-provider=apns;custom=keep"
    var pushNotificationAllowed = false
    var remotePushNotificationAllowed = true
    var pushNotificationConfig: PushConfig? = PushConfig()
    func clone() -> SDKAccountParams? {
        let result = SDKAccountParams()
        result.identityAddress = identityAddress
        result.contactUriParameters = contactUriParameters
        result.pushNotificationAllowed = pushNotificationAllowed
        result.remotePushNotificationAllowed = remotePushNotificationAllowed
        result.pushNotificationConfig = pushNotificationConfig?.clone()
        return result
    }
}
class SDKAccount { var params: SDKAccountParams? = SDKAccountParams(); var registrations = 0; func refreshRegister() { registrations += 1 } }
typealias Account = SDKAccount
