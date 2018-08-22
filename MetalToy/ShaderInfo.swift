//
//  ShaderInfo.swift
//  MetalToy
//
//  Created by minimoog on 8/23/18.
//  Copyright © 2018 Toni Jovanoski. All rights reserved.
//

import Foundation

public struct ShaderInfo: Codable {
    let name: String
    let fragment: String
    let textures: [String]
}

public func encodeToJson(shaderInfo: ShaderInfo) -> String? {
    let encoder = JSONEncoder()
    encoder.outputFormatting = .prettyPrinted
    
    guard let data = try? encoder.encode(shaderInfo) else { return nil }
    
    return String(data: data, encoding: .utf8)
}

public func decodeFromJson(json: String) -> ShaderInfo? {
    let decoder = JSONDecoder()
    
    guard let data = json.data(using: .utf8) else { return nil }
    guard let shaderInfo = try? decoder.decode(ShaderInfo.self, from: data) else { return nil}
    
    return shaderInfo
}
