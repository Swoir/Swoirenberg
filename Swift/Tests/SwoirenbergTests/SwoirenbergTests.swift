import XCTest
@testable import Swoirenberg

final class SwoirenbergTests: XCTestCase {
    func testProveAndVerify() throws {
        let circuitBytecodeBase64 = "H4sIAAAAAAAA/62QQQ6AMAgErfFBUKCFm1+xsf3/E9TYxka96SQEwmGyWTecjPu44aLdc93wDWzOu5cgMOfoMxIu4C2pAEsKioqisnolysoaLVkEQ6aMRYxKFY//ZYQj29T10XfhXv4PNvD4VlxNAQAA"
        let circuitBytecode = Data(base64Encoded: circuitBytecodeBase64)!
        let witnessMap = [Int64(3), Int64(5), Int64(15)]

        let num_points = try Swoirenberg.setup_srs(bytecode: circuitBytecode)

        let proof = try Swoirenberg.prove(bytecode: circuitBytecode, witnessMap: witnessMap, proof_type: "plonk", num_points: num_points)
        XCTAssertEqual(proof.proof.count, 2176, "Invalid proof returned")
        XCTAssertEqual(proof.vkey.count, 1719, "Invalid verification key returned")
        XCTAssertEqual(proof.vkey.sha256(), "7485f53732ab694457622a5fd0684f590cf9a64d7c7edfba4fe4bcbce09903a1", "Invalid verification key returned")

        let valid = try Swoirenberg.verify(proof: proof, proof_type: "plonk", num_points: num_points)
        XCTAssertTrue(valid, "Failed to verify proof")
    }


    func testProveAndVerifyHonk() throws {
        let circuitBytecodeBase64 = "H4sIAAAAAAAA/62QQQ6AMAgErfFBUKCFm1+xsf3/E9TYxka96SQEwmGyWTecjPu44aLdc93wDWzOu5cgMOfoMxIu4C2pAEsKioqisnolysoaLVkEQ6aMRYxKFY//ZYQj29T10XfhXv4PNvD4VlxNAQAA"
        let circuitBytecode = Data(base64Encoded: circuitBytecodeBase64)!
        let witnessMap = [Int64(3), Int64(5), Int64(15)]

        let num_points = try Swoirenberg.setup_srs(bytecode: circuitBytecode)

        let proof = try Swoirenberg.prove(bytecode: circuitBytecode, witnessMap: witnessMap, proof_type: "honk", num_points: num_points)
        XCTAssertEqual(proof.proof.count, 4068, "Invalid proof returned")
        XCTAssertEqual(proof.vkey.count, 1624, "Invalid verification key returned")
        XCTAssertEqual(proof.vkey.sha256(), "d11d852621c8691dab1d1d60eac2d5ff85fe02da16e7733425c2611b129c7a2f", "Invalid verification key returned")

        let valid = try Swoirenberg.verify(proof: proof, proof_type: "honk", num_points: num_points)
        XCTAssertTrue(valid, "Failed to verify proof")
    }
}
