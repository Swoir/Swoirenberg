import XCTest
@testable import Swoirenberg

final class SwoirenbergTests: XCTestCase {
    func testProveAndVerify() throws {
        let circuitBytecodeBase64 = "H4sIAAAAAAAA/62QQQqAMAwErfigpEna5OZXLLb/f4KKLZbiTQdCQg7Dsm66mc9x00O717rhG9ico5cgMOfoMxJu4C2pAEsKioqisnslysoaLVkEQ6aMRYxKFc//ZYQr29L10XfhXv4jB52E+OpMAQAA"
        let circuitBytecode = Data(base64Encoded: circuitBytecodeBase64)!
        let witnessMap = ["0x3", "0x5", "0xf"]

        let num_points = try Swoirenberg.setup_srs(bytecode: circuitBytecode)

        let proof = try Swoirenberg.prove(bytecode: circuitBytecode, witnessMap: witnessMap, proof_type: "honk", recursive: false)
        XCTAssertEqual(proof.proof.count, 14340, "Invalid proof returned")
        XCTAssertEqual(proof.vkey.count, 1825, "Invalid verification key returned")
        XCTAssertEqual(proof.vkey.sha256(), "612dbe8d1d24a693a2f676b1f4f72efafb21e01f189aaa68e4e1ad3975ff5a61", "Invalid verification key returned")

        let valid = try Swoirenberg.verify(proof: proof, proof_type: "honk")
        XCTAssertTrue(valid, "Failed to verify proof")
    }
}
