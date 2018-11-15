//
//  EditorViewController.swift
//  MetalToy
//
//  Created by minimoog on 2/27/18.
//  Copyright © 2018 Toni Jovanoski. All rights reserved.
//

import UIKit

class EditorViewController: UIViewController, UITextFieldDelegate {
    var document: ShaderDocument?
    
    @IBOutlet weak var contentWrapperView: UIView!
    @IBOutlet weak var contentView: UIView!
    
    var codeViewController: CodeViewController?
    var metalViewController: MetalViewController?

    var metalViewPanelContentVC: MetalViewPanelContentController!
    var metalViewPanelVC: PanelViewController!
    
    var textureSelectorPanelContentVC: TextureSelectorViewController!
    var textureSelectorPanelVC: PanelViewController!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        metalViewPanelContentVC = (storyboard?.instantiateViewController(withIdentifier: "MetalViewPanelContentController") as! MetalViewPanelContentController)
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
        textureSelectorPanelContentVC = (storyboard?.instantiateViewController(withIdentifier: "TextureSelectorViewController") as! TextureSelectorViewController)
    
        textureSelectorPanelVC = PanelViewController(with: textureSelectorPanelContentVC, in: self)
        
        //connect texture selector with metal view
        textureSelectorPanelContentVC.selectedTextureOnTextureUnit = {
            filename, index in
            
            self.metalViewController?.loadTexture(filename: filename, index: index)
            self.codeViewController?.setTexture(filename: filename, index: index)
        }
        
        let playBarItem = UIBarButtonItem(title: "Play", style: .plain, target: self, action: #selector(self.onPlayButtonTapped))
        let viewBarItem = UIBarButtonItem(title: "View", style: .plain, target: self, action: #selector(self.onViewButtonTapped))
        let texturesBarItem = UIBarButtonItem(title: "Textures", style: .plain, target: self, action: #selector(self.onTexturesButtonTapped))
        navigationItem.rightBarButtonItems = [playBarItem, viewBarItem, texturesBarItem]
        
        let backButton = UIBarButtonItem(title: "Save", style: .done, target: self, action: #selector(self.onSaveButtonTapped)) // ### TODO: Implement action
        navigationItem.leftBarButtonItems = [backButton]
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        codeViewController?.document = document
        
        //needs rework
        if let textures = codeViewController?.getTextures() {
            for (i, texture) in textures.enumerated() {
                let textureUnit = TextureUnit(filename: texture)
                
                self.textureSelectorPanelContentVC.textureUnits[i] = textureUnit
                self.metalViewController?.loadTexture(filename: texture, index: i)
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
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
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
    
    @objc func onSaveButtonTapped(sender: UIBarButtonItem) {
            dismiss(animated: true, completion: nil)        // this is top view controller so no problem here
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
