import XCTest
@testable import Swoirenberg
@testable import SwiftBridge

final class SwoirenbergTests: XCTestCase {
    func testProveAndVerify() throws {
        let circuitBytecodeBase64 = "H4sIAAAAAAAA/7VTQQ4DIQjE3bXHvgUWXfHWr9TU/f8TmrY2Ma43cRJCwmEYBrAAYOGKteRHyYyHcznsmZieuMckHp1Ph5CQF//ahTmLkxBTDBjJcabTRz7xB1Nx4RhoUdS16un6cpmOl6bxEsdAmpprvVuJD5bOLdwmzAJNn9a/e6em2nzGcrYJvBb0jn7W3FZ/R1hRXjSP+mBB/5FMpbN+oj/eG6c6pXEFAAA="
        let circuitBytecode = Data(base64Encoded: circuitBytecodeBase64)!
        let witnessMap = [Int64(1), Int64(2)]

        let proof = try Swoirenberg.prove(bytecode: circuitBytecode, witnessMap: witnessMap)
        XCTAssertEqual(proof.proof.count, 2176, "Invalid proof returned")
        XCTAssertEqual(proof.vkey.count, 1718, "Invalid verification key returned")
        XCTAssertEqual(proof.vkey.sha256(), "17d4957a251a2dbf570c8a308b72b1aea978f59fdd061bf377bb3c24ec209e5c", "Invalid verification key returned")

        let valid = try Swoirenberg.verify(bytecode: circuitBytecode, proof: proof)
        XCTAssertTrue(valid, "Failed to verify proof")
    }
}
