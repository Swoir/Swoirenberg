import Foundation
import SwiftBridge
import SwoirCore

public class Swoirenberg: SwoirBackendProtocol {

    public static func prove(bytecode: Data, witnessMap: [Int64]) throws -> SwoirCore.Proof {
        if bytecode.isEmpty { throw SwoirBackendError.emptyBytecode }
        if witnessMap.isEmpty { throw SwoirBackendError.emptyWitnessMap }
        let bytecodeBase64 = bytecode.base64EncodedString()
        let witnessMapRustVec = RustVec<Int64>(from: witnessMap)

        guard let proofResult = prove_swift(bytecodeBase64, witnessMapRustVec) else {
            throw SwoirBackendError.errorProving("Error generating proof")
        }
        let proof = SwoirCore.Proof(
            proof: Data(bytes: proofResult.proof_data_ptr(), count: Int(proofResult.proof_data_len())),
            vkey: Data(bytes: proofResult.vkey_data_ptr(), count: Int(proofResult.vkey_data_len())))
        return proof
    }

    public static func verify(bytecode: Data, proof: SwoirCore.Proof) throws -> Bool {
        if bytecode.isEmpty { throw SwoirBackendError.emptyBytecode }
        if proof.proof.isEmpty { throw SwoirBackendError.emptyProofData }
        if proof.vkey.isEmpty { throw SwoirBackendError.emptyVerificationKey }
        let bytecodeBase64 = bytecode.base64EncodedString()

        let verified = verify_swift(bytecodeBase64, RustVec<UInt8>(from: proof.proof), RustVec<UInt8>(from: proof.vkey)) ?? false
        return verified
    }
}
