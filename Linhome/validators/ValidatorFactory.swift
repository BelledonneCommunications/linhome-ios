
class ValidatorFactory { // todo move into shared
        static let nonEmptyStringValidator = NonEmptyStringValidator()
        static let uriValidator = NonEmptyUrlFormatValidator()
        static let hostnameEmptyOrValidValidator = RegExpFormatValidator("^[a-zA-Z0-9.]*$", "invalid_host_name")
       	static let numberEmptyOrValidValidator = RegExpFormatValidator("^[0-9]*$", "invalid_number")
        static let sipUri = NonEmptyWithRegExpFormatValidator("^([^@]+)(?:@(.+))?$", "invalid_sip_uri")
        static let actionCode = RegExpFormatValidator("^[0-9#*]+$", "invalid_action_code")
}
