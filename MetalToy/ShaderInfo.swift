//
//  ShaderInfo.swift
//  MetalToy
//
//  Created by minimoog on 8/23/18.
//  Copyright © 2018 Toni Jovanoski. All rights reserved.
//

import Foundation

public struct ShaderInfo: Codable {
    var fragment: String = DefaultComputeShader
    var textures: [String] = [String](repeating: "NULL", count: 4)
}

public func encodeToJsonString(shaderInfo: ShaderInfo) -> String? {
    guard let data = encodeToJsonData(shaderInfo: shaderInfo) else { return nil }
    
    return String(data: data, encoding: .utf8)
}

public func encodeToJsonData(shaderInfo: ShaderInfo) -> Data? {
    let encoder = JSONEncoder()
    encoder.outputFormatting = .prettyPrinted
    
    guard let data = try? encoder.encode(shaderInfo) else { return nil }
    
    return data
}

public func decodeFromJsonData(data: Data) -> ShaderInfo? {
    let decoder = JSONDecoder()
    
    guard let shaderInfo = try? decoder.decode(ShaderInfo.self, from: data) else { return nil }
    
    return shaderInfo
}

public func decodeFromJsonFile(json: String) -> ShaderInfo? {
    let decoder = JSONDecoder()
    
    guard let data = json.data(using: .utf8) else { return nil }
    guard let shaderInfo = try? decoder.decode(ShaderInfo.self, from: data) else { return nil }
    
    return shaderInfo
}
