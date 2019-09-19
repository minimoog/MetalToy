//
//  CompilerOutputParser.swift
//  MetalToy
//
//  Created by minimoog on 12/19/17.
//  Copyright © 2017 Toni Jovanoski. All rights reserved.
//

import Foundation

struct CompilerErrorMessage {
    let lineNumber: Int
    let columnNumber: Int
    let error: String
    let message: String
}

func parseCompilerOutput(_ compilerOutput: String) -> [CompilerErrorMessage] {
    let components = compilerOutput.components(separatedBy: "program_source")
    var outMessages = [CompilerErrorMessage]()
    
    for index in components.indices.dropFirst() {
        let splitted = components[index].split(separator: ":")
        
        if splitted.count < 4 {
            return outMessages
        }
        
        if let line: Int = Int(splitted[0]),
           let column: Int = Int(splitted[1]) {
            let compilerMessage = CompilerErrorMessage(lineNumber: line, columnNumber: column, error: String(splitted[2]), message: String(splitted[3]))
            
            outMessages.append(compilerMessage)
        }
    }
    
    return outMessages
}
