//
//  ShaderDocument.swift
//  MetalToy
//
//  Created by minimoog on 1/22/18.
//  Copyright © 2018 Toni Jovanoski. All rights reserved.
//

import UIKit

class ShaderDocument: UIDocument {
    var shaderInfo: ShaderInfo?
    
    override init(fileURL url: URL) {
        super.init(fileURL: url)
    }
    
    init() {
        let tempDir = FileManager.default.temporaryDirectory
        let url = tempDir.appendingPathComponent("MyShader.shader")
        
        shaderInfo = ShaderInfo()
        
        super.init(fileURL: url)
    }
    
    func getTextures() -> [String] {
        
        if let shaderInfo = shaderInfo {
            let path = Bundle.main.resourcePath!
            
            let textures: [String] = shaderInfo.textures.map {
                if $0 == "NULL" {
                    return "NULL"
                } else {
                    return path + "/" + $0
                }
            }
            
            return textures
        }
        
        return [String](repeating: "NULL", count: 4)
    }
    
    override func contents(forType typeName: String) throws -> Any {
        if let shaderInfo = shaderInfo {
            guard let jsonData = encodeToJsonData(shaderInfo: shaderInfo) else { return Data() }
            
            return jsonData as Any
        }
        
        return Data()
    }
    
    override func load(fromContents contents: Any, ofType typeName: String?) throws {
        guard let data = contents as? Data else {
            fatalError("\(contents) is not an instance of Data")
        }
        
        shaderInfo = decodeFromJsonData(data: data)
    }
}
