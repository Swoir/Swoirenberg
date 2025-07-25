import XCTest
@testable import Swoirenberg

final class SwoirenbergTests: XCTestCase {
    func testProveAndVerify() throws {
        let circuitBytecodeBase64 = "H4sIAAAAAAAA/62QQQqAMAwErfigpEna5OZXLLb/f4KKLZbiTQdCQg7Dsm66mc9x00O717rhG9ico5cgMOfoMxJu4C2pAEsKioqisnslysoaLVkEQ6aMRYxKFc//ZYQr29L10XfhXv4jB52E+OpMAQAA"
        let circuitBytecode = Data(base64Encoded: circuitBytecodeBase64)!
        let witnessMap = ["0x3", "0x5", "0xf"]

        let num_points = try Swoirenberg.setup_srs_from_bytecode(bytecode: circuitBytecode)

        let vkey = try Swoirenberg.get_verification_key(bytecode: circuitBytecode, proof_type: "ultra_honk")
        let proof = try Swoirenberg.prove(bytecode: circuitBytecode, witnessMap: witnessMap, proof_type: "ultra_honk", vkey: vkey)
        XCTAssertEqual(proof.count, 16288, "Invalid proof returned")
        XCTAssertEqual(vkey.count, 1816, "Invalid verification key returned")
        XCTAssertEqual(vkey.sha256(), "5d655dd393ef64156446080db6521c8f5af9ab3798c314cd6ed02cb72d41f7cb", "Invalid verification key returned")

        let valid = try Swoirenberg.verify(proof: proof, vkey: vkey, proof_type: "ultra_honk")
        XCTAssertTrue(valid, "Failed to verify proof")
    }

    func testProveAndVerifyKeccak() throws {
        let circuitBytecodeBase64 = "H4sIAAAAAAAA/62QQQqAMAwErfigpEna5OZXLLb/f4KKLZbiTQdCQg7Dsm66mc9x00O717rhG9ico5cgMOfoMxJu4C2pAEsKioqisnslysoaLVkEQ6aMRYxKFc//ZYQr29L10XfhXv4jB52E+OpMAQAA"
        let circuitBytecode = Data(base64Encoded: circuitBytecodeBase64)!
        let witnessMap = ["0x3", "0x5", "0xf"]

        let num_points = try Swoirenberg.setup_srs_from_bytecode(bytecode: circuitBytecode)

        let vkey = try Swoirenberg.get_verification_key(bytecode: circuitBytecode, proof_type: "ultra_honk_keccak")
        let proof = try Swoirenberg.prove(bytecode: circuitBytecode, witnessMap: witnessMap, proof_type: "ultra_honk_keccak", vkey: vkey)
        XCTAssertEqual(proof.count, 16288, "Invalid proof returned")
        XCTAssertEqual(vkey.count, 1816, "Invalid verification key returned")
        XCTAssertEqual(vkey.sha256(), "5d655dd393ef64156446080db6521c8f5af9ab3798c314cd6ed02cb72d41f7cb", "Invalid verification key returned")

        let valid = try Swoirenberg.verify(proof: proof, vkey: vkey, proof_type: "ultra_honk_keccak")
        XCTAssertTrue(valid, "Failed to verify proof")
    }

    func testExecute() throws {
        let circuitBytecodeBase64 = "H4sIAAAAAAAA/62QQQqAMAwErfigpEna5OZXLLb/f4KKLZbiTQdCQg7Dsm66mc9x00O717rhG9ico5cgMOfoMxJu4C2pAEsKioqisnslysoaLVkEQ6aMRYxKFc//ZYQr29L10XfhXv4jB52E+OpMAQAA"
        let circuitBytecode = Data(base64Encoded: circuitBytecodeBase64)!
        let witnessMap = ["3", "5"]

        let solvedWitness = try Swoirenberg.execute(bytecode: circuitBytecode, witnessMap: witnessMap)
        // 3 x 5 = 15 (0xf) and this should be the third value in the witness map
        XCTAssertEqual(solvedWitness, ["0x0000000000000000000000000000000000000000000000000000000000000003", "0x0000000000000000000000000000000000000000000000000000000000000005", "0x000000000000000000000000000000000000000000000000000000000000000f"])
    }
}
