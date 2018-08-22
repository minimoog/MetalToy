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
    var thumbnail: UIImage?
    
    enum SubDocumentType: String {
        case shaderinfo = "shaderinfo.json"
        case thumbnail = "thumbnail.png"
    }
    
    override func contents(forType typeName: String) throws -> Any {
        if let shaderInfo = shaderInfo, let thumbnail = thumbnail {
            guard let jsonData = encodeToJsonData(shaderInfo: shaderInfo) else { return Data() }
            
            let shaderInfoFileWrapper = FileWrapper(regularFileWithContents: jsonData)
            
            guard let imageData = UIImagePNGRepresentation(thumbnail) else { return Data() }
            let thumbnailFileWrapper = FileWrapper(regularFileWithContents: imageData)
            
            let dirWrapper = FileWrapper(directoryWithFileWrappers: [SubDocumentType.shaderinfo.rawValue: shaderInfoFileWrapper,
                                                                     SubDocumentType.thumbnail.rawValue: thumbnailFileWrapper])
            return dirWrapper
        } else {
            return Data()
        }
    }
    
    override func load(fromContents contents: Any, ofType typeName: String?) throws {
        if let userContents = contents as? FileWrapper {
            if userContents.isDirectory {
                if  let dirWrapper = userContents.fileWrappers,
                    let shaderInfoFileWrapper = dirWrapper[SubDocumentType.shaderinfo.rawValue],
                    let thumbnailFileWrapper = dirWrapper[SubDocumentType.thumbnail.rawValue],
                    let shaderInfoData = shaderInfoFileWrapper.regularFileContents,
                    let imageData = thumbnailFileWrapper.regularFileContents {
                        shaderInfo = decodeFromJsonData(data: shaderInfoData)
                        thumbnail = UIImage(data: imageData)
                }
            }
        }
    }
}
