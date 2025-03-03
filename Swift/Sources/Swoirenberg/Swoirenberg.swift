import Foundation
import SwoirCore

public class Swoirenberg: SwoirBackendProtocol {

    public static func setup_srs(bytecode: Data, srs_path: String? = nil, recursive: Bool = false) throws -> UInt32 {
        if bytecode.isEmpty { throw SwoirBackendError.emptyBytecode }
        let bytecodeBase64 = bytecode.base64EncodedString()
        guard let result = setup_srs_swift(bytecodeBase64, srs_path, recursive) else {
            throw SwoirBackendError.errorSettingUpSRS
        }
        return result
    }

    public static func prove(bytecode: Data, witnessMap: [String], proof_type: String, recursive: Bool) throws -> SwoirCore.Proof {
        if bytecode.isEmpty { throw SwoirBackendError.emptyBytecode }
        if witnessMap.isEmpty { throw SwoirBackendError.emptyWitnessMap }
        let bytecodeBase64 = bytecode.base64EncodedString()
        let witnessMapRustVec = RustVec<RustString>.init()
        for witness in witnessMap {
            witnessMapRustVec.push(value: witness.intoRustString())
        }

        guard let proofResult = prove_swift(bytecodeBase64.intoRustString(), witnessMapRustVec, proof_type.intoRustString(), recursive) else {
            throw SwoirBackendError.errorProving("Error generating proof")
        }
        let proof = SwoirCore.Proof(
            proof: Data(bytes: proofResult.proof_data_ptr(), count: Int(proofResult.proof_data_len())),
            vkey: Data(bytes: proofResult.vkey_data_ptr(), count: Int(proofResult.vkey_data_len())))
        return proof
    }

    public static func verify(proof: SwoirCore.Proof, proof_type: String) throws -> Bool {
        if proof.proof.isEmpty { throw SwoirBackendError.emptyProofData }
        if proof.vkey.isEmpty { throw SwoirBackendError.emptyVerificationKey }

        let verified = verify_swift(RustVec<UInt8>(from: proof.proof), RustVec<UInt8>(from: proof.vkey), proof_type) ?? false
        return verified
    }

    public static func execute(bytecode: Data, witnessMap: [String]) throws -> [String] {
        if bytecode.isEmpty { throw SwoirBackendError.emptyBytecode }
        if witnessMap.isEmpty { throw SwoirBackendError.emptyWitnessMap }
        let bytecodeBase64 = bytecode.base64EncodedString()
        let witnessMapRustVec = RustVec<RustString>.init()
        for witness in witnessMap {
            witnessMapRustVec.push(value: witness.intoRustString())
        }

        guard let witnessResult = execute_swift(bytecodeBase64.intoRustString(), witnessMapRustVec) else {
            throw SwoirBackendError.errorExecuting("Error executing circuit")
        }
        return witnessResult.map { $0.as_str().toString() }
    }
}
