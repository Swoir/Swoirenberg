import XCTest
@testable import Swoirenberg

final class SwoirenbergTests: XCTestCase {
    func testProveAndVerify() throws {
        let circuitBytecodeBase64 = "H4sIAAAAAAAA/42NsQmAMBBF74KDWGqnOIIIVmJpYyHYWChiZ5kRxAWcQnScdJY29gZNSAgp8or7x93/fIQfT2jfdAPhiqCQuw9OoBxmLmqLicVbeJTZTmlVB8mVz+e4pOxZb/4n7h2fVy9Ey93kBZmTjiLsAAAA"
        let circuitBytecode = Data(base64Encoded: circuitBytecodeBase64)!
        let witnessMap = ["0x3", "0x5", "0xf"]

        // let num_points = try Swoirenberg.setup_srs_from_bytecode(bytecode: circuitBytecode)
        let num_points = try Swoirenberg.setup_srs(circuit_size: 500)

        let vkey = try Swoirenberg.get_verification_key(bytecode: circuitBytecode, proof_type: "ultra_honk")
        let proof = try Swoirenberg.prove(bytecode: circuitBytecode, witnessMap: witnessMap, proof_type: "ultra_honk", vkey: vkey)
        XCTAssertEqual(proof.count, 16288, "Invalid proof returned")
        XCTAssertEqual(vkey.count, 3680, "Invalid verification key returned")
        XCTAssertEqual(vkey.sha256(), "8826f473e435f9292db370d9497f9a58488ddbe141b9fdacdd77ea07cada1a8a", "Invalid verification key returned")

        let valid = try Swoirenberg.verify(proof: proof, vkey: vkey, proof_type: "ultra_honk")
        XCTAssertTrue(valid, "Failed to verify proof")
    }

    func testProveAndVerifyKeccak() throws {
        let circuitBytecodeBase64 = "H4sIAAAAAAAA/42NsQmAMBBF74KDWGqnOIIIVmJpYyHYWChiZ5kRxAWcQnScdJY29gZNSAgp8or7x93/fIQfT2jfdAPhiqCQuw9OoBxmLmqLicVbeJTZTmlVB8mVz+e4pOxZb/4n7h2fVy9Ey93kBZmTjiLsAAAA"
        let circuitBytecode = Data(base64Encoded: circuitBytecodeBase64)!
        let witnessMap = ["0x3", "0x5", "0xf"]

        //let num_points = try Swoirenberg.setup_srs_from_bytecode(bytecode: circuitBytecode)
        let num_points = try Swoirenberg.setup_srs(circuit_size: 500)

        let vkey = try Swoirenberg.get_verification_key(bytecode: circuitBytecode, proof_type: "ultra_honk_keccak")
        let proof = try Swoirenberg.prove(bytecode: circuitBytecode, witnessMap: witnessMap, proof_type: "ultra_honk_keccak", vkey: vkey)
        XCTAssertEqual(proof.count, 5216, "Invalid proof returned")
        XCTAssertEqual(vkey.count, 1888, "Invalid verification key returned")
        XCTAssertEqual(vkey.sha256(), "2b4fcd1aac6944bcf4578f2e484b399329ad23d0591737ca4c745b7562d8d33f", "Invalid verification key returned")

        let valid = try Swoirenberg.verify(proof: proof, vkey: vkey, proof_type: "ultra_honk_keccak")
        XCTAssertTrue(valid, "Failed to verify proof")
    }

    func testExecute() throws {
        let circuitBytecodeBase64 = "H4sIAAAAAAAA/42NsQmAMBBF74KDWGqnOIIIVmJpYyHYWChiZ5kRxAWcQnScdJY29gZNSAgp8or7x93/fIQfT2jfdAPhiqCQuw9OoBxmLmqLicVbeJTZTmlVB8mVz+e4pOxZb/4n7h2fVy9Ey93kBZmTjiLsAAAA"
        let circuitBytecode = Data(base64Encoded: circuitBytecodeBase64)!
        let witnessMap = ["3", "5"]

        let solvedWitness = try Swoirenberg.execute(bytecode: circuitBytecode, witnessMap: witnessMap)
        // 3 x 5 = 15 (0xf) and this should be the third value in the witness map
        XCTAssertEqual(solvedWitness, ["0x0000000000000000000000000000000000000000000000000000000000000003", "0x0000000000000000000000000000000000000000000000000000000000000005", "0x000000000000000000000000000000000000000000000000000000000000000f"])
    }
}
