//
//  DocumentManager.swift
//  MetalToy
//
//  Created by minimoog on 4/16/18.
//  Copyright © 2018 Toni Jovanoski. All rights reserved.
//

import Foundation

public func localDocumentDir() -> URL {
    let dirpaths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
    
    return dirpaths[0]
}

class DocumentManager {
    var documents: [URL] = [URL]()
    
    var count: Int {
        get {
            return documents.count
        }
    }
    
    subscript(index: Int) -> URL {
        return documents[index]
    }
    
    func refreshFiles() {
        documents = []
    
        let localDir = localDocumentDir()
    
        do {
            documents = try FileManager.default.contentsOfDirectory(at: localDir, includingPropertiesForKeys: nil, options: .skipsHiddenFiles)
        } catch {
            print(error)
        }
    }
    
    func wipeAllDocuments() {
        for document in documents {
            do {
                try FileManager.default.removeItem(at: document)
            } catch {
                print(error)
            }
        }
    }
    
    func removeDocuments(indices: [Int]) {
        for item in indices.sorted(by: >) {
            let docUrl = documents[item]
            
            DispatchQueue.global(qos: .default).async {
                let fileCoordinator = NSFileCoordinator()
                fileCoordinator.coordinate(writingItemAt: docUrl, options: .forDeleting, error: nil) {
                    url in
                    
                    do {
                        try FileManager.default.removeItem(at: url)
                    } catch {
                        print(error)
                    }
                }
            }
            
            documents.remove(at: item)
        }
    }
    
    func namePathComponent(index: Int) -> String {
        //if let namePath = try? String(contentsOf: documents[index].appendingPathComponent(ShaderDocument.SubDocumentType.name.rawValue), encoding: .utf8) {
        //    return namePath
        //}
        
        return String()
    }
    
    func imagePathComponent(index: Int) -> String {
        return documents[index].appendingPathComponent(ShaderDocument.SubDocumentType.thumbnail.rawValue).path
    }
}
