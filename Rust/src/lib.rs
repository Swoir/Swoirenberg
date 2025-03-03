use noir_rs::{
    barretenberg::{prove::prove_ultra_honk, srs::setup_srs, verify::verify_ultra_honk}, execute::execute, native_types::{Witness, WitnessMap}, AcirField, FieldElement
};

// Expose functions using FFI and swift-bridge so we can call them in Swift
#[swift_bridge::bridge]
mod ffi {
    extern "Rust" {
        type Proof;
        fn setup_srs_swift(circuit_bytecode: String, srs_path: Option<&str>, recursive: bool) -> Option<u32>;
        fn prove_swift(circuit_bytecode: String, initial_witness: Vec<String>, proof_type: String, recursive: bool) -> Option<Proof>;
        fn verify_swift(proof: Vec<u8>, vkey: Vec<u8>, proof_type: String) -> Option<bool>;
        fn execute_swift(circuit_bytecode: String, initial_witness: Vec<String>) -> Option<Vec<String>>;
        fn proof_data_ptr(&self) -> *const u8;
        fn proof_data_len(&self) -> usize;
        fn vkey_data_ptr(&self) -> *const u8;
        fn vkey_data_len(&self) -> usize;
    }
}

pub struct Proof {
    pub proof: Vec<u8>,
    pub vkey: Vec<u8>,
}
impl Proof {
    pub fn proof_data_ptr(&self) -> *const u8 {
        self.proof.as_ptr()
    }
    pub fn proof_data_len(&self) -> usize {
        self.proof.len()
    }
    pub fn vkey_data_ptr(&self) -> *const u8 {
        self.vkey.as_ptr()
    }
    pub fn vkey_data_len(&self) -> usize {
        self.vkey.len()
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
/// - `proof_type`: The type of proof to be generated. Can only be "honk" at the moment.
///
/// # Returns
/// - `Option<Proof>`: The generated proof and its associated verification key wrapped in a `Proof` struct. Returns `None` if the proof generation fails.
pub fn prove_swift(circuit_bytecode: String, initial_witness: Vec<String>, proof_type: String, recursive: bool) -> Option<Proof> {
    let initial_witness_vec: Vec<FieldElement> = initial_witness
        .into_iter()
        .map(|s| FieldElement::try_from_str(&s).unwrap())
        .collect();
    let mut initial_witness = WitnessMap::new();
    for (i, witness) in initial_witness_vec.into_iter().enumerate() {
        initial_witness.insert(Witness(i as u32), witness);
    }

    if proof_type == "honk" {
        let (proof, vkey) = prove_ultra_honk(&circuit_bytecode, initial_witness, recursive).ok()?;
        return Some(Proof {
            proof,
            vkey,
        });
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
/// - `proof_type`: The type of proof to be verified. Can only be "honk" at the moment.
///
/// # Returns
/// - `Option<bool>`: Returns `true` if the proof is valid, `false` otherwise. Returns `None` if the verification process fails.
pub fn verify_swift(proof: Vec<u8>, vkey: Vec<u8>, proof_type: String) -> Option<bool> {
    if proof_type == "honk" {
        verify_ultra_honk(proof, vkey).ok()
    } else {
        println!("Unsupported proof type");
        return None;
    }

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
pub fn setup_srs_swift(circuit_bytecode: String, srs_path: Option<&str>, recursive: bool) -> Option<u32> {
    setup_srs(&circuit_bytecode, srs_path, recursive).ok()
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
