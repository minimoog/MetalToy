//
//  EditorViewController.swift
//  MetalToy
//
//  Created by minimoog on 2/27/18.
//  Copyright © 2018 Toni Jovanoski. All rights reserved.
//

import UIKit

class EditorViewController: UIViewController, UITextFieldDelegate {
    var docNameTextField: UITextField?
    var documentURL: URL?
    var document: ShaderDocument?
    
    @IBOutlet weak var contentWrapperView: UIView!
    @IBOutlet weak var contentView: UIView!
    
    var codeViewController: CodeViewController?
    var metalViewController: MetalViewController?

    var metalViewPanelContentVC: MetalViewPanelContentController!
    var metalViewPanelVC: PanelViewController!
    
    var textureSelectorPanelContentVC: TextureSelectorViewController!
    var textureSelectorPanelVC: PanelViewController!
    
    public var savedDocumentAction: (() -> ())?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        metalViewPanelContentVC = storyboard?.instantiateViewController(withIdentifier: "MetalViewPanelContentController") as! MetalViewPanelContentController
        metalViewPanelVC = PanelViewController(with: metalViewPanelContentVC, in: self)
        
        metalViewController = metalViewPanelContentVC.metalViewController
        
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
        
        //texture selector panel
        textureSelectorPanelContentVC = storyboard?.instantiateViewController(withIdentifier: "TextureSelectorViewController") as! TextureSelectorViewController
        textureSelectorPanelVC = PanelViewController(with: textureSelectorPanelContentVC, in: self)
        
        let playBarItem = UIBarButtonItem(title: "Play", style: .plain, target: self, action: #selector(self.onPlayButtonTapped))
        let viewBarItem = UIBarButtonItem(title: "View", style: .plain, target: self, action: #selector(self.onViewButtonTapped))
        let texturesBarItem = UIBarButtonItem(title: "Textures", style: .plain, target: self, action: #selector(self.onTexturesButtonTapped))
        navigationItem.rightBarButtonItems = [playBarItem, viewBarItem, texturesBarItem]
        
        docNameTextField = UITextField()
        docNameTextField?.textAlignment = .center
        docNameTextField?.autoresizingMask = .flexibleWidth
        docNameTextField?.frame = CGRect(x: 0, y: 0, width: 400, height: 30)
        docNameTextField?.delegate = self
        docNameTextField?.textColor = navigationController?.navigationBar.titleTextAttributes![NSAttributedStringKey.foregroundColor] as? UIColor
        
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

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        
        coordinator.animate(alongsideTransition: { (context) in
            
        }) { (context) in
            
            if !self.allowFloatingPanels {
                self.closeAllFloatingPanels()
            }
            
            if !self.allowPanelPinning {
                self.closeAllPinnedPanels()
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
                    
                    self.document?.close { success in
                        if success {
                            savedDocumentAction()
                        } else {
                            print("Failed closing document")
                        }
                    }
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
    
    @objc func onViewButtonTapped(sender: UIBarButtonItem) {
        metalViewPanelVC.modalPresentationStyle = .popover
        metalViewPanelVC.popoverPresentationController?.barButtonItem = sender
        
        present(metalViewPanelVC, animated: true, completion: nil)
    }
    
    @objc func onPlayButtonTapped(sender: UIBarButtonItem) {
        if sender.title == "Play" {
            sender.title = "Pause"
            
            metalViewController?.mtkView.isPaused = false
            
            if let text = codeViewController?.codeView?.text {
                metalViewController?.setRenderPipeline(fragmentShader: text)
            }
            
        } else {
            sender.title = "Play"
            
            metalViewController?.mtkView.isPaused = true
        }
    }
    
    @objc func onTexturesButtonTapped(sender: UIBarButtonItem) {
        textureSelectorPanelVC.modalPresentationStyle = .popover
        textureSelectorPanelVC.popoverPresentationController?.barButtonItem = sender
        
        present(textureSelectorPanelVC, animated: true, completion: nil)
    }
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let destination = segue.destination
        
        if let codeViewController = destination as? CodeViewController {
            self.codeViewController = codeViewController
        }
    }
}

/*
 * PanelKit
 */
extension EditorViewController: PanelManager {
    
    var panelContentWrapperView: UIView {
        return contentWrapperView
    }
    
    var panelContentView: UIView {
        return contentView
    }
    
    var panels: [PanelViewController] {
        return [metalViewPanelVC, textureSelectorPanelVC]
    }
    
}
