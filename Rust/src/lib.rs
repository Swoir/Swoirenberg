use noir_rs::{
    barretenberg::{prove::{prove_ultra_honk, prove_ultra_honk_keccak}, srs::{setup_srs, setup_srs_from_bytecode}, verify::{verify_ultra_honk, get_ultra_honk_verification_key, verify_ultra_keccak_honk, get_ultra_honk_keccak_verification_key}}, execute::execute, native_types::{Witness, WitnessMap}, AcirField, FieldElement
};

// Expose functions using FFI and swift-bridge so we can call them in Swift
#[swift_bridge::bridge]
mod ffi {
    extern "Rust" {
        fn setup_srs_swift(circuit_size: u32, srs_path: Option<&str>) -> Option<u32>;
        fn setup_srs_from_bytecode_swift(circuit_bytecode: String, srs_path: Option<&str>) -> Option<u32>;
        fn prove_swift(circuit_bytecode: String, initial_witness: Vec<String>, proof_type: String, vkey: Vec<u8>) -> Option<Vec<u8>>;
        fn verify_swift(proof: Vec<u8>, vkey: Vec<u8>, proof_type: String) -> Option<bool>;
        fn execute_swift(circuit_bytecode: String, initial_witness: Vec<String>) -> Option<Vec<String>>;
        fn get_vkey_swift(circuit_bytecode: String, proof_type: String) -> Option<Vec<u8>>;
    }
}

/// Generates a zkSNARK proof from given bytecode and witness values.
///
/// This function converts the initial witness vector from i64 values to FieldElement values, then creates a WitnessMap
/// from these values. Using the provided circuit bytecode and this WitnessMap, it generates the zkSNARK proof.
///
/// # Parameters
/// - `circuit_bytecode`: The base64 encoded bytecode of the ACIR circuit against which the proof needs to be generated.
/// - `initial_witness`: The initial witness values represented as a vector of i64.
/// - `proof_type`: "ultra_honk" or "ultra_honk_keccak"
/// - `vkey`: The verification key for the circuit.
///
/// # Returns
/// - `Option<Vec<u8>>`: The generated proof and its associated verification key wrapped in a `Proof` struct. Returns `None` if the proof generation fails.
pub fn prove_swift(circuit_bytecode: String, initial_witness: Vec<String>, proof_type: String, vkey: Vec<u8>) -> Option<Vec<u8>> {
    let initial_witness_vec: Vec<FieldElement> = initial_witness
        .into_iter()
        .map(|s| FieldElement::try_from_str(&s).unwrap())
        .collect();
    let mut initial_witness = WitnessMap::new();
    for (i, witness) in initial_witness_vec.into_iter().enumerate() {
        initial_witness.insert(Witness(i as u32), witness);
    }

    if proof_type == "ultra_honk" {
        let proof = prove_ultra_honk(&circuit_bytecode, initial_witness, vkey).ok()?;
        return Some(proof);
    } else if proof_type == "ultra_honk_keccak" {
        let proof = prove_ultra_honk_keccak(&circuit_bytecode, initial_witness, vkey, false).ok()?;
        return Some(proof);
    } else {
        println!("Unsupported proof type");
        return None;
    }
}

/// Verifies a given zkSNARK proof using the associated circuit bytecode and verification key.
///
/// This function takes in the circuit bytecode, the generated proof, and the circuit verification key, then verifies
/// the correctness of the proof.
///
/// # Parameters
/// - `proof`: The proof to be verified.
/// - `vkey`: The circuit verification key.
/// - `proof_type`: "ultra_honk" or "ultra_honk_keccak"
///
/// # Returns
/// - `Option<bool>`: Returns `true` if the proof is valid, `false` otherwise. Returns `None` if the verification process fails.
pub fn verify_swift(proof: Vec<u8>, vkey: Vec<u8>, proof_type: String) -> Option<bool> {
    if proof_type == "ultra_honk" {
        verify_ultra_honk(proof, vkey).ok()
    } else if proof_type == "ultra_honk_keccak" {
        verify_ultra_keccak_honk(proof, vkey, false).ok()
    } else {
        println!("Unsupported proof type");
        return None;
    }

}

