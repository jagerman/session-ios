// Copyright © 2022 Rangeproof Pty Ltd. All rights reserved.

import Foundation

import Quick
import Nimble

@testable import SessionMessagingKit

class SOGSErrorSpec: QuickSpec {
    // MARK: - Spec

    override func spec() {
        describe("a SOGSError") {
            it("generates the error description correctly") {
                expect(OpenGroupAPI.Error.decryptionFailed.errorDescription)
                    .to(equal("Couldn't decrypt response."))
                expect(OpenGroupAPI.Error.signingFailed.errorDescription)
                    .to(equal("Couldn't sign message."))
                expect(OpenGroupAPI.Error.noPublicKey.errorDescription)
                    .to(equal("Couldn't find server public key."))
            }
        }
    }
}
