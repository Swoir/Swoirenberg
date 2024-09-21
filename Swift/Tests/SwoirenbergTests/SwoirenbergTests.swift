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
        XCTAssertEqual(proof.vkey.count, 1779, "Invalid verification key returned")
        XCTAssertEqual(proof.vkey.sha256(), "426892602ce2f8244c42213c695168cbee100ea2373e8869282fdec7d7467809", "Invalid verification key returned")

        let valid = try Swoirenberg.verify(proof: proof, proof_type: "plonk", num_points: num_points)
        XCTAssertTrue(valid, "Failed to verify proof")
    }


    func testProveAndVerifyHonk() throws {
        let circuitBytecodeBase64 = "H4sIAAAAAAAA/62QQQ6AMAgErfFBUKCFm1+xsf3/E9TYxka96SQEwmGyWTecjPu44aLdc93wDWzOu5cgMOfoMxIu4C2pAEsKioqisnolysoaLVkEQ6aMRYxKFY//ZYQj29T10XfhXv4PNvD4VlxNAQAA"
        let circuitBytecode = Data(base64Encoded: circuitBytecodeBase64)!
        let witnessMap = [Int64(3), Int64(5), Int64(15)]

        let num_points = try Swoirenberg.setup_srs(bytecode: circuitBytecode)

        let proof = try Swoirenberg.prove(bytecode: circuitBytecode, witnessMap: witnessMap, proof_type: "honk", num_points: num_points)
        XCTAssertEqual(proof.proof.count, 13572, "Invalid proof returned")
        XCTAssertEqual(proof.vkey.count, 1825, "Invalid verification key returned")
        XCTAssertEqual(proof.vkey.sha256(), "8a027b21fe7066652ed4a9246d0cbef0d31f9284462b872ee06a2f6a8105a59c", "Invalid verification key returned")

        let valid = try Swoirenberg.verify(proof: proof, proof_type: "honk", num_points: num_points)
        XCTAssertTrue(valid, "Failed to verify proof")
    }
}
