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
    
    enum SubDocumentType: String {
        case shader = "shader.txt"
        case name = "name.txt"
        case thumbnail = "thumbnail.png"
    }
    
    override func contents(forType typeName: String) throws -> Any {
        if let shaderText = shaderText, let thumbnail = thumbnail {
            let lenShaderText = shaderText.lengthOfBytes(using: .utf8)
            
            let shaderTextFileWrapper = FileWrapper(regularFileWithContents: Data(bytes: shaderText, count: lenShaderText))
            
            let lenNameText = name?.lengthOfBytes(using: .utf8)
            let nameFileWrapper = FileWrapper(regularFileWithContents: Data(bytes: name!, count: lenNameText!))
            
            let imageData = UIImagePNGRepresentation(thumbnail)
            let thumbnailFileWrapper = FileWrapper(regularFileWithContents: imageData!) // ### TODO: Fix '!'
            
            let dirWrapper = FileWrapper(directoryWithFileWrappers: [SubDocumentType.shader.rawValue:       shaderTextFileWrapper,
                                                                     SubDocumentType.name.rawValue:         nameFileWrapper,
                                                                     SubDocumentType.thumbnail.rawValue:    thumbnailFileWrapper])
            
            return dirWrapper
        } else {
            return Data()
        }
    }
    
    override func load(fromContents contents: Any, ofType typeName: String?) throws {
        if let userContents = contents as? FileWrapper {
            if userContents.isDirectory {
                if  let dirWrapper = userContents.fileWrappers,
                    let shaderTextFileWrapper = dirWrapper[SubDocumentType.shader.rawValue],
                    let thumbnailFileWrapper = dirWrapper[SubDocumentType.thumbnail.rawValue],
                    let nameFileWrapper = dirWrapper[SubDocumentType.name.rawValue],
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
