import XCTest
@testable import Swoirenberg

final class SwoirenbergTests: XCTestCase {
    func testProveAndVerify() throws {
        let circuitBytecodeBase64 = "H4sIAAAAAAAA/62QQQ6AMAgErfFBUKCFm1+xsf3/E9TYxka96SQEwmGyWTecjPu44aLdc93wDWzOu5cgMOfoMxIu4C2pAEsKioqisnolysoaLVkEQ6aMRYxKFY//ZYQj29T10XfhXv4PNvD4VlxNAQAA"
        let circuitBytecode = Data(base64Encoded: circuitBytecodeBase64)!
        let witnessMap = ["3", "5", "15"]

        let num_points = try Swoirenberg.setup_srs(bytecode: circuitBytecode)

        let proof = try Swoirenberg.prove(bytecode: circuitBytecode, witnessMap: witnessMap, proof_type: "plonk", num_points: num_points)
        XCTAssertEqual(proof.proof.count, 2176, "Invalid proof returned")
        XCTAssertEqual(proof.vkey.count, 1779, "Invalid verification key returned")
        XCTAssertEqual(proof.vkey.sha256(), "426892602ce2f8244c42213c695168cbee100ea2373e8869282fdec7d7467809", "Invalid verification key returned")

        let valid = try Swoirenberg.verify(proof: proof, proof_type: "plonk", num_points: num_points)
        XCTAssertTrue(valid, "Failed to verify proof")
    }


    func testProveAndVerifyHonk() throws {
        let circuitBytecodeBase64 = "H4sIAAAAAAAA/62QQQ6AMAgErfFBUKCFm1+xsf3/E9TYxka96SQEwmGyWTecjPu44aLdc93wDWzOu5cgMOfoMxIu4C2pAEsKioqisnolysoaLVkEQ6aMRYxKFY//ZYQj29T10XfhXv4PNvD4VlxNAQAA"
        let circuitBytecode = Data(base64Encoded: circuitBytecodeBase64)!
        let witnessMap = ["0x3", "0x5", "0xf"]

        let num_points = try Swoirenberg.setup_srs(bytecode: circuitBytecode)

        let proof = try Swoirenberg.prove(bytecode: circuitBytecode, witnessMap: witnessMap, proof_type: "honk", num_points: num_points)
        XCTAssertEqual(proof.proof.count, 14340, "Invalid proof returned")
        XCTAssertEqual(proof.vkey.count, 1825, "Invalid verification key returned")
        XCTAssertEqual(proof.vkey.sha256(), "55c139f690e5b10ed968b1ca8cf09703d6480c808a6e9bb77bbc3e2e64684dbf", "Invalid verification key returned")

        let valid = try Swoirenberg.verify(proof: proof, proof_type: "honk", num_points: num_points)
        XCTAssertTrue(valid, "Failed to verify proof")
    }
}
