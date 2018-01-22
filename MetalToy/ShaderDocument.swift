//
//  ShaderDocument.swift
//  MetalToy
//
//  Created by minimoog on 1/22/18.
//  Copyright © 2018 Toni Jovanoski. All rights reserved.
//

import UIKit

class ShaderDocument: UIDocument {
    var shaderText: String? = ""
    var thumbnail: UIImage? = UIImage()
    
    override func contents(forType typeName: String) throws -> Any {
        if let shaderText = shaderText, let thumbnail = thumbnail {
            let length = shaderText.lengthOfBytes(using: .utf8)
            
            let shaderTextFileWrapper = FileWrapper(regularFileWithContents: Data(bytes: shaderText, count: length))
            
            let imageData = UIImagePNGRepresentation(thumbnail)
            let thumbnailFileWrapper = FileWrapper(regularFileWithContents: imageData!) // ### TODO: Fix '!'
            
            let dirWrapper = FileWrapper(directoryWithFileWrappers: ["shader.txt": shaderTextFileWrapper, "thumbnail.png": thumbnailFileWrapper])
            
            return dirWrapper
        } else {
            return Data()
        }
    }
    
    override func load(fromContents contents: Any, ofType typeName: String?) throws {
        if let userContents = contents as? FileWrapper {
            if userContents.isDirectory {
                if  let dirWrapper = userContents.fileWrappers,
                    let shaderTextFileWrapper = dirWrapper["shader.txt"],
                    let thumbnailFileWrapper = dirWrapper["thumbnail.png"],
                    let shaderTextData = shaderTextFileWrapper.regularFileContents,
                    let imageData = thumbnailFileWrapper.regularFileContents {
                        shaderText = String(data: shaderTextData, encoding: .utf8)
                        thumbnail = UIImage(data: imageData)
                }
            }
        }
    }
}
