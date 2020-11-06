import SessionUtilities

@objc(SNReadReceipt)
public final class ReadReceipt : ControlMessage {
    public var timestamps: [UInt64]?

    // MARK: Initialization
    init(timestamps: [UInt64]) {
        super.init()
        self.timestamps = timestamps
    }

    // MARK: Coding
    public required init?(coder: NSCoder) {
        super.init(coder: coder)
    }

    public override func encode(with coder: NSCoder) {
        super.encode(with: coder)
    }

    // MARK: Proto Conversion
    public override class func fromProto(_ proto: SNProtoContent) -> ReadReceipt? {
        guard let receiptProto = proto.receiptMessage, receiptProto.type == .read else { return nil }
        let timestamps = receiptProto.timestamp
        guard !timestamps.isEmpty else { return nil }
        return ReadReceipt(timestamps: timestamps)
    }

    public override func toProto() -> SNProtoContent? {
        guard let timestamps = timestamps else {
            SNLog("Couldn't construct read receipt proto from: \(self).")
            return nil
        }
        let receiptProto = SNProtoReceiptMessage.builder(type: .read)
        receiptProto.setTimestamp(timestamps)
        let contentProto = SNProtoContent.builder()
        do {
            contentProto.setReceiptMessage(try receiptProto.build())
            return try contentProto.build()
        } catch {
            SNLog("Couldn't construct read receipt proto from: \(self).")
            return nil
        }
    }
}
