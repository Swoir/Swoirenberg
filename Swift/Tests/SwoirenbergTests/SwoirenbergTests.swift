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
        XCTAssertEqual(proof.vkey.sha256(), "8c0b1853d3ea54b28c620a4a73a5045a29377372a93b7deffec65df0cebb5500", "Invalid verification key returned")

        let valid = try Swoirenberg.verify(proof: proof, proof_type: "plonk", num_points: num_points)
        XCTAssertTrue(valid, "Failed to verify proof")
    }


    func testProveAndVerifyHonk() throws {
        let circuitBytecodeBase64 = "H4sIAAAAAAAA/62QQQ6AMAgErfFBUKCFm1+xsf3/E9TYxka96SQEwmGyWTecjPu44aLdc93wDWzOu5cgMOfoMxIu4C2pAEsKioqisnolysoaLVkEQ6aMRYxKFY//ZYQj29T10XfhXv4PNvD4VlxNAQAA"
        let circuitBytecode = Data(base64Encoded: circuitBytecodeBase64)!
        let witnessMap = [Int64(3), Int64(5), Int64(15)]

        let num_points = try Swoirenberg.setup_srs(bytecode: circuitBytecode)

        let proof = try Swoirenberg.prove(bytecode: circuitBytecode, witnessMap: witnessMap, proof_type: "honk", num_points: num_points)
        XCTAssertEqual(proof.proof.count, 12612, "Invalid proof returned")
        XCTAssertEqual(proof.vkey.count, 1632, "Invalid verification key returned")
        XCTAssertEqual(proof.vkey.sha256(), "046f7f0c94da7e4d301f10227a2e50e49d408a567b447b150babd6f58e6d6c79", "Invalid verification key returned")

        let valid = try Swoirenberg.verify(proof: proof, proof_type: "honk", num_points: num_points)
        XCTAssertTrue(valid, "Failed to verify proof")
    }
}
