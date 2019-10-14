
@objc(LKMentionUtilities)
public final class MentionUtilities : NSObject {
    
    override private init() { }
    
    @objc public static func highlightMentions(in string: String, thread: TSThread) -> String {
        return highlightMentions(in: string, isOutgoingMessage: false, thread: thread, attributes: [:]).string // isOutgoingMessage and attributes are irrelevant
    }
    
    @objc public static func highlightMentions(in string: String, isOutgoingMessage: Bool, thread: TSThread, attributes: [NSAttributedString.Key:Any]) -> NSAttributedString {
        var groupChat: LokiGroupChat?
        OWSPrimaryStorage.shared().dbReadConnection.read { transaction in
            groupChat = LokiDatabaseUtilities.objc_getGroupChat(for: thread.uniqueId!, in: transaction)
        }
        var string = string
        let regex = try! NSRegularExpression(pattern: "@[0-9a-fA-F]*", options: [])
        let knownUserHexEncodedPublicKeys = LokiAPI.userHexEncodedPublicKeyCache[thread.uniqueId!] ?? [] // Should always be populated at this point
        var mentions: [NSRange] = []
        var outerMatch = regex.firstMatch(in: string, options: .withoutAnchoringBounds, range: NSRange(location: 0, length: string.count))
        while let match = outerMatch, thread.isGroupThread() {
            let hexEncodedPublicKey = String((string as NSString).substring(with: match.range).dropFirst()) // Drop the @
            let matchEnd: Int
            if knownUserHexEncodedPublicKeys.contains(hexEncodedPublicKey) {
                var userDisplayName: String?
                if hexEncodedPublicKey == OWSIdentityManager.shared().identityKeyPair()!.hexEncodedPublicKey {
                    userDisplayName = OWSProfileManager.shared().localProfileName()
                } else {
                    if let groupChat = groupChat {
                        OWSPrimaryStorage.shared().dbReadConnection.read { transaction in
                            let collection = "\(groupChat.server).\(groupChat.channel)"
                            userDisplayName = transaction.object(forKey: hexEncodedPublicKey, inCollection: collection) as! String?
                        }
                    } else {
                        userDisplayName = nil // TODO: Implement
                    }
                }
                if let userDisplayName = userDisplayName {
                    string = (string as NSString).replacingCharacters(in: match.range, with: "@\(userDisplayName)")
                    mentions.append(NSRange(location: match.range.location, length: userDisplayName.count + 1)) // + 1 to include the @
                    matchEnd = match.range.location + userDisplayName.count
                } else {
                    matchEnd = match.range.location + match.range.length
                }
            } else {
                matchEnd = match.range.location + match.range.length
            }
            outerMatch = regex.firstMatch(in: string, options: .withoutAnchoringBounds, range: NSRange(location: matchEnd, length: string.count - matchEnd))
        }
        let result = NSMutableAttributedString(string: string, attributes: attributes)
        mentions.forEach { mention in
            let color: UIColor = isOutgoingMessage ? .lokiDarkGray() : .lokiGreen()
            result.addAttribute(.backgroundColor, value: color, range: mention)
        }
        return result
    }
}
