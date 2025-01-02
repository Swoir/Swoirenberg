// File automatically generated by swift-bridge.
import SwoirenbergLib
public func setup_srs_swift<GenericIntoRustString: IntoRustString, GenericToRustStr: ToRustStr>(_ circuit_bytecode: GenericIntoRustString, _ srs_path: Optional<GenericToRustStr>, _ recursive: Bool) -> Optional<UInt32> {
    return optionalRustStrToRustStr(srs_path, { srs_pathAsRustStr in
        __swift_bridge__$setup_srs_swift({ let rustString = circuit_bytecode.intoRustString(); rustString.isOwned = false; return rustString.ptr }(), srs_pathAsRustStr, recursive).intoSwiftRepr()
    })
}
public func prove_swift<GenericIntoRustString: IntoRustString>(_ circuit_bytecode: GenericIntoRustString, _ initial_witness: RustVec<GenericIntoRustString>, _ proof_type: GenericIntoRustString, _ recursive: Bool) -> Optional<Proof> {
    { let val = __swift_bridge__$prove_swift({ let rustString = circuit_bytecode.intoRustString(); rustString.isOwned = false; return rustString.ptr }(), { let val = initial_witness; val.isOwned = false; return val.ptr }(), { let rustString = proof_type.intoRustString(); rustString.isOwned = false; return rustString.ptr }(), recursive); if val != nil { return Proof(ptr: val!) } else { return nil } }()
}
public func verify_swift<GenericIntoRustString: IntoRustString>(_ proof: RustVec<UInt8>, _ vkey: RustVec<UInt8>, _ proof_type: GenericIntoRustString) -> Optional<Bool> {
    __swift_bridge__$verify_swift({ let val = proof; val.isOwned = false; return val.ptr }(), { let val = vkey; val.isOwned = false; return val.ptr }(), { let rustString = proof_type.intoRustString(); rustString.isOwned = false; return rustString.ptr }()).intoSwiftRepr()
}

public class Proof: ProofRefMut {
    var isOwned: Bool = true

    public override init(ptr: UnsafeMutableRawPointer) {
        super.init(ptr: ptr)
    }

    deinit {
        if isOwned {
            __swift_bridge__$Proof$_free(ptr)
        }
    }
}
public class ProofRefMut: ProofRef {
    public override init(ptr: UnsafeMutableRawPointer) {
        super.init(ptr: ptr)
    }
}
public class ProofRef {
    var ptr: UnsafeMutableRawPointer

    public init(ptr: UnsafeMutableRawPointer) {
        self.ptr = ptr
    }
}
extension ProofRef {
    public func proof_data_ptr() -> UnsafePointer<UInt8> {
        __swift_bridge__$Proof$proof_data_ptr(ptr)
    }

    public func proof_data_len() -> UInt {
        __swift_bridge__$Proof$proof_data_len(ptr)
    }

    public func vkey_data_ptr() -> UnsafePointer<UInt8> {
        __swift_bridge__$Proof$vkey_data_ptr(ptr)
    }

    public func vkey_data_len() -> UInt {
        __swift_bridge__$Proof$vkey_data_len(ptr)
    }
}
extension Proof: Vectorizable {
    public static func vecOfSelfNew() -> UnsafeMutableRawPointer {
        __swift_bridge__$Vec_Proof$new()
    }

    public static func vecOfSelfFree(vecPtr: UnsafeMutableRawPointer) {
        __swift_bridge__$Vec_Proof$drop(vecPtr)
    }

    public static func vecOfSelfPush(vecPtr: UnsafeMutableRawPointer, value: Proof) {
        __swift_bridge__$Vec_Proof$push(vecPtr, {value.isOwned = false; return value.ptr;}())
    }

    public static func vecOfSelfPop(vecPtr: UnsafeMutableRawPointer) -> Optional<Self> {
        let pointer = __swift_bridge__$Vec_Proof$pop(vecPtr)
        if pointer == nil {
            return nil
        } else {
            return (Proof(ptr: pointer!) as! Self)
        }
    }

    public static func vecOfSelfGet(vecPtr: UnsafeMutableRawPointer, index: UInt) -> Optional<ProofRef> {
        let pointer = __swift_bridge__$Vec_Proof$get(vecPtr, index)
        if pointer == nil {
            return nil
        } else {
            return ProofRef(ptr: pointer!)
        }
    }

    public static func vecOfSelfGetMut(vecPtr: UnsafeMutableRawPointer, index: UInt) -> Optional<ProofRefMut> {
        let pointer = __swift_bridge__$Vec_Proof$get_mut(vecPtr, index)
        if pointer == nil {
            return nil
        } else {
            return ProofRefMut(ptr: pointer!)
        }
    }

    public static func vecOfSelfAsPtr(vecPtr: UnsafeMutableRawPointer) -> UnsafePointer<ProofRef> {
        UnsafePointer<ProofRef>(OpaquePointer(__swift_bridge__$Vec_Proof$as_ptr(vecPtr)))
    }

    public static func vecOfSelfLen(vecPtr: UnsafeMutableRawPointer) -> UInt {
        __swift_bridge__$Vec_Proof$len(vecPtr)
    }
}



