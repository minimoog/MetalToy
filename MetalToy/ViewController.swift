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
    
    public var savedDocumentAction: (() -> ())?
    
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
        
        if documentName == nil {    //new document
            let RFC3339DateFormatter = DateFormatter()
            RFC3339DateFormatter.locale = Locale(identifier: "en_US_POSIX")
            RFC3339DateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
            RFC3339DateFormatter.timeZone = TimeZone(secondsFromGMT: 0)
            
            documentName = RFC3339DateFormatter.string(from: Date())
            
            document = ShaderDocument(fileURL: localDocumentDir().appendingPathComponent(documentName!))
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
        super.viewWillDisappear(animated)
        
        let imageToSave = metalViewController?.snapshot(size: CGSize(width: 100, height: 100))
        document!.thumbnail = imageToSave
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        
        document!.shaderText = codeViewController?.codeView?.text!
        
        document!.save(to: document!.fileURL, for: .forOverwriting) { success in
            if success {
                print("Success")
                
                if let savedDocumentAction = self.savedDocumentAction {
                    savedDocumentAction()
                }
                
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

