//
//  ArisenAbirixSerializationProvider.swift
//  ArisenAbirixSerializationProvider
//
//  Created by Todd Bowden on 6/16/18.
// Copyright (c) 2017-2019 block.one and its contributors. All rights reserved.
//

import Foundation
import ArisenSwift

/// Serialization provider implementation for ARISEN SDK for Swift using ABIRIX.
/// Responsible for ABI-driven transaction and action serialization and deserialization
/// between JSON and binary data representations.
 public class ArisenAbirixSerializationProvider: ArisenSerializationProviderProtocol {

    /// Used to hold errors.
    public class Error: ArisenError { }

    private var context = abirix_create()
    private var abiJsonString = ""

    /// Getter to return error as a String.
    public var error: String? {
        return String(validatingUTF8: abirix_get_error(context))
    }

    /// Default init.
    required public init() {

    }

    deinit {
        abirix_destroy(context)
    }

    /// Convert ABIrix String data to UInt64 value.
    ///
    /// - Parameter string: String data to convert.
    /// - Returns: A UInt64 value.
    public func name64(string: String?) -> UInt64 {
        guard let string = string else { return 0 }
        return abirix_string_to_name(context, string)
    }

    /// Convert ABIrix UInt64 data to String value.
    ///
    /// - Parameter name64: A UInt64 value to convert.
    /// - Returns: A string value.
    public func string(name64: UInt64) -> String? {
        return String(validatingUTF8: abirix_name_to_string(context, name64))
    }

    private func refreshContext() {
        if context != nil {
            abirix_destroy(context)
        }
        context = abirix_create()
    }

    private func getAbiJsonFile(fileName: String) throws -> String {
        var abiString = ""
        let path = Bundle(for: ArisenAbirixSerializationProvider.self).url(forResource: fileName, withExtension: nil)?.path ?? ""
        abiString = try NSString(contentsOfFile: path, encoding: String.Encoding.utf8.rawValue) as String
        guard abiString != "" else {
            throw Error(.serializationProviderError, reason: "Json to hex -- No ABI file found for \(fileName)")
        }
        return abiString
    }

    /// Convert JSON Transaction data representation to ABIRIX binary representation of Transaction data.
    ///
    /// - Parameter json: The JSON representation of Transaction data to serialize.
    /// - Returns: A binary String of Transaction data.
    /// - Throws: If the data cannot be serialized for any reason.
    public func serializeTransaction(json: String) throws -> String {
        let transactionJson = try getAbiJsonFile(fileName: "transaction.abi.json")
        return try serialize(contract: nil, name: "", type: "transaction", json: json, abi: transactionJson)
    }

    /// Convert JSON ABI data representation to ABIRIX binary of data.
    ///
    /// - Parameter json: The JSON data String to serialize.
    /// - Returns: A String of binary data.
    /// - Throws: If the data cannot be serialized for any reason.
    public func serializeAbi(json: String) throws -> String {
        let abiJson = try getAbiJsonFile(fileName: "abi.abi.json")
        return try serialize(contract: nil, name: "", type: "abi_def", json: json, abi: abiJson)
    }

    /// Calls ABIRIX to carry out JSON to binary conversion using ABIs.
    ///
    /// - Parameters:
    ///   - contract: An optional String representing contract name for the serialize action lookup for this ABIRIX conversion.
    ///   - name: An optional String representing an action name that is used in conjunction with contract (above) to derive the serialize type name.
    ///   - type: An optional string representing the type name for the serialize action lookup for this serialize conversion.
    ///   - json: The JSON data String to serialize to binary.
    ///   - abi: A String representation of the ABI to use for conversion.
    /// - Returns: A String of binary serialized data.
    /// - Throws: If the data cannot be serialized for any reason.
    public func serialize(contract: String?, name: String = "", type: String? = nil, json: String, abi: String) throws -> String {

        refreshContext()

        let contract64 = name64(string: contract)
        abiJsonString = abi

        // set the abi
        let setAbiResult = abirix_set_abi(context, contract64, abiJsonString)
        guard setAbiResult == 1 else {
            throw Error(.serializationProviderError, reason: "Json to hex -- Unable to set ABI. \(self.error ?? "")")
        }

        // get the type name for the action
        guard let type = type ?? getType(action: name, contract: contract64) else {
            throw Error(.serializationProviderError, reason: "Unable find type for action \(name). \(self.error ?? "")")
        }

        var jsonToBinResult: Int32 = 0
        jsonToBinResult = abirix_json_to_bin_reorderable(context, contract64, type, json)

        guard jsonToBinResult == 1 else {
            throw Error(.serializationProviderError, reason: "Unable to pack json to bin. \(self.error ?? "")")
        }

        guard let hex = String(validatingUTF8: abirix_get_bin_hex(context)) else {
            throw Error(.serializationProviderError, reason: "Unable to convert binary to hex")
        }
        return hex
    }

    /// Converts a binary string of ABIRIX Transaction data to JSON string representation of Transaction data.
    ///
    /// - Parameter hex: The binary Transaction data String to deserialize.
    /// - Returns: A String of JSON Transaction data.
    /// - Throws: If the data cannot be deserialized for any reason.
    public func deserializeTransaction(hex: String) throws -> String {
        let transactionJson = try getAbiJsonFile(fileName: "transaction.abi.json")
        return try deserialize(contract: nil, name: "", type: "transaction", hex: hex, abi: transactionJson)
    }

    /// Converts a binary string of ABIRIX data to JSON string data.
    ///
    /// - Parameter hex: The binary data String to deserialize.
    /// - Returns: A String of JSON data.
    /// - Throws: If the data cannot be deserialized for any reason.
    public func deserializeAbi(hex: String) throws -> String {
        let abiJson = try getAbiJsonFile(fileName: "abi.abi.json")
        return try deserialize(contract: nil, name: "", type: "abi_def", hex: hex, abi: abiJson)
    }

    /// Calls ABIRIX to carry out binary to JSON conversion using ABIs.
    ///
    /// - Parameters:
    ///   - contract: An optional String representing contract name for the ABIRIX action lookup for this ABIRIX conversion.
    ///   - name: An optional String representing an action name that is used in conjunction with contract (above) to derive the ABIrix type name.
    ///   - type: An optional string representing the type name for the ABIRIX action lookup for this ABIRIX conversion.
    ///   - hex: The binary data String to deserialize to a JSON String.
    ///   - abi: A String representation of the ABI to use for conversion.
    /// - Returns: A String of JSON data.
    /// - Throws: If the data cannot be deserialized for any reason.
    public func deserialize(contract: String?, name: String = "", type: String? = nil, hex: String, abi: String) throws -> String {

        refreshContext()

        let contract64 = name64(string: contract)
        abiJsonString = abi

        // set the abi
        let setAbiResult = abirix_set_abi(context, contract64, abiJsonString)
        guard setAbiResult == 1 else {
            throw Error(.serializationProviderError, reason: "Hex to json -- Unable to set ABI. \(self.error ?? "")")
        }

        // get the type name for the action
        guard let type = type ?? getType(action: name, contract: contract64) else {
            throw Error(.serializationProviderError, reason: "Unable find type for action \(name). \(self.error ?? "")")
        }

        if let json = abirix_hex_to_json(context, contract64, type, hex) {
            if let string = String(validatingUTF8: json) {
                return string
            } else {
                throw Error(.serializationProviderError, reason: "Unable to convert c string json to String.)")
            }
        } else {
            throw Error(.serializationProviderError, reason: "Unable to unpack hex to json. \(self.error ?? "")")
        }

    }

    // Get the type name for the action and contract.
    private func getType(action: String, contract: UInt64) -> String? {
        let action64 = name64(string: action)
        if let type = abirix_get_type_for_action(context, contract, action64) {
            return String(validatingUTF8: type)
        } else {
            return nil
        }
    }

    private func jsonString(dictionary: [String: Any]) -> String? {
        if let data = try? JSONSerialization.data(withJSONObject: dictionary, options: []) {
            return String(data: data, encoding: .utf8)
        } else {
            return nil
        }
    }

}
