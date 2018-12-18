//
//  EditorNavigationController.swift
//  MetalToy
//
//  Created by minimoog on 11/6/18.
//  Copyright © 2018 Toni Jovanoski. All rights reserved.
//

import UIKit

class EditorNavigationController: UINavigationController {
    var document: ShaderDocument?

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if let editorViewController = topViewController as? EditorViewController {
            
            //pass document to editor view controller
            
            editorViewController.document = document
        }
    }
}
