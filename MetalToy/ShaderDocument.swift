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
    var thumbnail: UIImage?
    var name: String?
    
    override func contents(forType typeName: String) throws -> Any {
        if let shaderText = shaderText, let thumbnail = thumbnail {
            let lenShaderText = shaderText.lengthOfBytes(using: .utf8)
            
            let shaderTextFileWrapper = FileWrapper(regularFileWithContents: Data(bytes: shaderText, count: lenShaderText))
            
            let lenNameText = name?.lengthOfBytes(using: .utf8)
            let nameFileWrapper = FileWrapper(regularFileWithContents: Data(bytes: name!, count: lenNameText!))
            
            let imageData = UIImagePNGRepresentation(thumbnail)
            let thumbnailFileWrapper = FileWrapper(regularFileWithContents: imageData!) // ### TODO: Fix '!'
            
            let dirWrapper = FileWrapper(directoryWithFileWrappers: ["shader.txt": shaderTextFileWrapper,
                                                                     "name.txt": nameFileWrapper,
                                                                     "thumbnail.png": thumbnailFileWrapper])
            
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
                    let nameFileWrapper = dirWrapper["name.txt"],
                    let shaderTextData = shaderTextFileWrapper.regularFileContents,
                    let imageData = thumbnailFileWrapper.regularFileContents,
                    let nameData = nameFileWrapper.regularFileContents {
                        shaderText = String(data: shaderTextData, encoding: .utf8)
                        thumbnail = UIImage(data: imageData)
                        name = String(data: nameData, encoding: .utf8)
                }
            }
        }
    }
}
