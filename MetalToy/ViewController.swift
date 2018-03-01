//
//  ViewController.swift
//  MetalToy
//
//  Created by Toni Jovanoski on 9/26/17.
//  Copyright © 2017 Toni Jovanoski. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UITextFieldDelegate {
    var metalViewController: MetalViewController?
    var codeViewController: CodeViewController?
    var docNameTextField: UITextField?
    var documentURL: URL?
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
        
//        codeViewController?.playAction = { text in
//            if let metalViewController = self.metalViewController, let text = text {
//                metalViewController.mtkView.isPaused = false
//                metalViewController.setRenderPipeline(fragmentShader: text)
//            }
//        }
//
//        codeViewController?.pauseAction = {
//            if let metalViewController = self.metalViewController {
//                metalViewController.mtkView.isPaused = true
//            }
//        }
        
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
        
        //let playBarItem = UIBarButtonItem(title: "Play", style: .plain, target: codeViewController, action: #selector(codeViewController?.onPlayButtonTapped))
        
        //navigationItem.rightBarButtonItems = [playBarItem]
        
        docNameTextField = UITextField()
        docNameTextField?.textAlignment = .center
        docNameTextField?.autoresizingMask = .flexibleWidth
        docNameTextField?.frame = CGRect(x: 0, y: 0, width: 400, height: 30)
        docNameTextField?.delegate = self
        
        navigationItem.titleView = docNameTextField
        
        if documentURL == nil {    //new document
            //Shader documents has uuid filename
            //the name of the document is stored inside the document
            
            document = ShaderDocument(fileURL: localDocumentDir().appendingPathComponent(UUID().uuidString))
            
            let RFC3339DateFormatter = DateFormatter()
            RFC3339DateFormatter.locale = Locale(identifier: "en_US_POSIX")
            RFC3339DateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
            RFC3339DateFormatter.timeZone = TimeZone(secondsFromGMT: 0)
            
            let documentName = RFC3339DateFormatter.string(from: Date())
            
            docNameTextField?.text = documentName
            document?.name = documentName
        } else {
            document = ShaderDocument(fileURL: documentURL!)
            
            document!.open { valid in
                if valid {
                    self.codeViewController?.codeView?.text = self.document!.shaderText!
                    self.docNameTextField?.text = self.document?.name
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
    
    override func viewWillAppear(_ animated: Bool) {

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
    
    // MARK: UITextDelegate
    func textFieldDidEndEditing(_ textField: UITextField) {
        guard document != nil else {
            return
        }
        
        document?.name = textField.text
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}

