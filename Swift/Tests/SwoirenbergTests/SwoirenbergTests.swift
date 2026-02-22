import XCTest
@testable import Swoirenberg

final class SwoirenbergTests: XCTestCase {
    func testProveAndVerify() throws {
        let circuitBytecodeBase64 = "H4sIAAAAAAAA/4XMPQ5AMBiA4aqLGNmIE4hITGIUiUHCYPCTshh7g37tYDWYHEDYXaSb0WLXE/DObx6dw7TUedVgoKvX9yUZ0pK0AsRpoO80pAE/DbuIiHRma4+DjdIkM90rHI8OfPmIW234F0JcSZgx9gL3WmBNjQAAAA=="
        let circuitBytecode = Data(base64Encoded: circuitBytecodeBase64)!
        let witnessMap = ["0x3", "0x5", "0xf"]

        // let num_points = try Swoirenberg.setup_srs_from_bytecode(bytecode: circuitBytecode)
        let num_points = try Swoirenberg.setup_srs(circuit_size: 500)

        let vkey = try Swoirenberg.get_verification_key(bytecode: circuitBytecode, proof_type: "ultra_honk")
        let proof = try Swoirenberg.prove(bytecode: circuitBytecode, witnessMap: witnessMap, proof_type: "ultra_honk", vkey: vkey)
        XCTAssertEqual(proof.count, 16036, "Invalid proof returned")
        XCTAssertEqual(vkey.count, 3680, "Invalid verification key returned")
        XCTAssertEqual(vkey.sha256(), "5ccf2ea73cfe518309d753df1f52ee1acffcc0ebce025c9303abd9bea2ee9312", "Invalid verification key returned")

        let valid = try Swoirenberg.verify(proof: proof, vkey: vkey, proof_type: "ultra_honk")
        XCTAssertTrue(valid, "Failed to verify proof")
    }

    func testProveAndVerifyKeccak() throws {
        let circuitBytecodeBase64 = "H4sIAAAAAAAA/4XMPQ5AMBiA4aqLGNmIE4hITGIUiUHCYPCTshh7g37tYDWYHEDYXaSb0WLXE/DObx6dw7TUedVgoKvX9yUZ0pK0AsRpoO80pAE/DbuIiHRma4+DjdIkM90rHI8OfPmIW234F0JcSZgx9gL3WmBNjQAAAA=="
        let circuitBytecode = Data(base64Encoded: circuitBytecodeBase64)!
        let witnessMap = ["0x3", "0x5", "0xf"]

        //let num_points = try Swoirenberg.setup_srs_from_bytecode(bytecode: circuitBytecode)
        let num_points = try Swoirenberg.setup_srs(circuit_size: 500)

        let vkey = try Swoirenberg.get_verification_key(bytecode: circuitBytecode, proof_type: "ultra_honk_keccak")
        let proof = try Swoirenberg.prove(bytecode: circuitBytecode, witnessMap: witnessMap, proof_type: "ultra_honk_keccak", vkey: vkey)
        XCTAssertEqual(proof.count, 4964, "Invalid proof returned")
        XCTAssertEqual(vkey.count, 1888, "Invalid verification key returned")
        XCTAssertEqual(vkey.sha256(), "bff0cdab27ece0f8b843353a145933c507f2c3733516e1fb8c7d91a39d4c043e", "Invalid verification key returned")

        let valid = try Swoirenberg.verify(proof: proof, vkey: vkey, proof_type: "ultra_honk_keccak")
        XCTAssertTrue(valid, "Failed to verify proof")
    }

    func testExecute() throws {
        let circuitBytecodeBase64 = "H4sIAAAAAAAA/4XMPQ5AMBiA4aqLGNmIE4hITGIUiUHCYPCTshh7g37tYDWYHEDYXaSb0WLXE/DObx6dw7TUedVgoKvX9yUZ0pK0AsRpoO80pAE/DbuIiHRma4+DjdIkM90rHI8OfPmIW234F0JcSZgx9gL3WmBNjQAAAA=="
        let circuitBytecode = Data(base64Encoded: circuitBytecodeBase64)!
        let witnessMap = ["3", "5"]

        let solvedWitness = try Swoirenberg.execute(bytecode: circuitBytecode, witnessMap: witnessMap)
        // 3 x 5 = 15 (0xf) and this should be the third value in the witness map
        XCTAssertEqual(solvedWitness, ["0x0000000000000000000000000000000000000000000000000000000000000003", "0x0000000000000000000000000000000000000000000000000000000000000005", "0x000000000000000000000000000000000000000000000000000000000000000f"])
    }
}
