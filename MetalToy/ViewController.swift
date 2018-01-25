//
//  ViewController.swift
//  MetalToy
//
//  Created by Toni Jovanoski on 9/26/17.
//  Copyright © 2017 Toni Jovanoski. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    var metalViewController: MetalViewController?
    var codeViewController: CodeViewController?
    var documentName: String?
    var document: ShaderDocument?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let splitController = SplitViewController()
        addChildViewController(splitController)
        
        splitController.view.frame = self.view.bounds
        splitController.view.autoresizingMask = UIViewAutoresizing(rawValue: UIViewAutoresizing.flexibleWidth.rawValue | UIViewAutoresizing.flexibleHeight.rawValue)
        
        view.addSubview(splitController.view)
        splitController.didMove(toParentViewController: self)
        splitController.arrangement = .horizontal
        
        metalViewController = storyboard?.instantiateViewController(withIdentifier: "MetalViewController") as? MetalViewController
        codeViewController = storyboard?.instantiateViewController(withIdentifier: "CodeViewController") as? CodeViewController
        
        codeViewController?.playAction = { text in
            if let metalViewController = self.metalViewController, let text = text {
                metalViewController.mtkView.isPaused = false
                metalViewController.setRenderPipeline(fragmentShader: text)
            }
        }
        
        codeViewController?.pauseAction = {
            if let metalViewController = self.metalViewController {
                metalViewController.mtkView.isPaused = true
            }
        }
        
        metalViewController?.finishedCompiling = { result, compilerMessages in
            if result {
                if let codeViewController = self.codeViewController {
                    codeViewController.removePoints()
                }
            } else {
                if let codeViewController = self.codeViewController, let compilerMessages = compilerMessages {
                    codeViewController.updateViewWithPoints(messages: compilerMessages)
                }
            }
        }
        
        splitController.firstChild = codeViewController
        splitController.secondChild = metalViewController
        
        let playBarItem = UIBarButtonItem(title: "Play", style: .plain, target: codeViewController, action: #selector(codeViewController?.onPlayButtonTapped))
        
        navigationItem.rightBarButtonItems = [playBarItem]
        
        if documentName == nil {
            document = ShaderDocument(fileURL: localDocumentDir().appendingPathComponent("test123"))
            documentName = "test123"
        } else {
            document = ShaderDocument(fileURL: localDocumentDir().appendingPathComponent(documentName!))
            
            document!.open { valid in
                if valid {
                    self.codeViewController?.codeView?.text = self.document!.shaderText!
                } else {
                    print("Erorr loading document")
                }
            }
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        // ### Here get snapshot
        
        super.viewWillDisappear(animated)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        // ### Here save the document
        document!.shaderText = codeViewController?.codeView?.text!
        
        document!.save(to: document!.fileURL, for: .forOverwriting) { success in
            if success {
                print("Success")
            } else {
                print("Failed storing")
            }
        }
        
        super.viewDidDisappear(animated)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}

