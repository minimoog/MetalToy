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
        case shader = "shader.txt"  //old format
        case name = "name.txt"      //old format
    }
    
    override init(fileURL url: URL) {
        super.init(fileURL: url)
    }
    
    init() {
        let tempDir = FileManager.default.temporaryDirectory
        let url = tempDir.appendingPathComponent("MyShader.shader")
        
        super.init(fileURL: url)
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
                } else {
                    // read from old format
                    if let dirWrapper = userContents.fileWrappers,
                        let shaderTextFileWrapper = dirWrapper[SubDocumentType.shader.rawValue],
                        let nameFileWrapper = dirWrapper[SubDocumentType.name.rawValue],
                        let shaderTextData = shaderTextFileWrapper.regularFileContents,
                        let thumbnailFileWrapper = dirWrapper[SubDocumentType.thumbnail.rawValue],
                        let imageData = thumbnailFileWrapper.regularFileContents,
                        let nameData = nameFileWrapper.regularFileContents {
                        
                        shaderInfo = ShaderInfo(name: String(data: nameData, encoding: .utf8)!,
                                                             fragment: String(data: shaderTextData, encoding: .utf8)!,
                                                             textures: [String]())
                        
                        //remove old data
                        userContents.removeFileWrapper(nameFileWrapper)
                        userContents.removeFileWrapper(shaderTextFileWrapper)
                        
                        thumbnail = UIImage(data: imageData)
                    }
                }
            }
        }
    }
}