/// Sets up the SRS for the zkSNARK proof generation process.
/// 
/// This function sets up the SRS for the zkSNARK proof generation process using the provided circuit size and
/// the path to the file where the SRS needs to be stored.
/// 
/// # Parameters
/// - `circuit_size`: The size of the circuit.
/// - `srs_path`: The path to the file where the SRS needs to be stored. If `None`, the SRS will be fetched online.
/// 
/// # Returns
/// - `Option<u32>`: The size of the SRS needed for the circuit
pub fn setup_srs_swift(circuit_size: u32, srs_path: Option<&str>) -> Option<u32> {
    setup_srs(circuit_size, srs_path).ok()
}

/// Sets up the SRS for the zkSNARK proof generation process.
/// 
/// This function sets up the SRS for the zkSNARK proof generation process using the provided circuit bytecode as
/// as a base to compute the circuit size and set up the SRS accordingly for the circuit.
/// 
/// # Parameters
/// - `circuit_bytecode`: The base64 encoded bytecode of the ACIR circuit against which the SRS needs to be set up.
/// - `srs_path`: The path to the file where the SRS needs to be stored. If `None`, the SRS will be fetched online.
/// 
/// # Returns
/// - `Option<u32>`: The size of the SRS needed for the circuit
pub fn setup_srs_from_bytecode_swift(circuit_bytecode: String, srs_path: Option<&str>) -> Option<u32> {
    setup_srs_from_bytecode(&circuit_bytecode, srs_path, false).ok()
}


/// Executes the circuit with the given initial witness values.
/// 
/// This function takes in the circuit bytecode and the initial witness values, then executes the circuit with the given witness values.
/// 
/// # Parameters
/// - `circuit_bytecode`: The base64 encoded bytecode of the ACIR circuit to be executed.
/// - `initial_witness`: The initial witness values represented as a vector of i64.
/// 
/// # Returns
/// - `Option<Vec<String>>`: The witness values returned by the circuit wrapped in a `Vec<String>`. Returns `None` if the execution fails.
pub fn execute_swift(circuit_bytecode: String, initial_witness: Vec<String>) -> Option<Vec<String>> {
    let initial_witness_vec: Vec<FieldElement> = initial_witness
    .into_iter()
    .map(|s| FieldElement::try_from_str(&s).unwrap())
    .collect();
    let mut initial_witness_final = WitnessMap::new();
    for (i, witness) in initial_witness_vec.into_iter().enumerate() {
        initial_witness_final.insert(Witness(i as u32), witness);
    }

    let witness = execute(&circuit_bytecode, initial_witness_final).ok()?;
    let witness_map = &witness.peek().into_iter().last()?.witness;
    let witness_vec = witness_map.clone().into_iter().map(|(i, val)| format!("0x{}", val.to_hex())).collect();
    Some(witness_vec)
}

/// Gets the verification key for the given circuit bytecode.
/// 
/// This function takes in the circuit bytecode, then computes the verification key for the circuit.
/// 
/// # Parameters
/// - `circuit_bytecode`: The base64 encoded bytecode of the ACIR circuit against which the verification key needs to be computed.
/// - `proof_type`: "ultra_honk" or "ultra_honk_keccak"
/// 
/// # Returns
/// - `Option<Vec<u8>>`: The verification key for the circuit wrapped in a `Vec<u8>`. Returns `None` if the verification key computation fails.
pub fn get_vkey_swift(circuit_bytecode: String, proof_type: String) -> Option<Vec<u8>> {
    if proof_type == "ultra_honk" {
        get_ultra_honk_verification_key(&circuit_bytecode).ok()
    } else if proof_type == "ultra_honk_keccak" {
        get_ultra_honk_keccak_verification_key(&circuit_bytecode, false).ok()
    } else {
        println!("Unsupported proof type");
        return None;
    }
}
