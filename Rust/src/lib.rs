use noir_rs::{
    native_types::{Witness, WitnessMap},
    prove::prove,
    verify::verify,
    FieldElement,
};

// Expose functions using FFI and swift-bridge so we can call them in Swift
#[swift_bridge::bridge]
mod ffi {
    extern "Rust" {
        type Proof;
        fn prove_swift(circuit_bytecode: String, initial_witness: Vec<i64>) -> Option<Proof>;
        fn verify_swift(circuit_bytecode: String, proof: Vec<u8>, vkey: Vec<u8>) -> Option<bool>;
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
///
/// # Returns
/// - `Option<Proof>`: The generated proof and its associated verification key wrapped in a `Proof` struct. Returns `None` if the proof generation fails.
pub fn prove_swift(circuit_bytecode: String, initial_witness: Vec<i64>) -> Option<Proof> {
    let initial_witness_vec: Vec<FieldElement> = initial_witness
        .into_iter()
        .map(|f| f as i128)
        .map(FieldElement::from)
        .collect();
    let mut initial_witness = WitnessMap::new();
    for (i, witness) in initial_witness_vec.into_iter().enumerate() {
        initial_witness.insert(Witness(i as u32 + 1), witness);
    }

    let (proof, vkey) = prove(circuit_bytecode, initial_witness).ok()?;
    Some(Proof {
        proof,
        vkey,
    })
}

/// Verifies a given zkSNARK proof using the associated circuit bytecode and verification key.
///
/// This function takes in the circuit bytecode, the generated proof, and the circuit verification key, then verifies
/// the correctness of the proof.
///
/// # Parameters
/// - `circuit_bytecode`: The base64 encoded bytecode of the ACIR circuit against which the proof needs to be verified.
/// - `proof`: The proof to be verified.
/// - `vkey`: The circuit verification key.
///
/// # Returns
/// - `Option<bool>`: Returns `true` if the proof is valid, `false` otherwise. Returns `None` if the verification process fails.
pub fn verify_swift(circuit_bytecode: String, proof: Vec<u8>, vkey: Vec<u8>) -> Option<bool> {
    verify(circuit_bytecode, proof, vkey).ok()
}
