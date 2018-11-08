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

        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if let editorViewController = topViewController as? EditorViewController {
            
            //pass document to editor view controller
            
            editorViewController.document = document
        }
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
