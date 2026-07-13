import XCTest
@testable import Swoirenberg

final class SwoirenbergTests: XCTestCase {
    func testProveAndVerify() throws {
        let circuitBytecodeBase64 = "H4sIAAAAAAAA/4XMPQ5AMBiA4eIiRjbiBCISkxhFYpAwGPykLMbeoF+bmA0mBxD2XqSb0WLXE/DObx6Dwbw2Rd0C2fxhqPCYVbjjwIWJvtOQBkyYThlj6S72kYQ7IWlueVc0nT0E8uG32vRfCDEl6ZTSFyS2vOeMAAAA"
        let circuitBytecode = Data(base64Encoded: circuitBytecodeBase64)!
        let witnessMap = ["0x3", "0x5", "0xf"]

        // let num_points = try Swoirenberg.setup_srs_from_bytecode(bytecode: circuitBytecode)
        let num_points = try Swoirenberg.setup_srs(circuit_size: 500)

        let vkey = try Swoirenberg.get_verification_key(bytecode: circuitBytecode, proof_type: "ultra_honk")
        let proof = try Swoirenberg.prove(bytecode: circuitBytecode, witnessMap: witnessMap, proof_type: "ultra_honk", vkey: vkey)
        XCTAssertEqual(proof.count, 14692, "Invalid proof returned")
        XCTAssertEqual(vkey.count, 3680, "Invalid verification key returned")
        XCTAssertEqual(vkey.sha256(), "fe1fd63f6e4789bb275dadf3c3b8b16eeaa101eeae2c75af82fc54d1c490f39e", "Invalid verification key returned")

        let valid = try Swoirenberg.verify(proof: proof, vkey: vkey, proof_type: "ultra_honk")
        XCTAssertTrue(valid, "Failed to verify proof")
    }

    func testProveAndVerifyKeccak() throws {
        let circuitBytecodeBase64 = "H4sIAAAAAAAA/4XMPQ5AMBiA4eIiRjbiBCISkxhFYpAwGPykLMbeoF+bmA0mBxD2XqSb0WLXE/DObx6Dwbw2Rd0C2fxhqPCYVbjjwIWJvtOQBkyYThlj6S72kYQ7IWlueVc0nT0E8uG32vRfCDEl6ZTSFyS2vOeMAAAA"
        let circuitBytecode = Data(base64Encoded: circuitBytecodeBase64)!
        let witnessMap = ["0x3", "0x5", "0xf"]

        //let num_points = try Swoirenberg.setup_srs_from_bytecode(bytecode: circuitBytecode)
        let num_points = try Swoirenberg.setup_srs(circuit_size: 500)

        let vkey = try Swoirenberg.get_verification_key(bytecode: circuitBytecode, proof_type: "ultra_honk_keccak")
        let proof = try Swoirenberg.prove(bytecode: circuitBytecode, witnessMap: witnessMap, proof_type: "ultra_honk_keccak", vkey: vkey)
        XCTAssertEqual(proof.count, 4580, "Invalid proof returned")
        XCTAssertEqual(vkey.count, 1888, "Invalid verification key returned")
        XCTAssertEqual(vkey.sha256(), "38b5240203f57efb2345eacb75272d6ca191c634fd12132b3d7e2e70d7f8ddbf", "Invalid verification key returned")

        let valid = try Swoirenberg.verify(proof: proof, vkey: vkey, proof_type: "ultra_honk_keccak")
        XCTAssertTrue(valid, "Failed to verify proof")
    }

    func testExecute() throws {
        let circuitBytecodeBase64 = "H4sIAAAAAAAA/4XMPQ5AMBiA4eIiRjbiBCISkxhFYpAwGPykLMbeoF+bmA0mBxD2XqSb0WLXE/DObx6Dwbw2Rd0C2fxhqPCYVbjjwIWJvtOQBkyYThlj6S72kYQ7IWlueVc0nT0E8uG32vRfCDEl6ZTSFyS2vOeMAAAA"
        let circuitBytecode = Data(base64Encoded: circuitBytecodeBase64)!
        let witnessMap = ["3", "5"]

        let solvedWitness = try Swoirenberg.execute(bytecode: circuitBytecode, witnessMap: witnessMap)
        // 3 x 5 = 15 (0xf) and this should be the third value in the witness map
        XCTAssertEqual(solvedWitness, ["0x0000000000000000000000000000000000000000000000000000000000000003", "0x0000000000000000000000000000000000000000000000000000000000000005", "0x000000000000000000000000000000000000000000000000000000000000000f"])
    }
}
