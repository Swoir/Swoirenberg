import Foundation
import SwoirCore

public class Swoirenberg: SwoirBackendProtocol {

    public static func setup_srs(circuit_size: UInt32, srs_path: String? = nil) throws -> UInt32 {
        if circuit_size == 0 { throw SwoirBackendError.nonPositiveCircuitSize }
        guard let result = setup_srs_swift(circuit_size, srs_path) else {
            throw SwoirBackendError.errorSettingUpSRS
        }
        return result
    }

    public static func setup_srs_from_bytecode(bytecode: Data, srs_path: String? = nil) throws -> UInt32 {
        if bytecode.isEmpty { throw SwoirBackendError.emptyBytecode }
        let bytecodeBase64 = bytecode.base64EncodedString()
        guard let result = setup_srs_from_bytecode_swift(bytecodeBase64, srs_path) else {
            throw SwoirBackendError.errorSettingUpSRS
        }
        return result
    }

    public static func prove(bytecode: Data, witnessMap: [String], proof_type: String, vkey: Data) throws -> Data {
        if bytecode.isEmpty { throw SwoirBackendError.emptyBytecode }
        if witnessMap.isEmpty { throw SwoirBackendError.emptyWitnessMap }
        let bytecodeBase64 = bytecode.base64EncodedString()
        let witnessMapRustVec = RustVec<RustString>.init()
        for witness in witnessMap {
            witnessMapRustVec.push(value: witness.intoRustString())
        }

        guard let proofResult = prove_swift(bytecodeBase64.intoRustString(), witnessMapRustVec, proof_type.intoRustString(), RustVec<UInt8>(from: vkey)) else {
            throw SwoirBackendError.errorProving("Error generating proof")
        }
        return Data(bytes: proofResult)
    }

    public static func verify(proof: Data, vkey: Data, proof_type: String) throws -> Bool {
        if proof.isEmpty { throw SwoirBackendError.emptyProofData }
        if vkey.isEmpty { throw SwoirBackendError.emptyVerificationKey }

        let verified = verify_swift(RustVec<UInt8>(from: proof), RustVec<UInt8>(from: vkey), proof_type) ?? false
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

    public static func get_verification_key(bytecode: Data, proof_type: String) throws -> Data {
        if bytecode.isEmpty { throw SwoirBackendError.emptyBytecode }
        let bytecodeBase64 = bytecode.base64EncodedString()
        guard let result = get_vkey_swift(bytecodeBase64.intoRustString(), proof_type.intoRustString()) else {
            throw SwoirBackendError.errorGettingVerificationKey
        }
        return Data(bytes: result)
    }
}