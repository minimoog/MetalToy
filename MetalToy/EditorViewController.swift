//
//  EditorViewController.swift
//  MetalToy
//
//  Created by minimoog on 2/27/18.
//  Copyright © 2018 Toni Jovanoski. All rights reserved.
//

import UIKit

class EditorViewController: UIViewController {
    var document: ShaderDocument?
    
    @IBOutlet weak var contentWrapperView: UIView!
    @IBOutlet weak var contentView: UIView!
    
    var codeViewController: CodeViewController?
    var metalViewController: MetalViewController?

    var textureSelectorPanelContentVC: TextureSelectorViewController!
    
    var playBarItem: UIBarButtonItem?
    var viewBarItem: UIBarButtonItem?
    var texturesBarItem: UIBarButtonItem?
    
    var isPlaying: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        //metalViewController = metalViewPanelContentVC.metalViewController
        
        //on shader successfull compiling invoke codeviewcontroller
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
        
        //connect texture selector with metal view
        textureSelectorPanelContentVC.selectedTextureOnTextureUnit = {
            filename, index in
            
            self.metalViewController?.loadTexture(filename: filename, index: index)
            self.codeViewController?.setTexture(filename: filename, index: index)
        }
        
        //setup buttons
        if #available(iOS 13.0, *) {
            playBarItem = UIBarButtonItem(image: UIImage(systemName: "play.fill"), style: .plain, target: self, action: #selector(self.onPlayButtonTapped))
        } else {
            playBarItem = UIBarButtonItem(title: "Play", style: .plain, target: self, action: #selector(self.onPlayButtonTapped))
        }
        
        if #available(iOS 13.0, *) {
            viewBarItem = UIBarButtonItem(image: UIImage(systemName: "eye"), style: .plain, target: self, action: #selector(self.onViewButtonTapped))
        } else {
            viewBarItem = UIBarButtonItem(title: "View", style: .plain, target: self, action: #selector(self.onViewButtonTapped))
        }
        
        texturesBarItem = UIBarButtonItem(title: "Textures", style: .plain, target: self, action: #selector(self.onTexturesButtonTapped))
        navigationItem.rightBarButtonItems = [playBarItem!, viewBarItem!, texturesBarItem!]
        
        let backButton = UIBarButtonItem(title: "Shaders", style: .done, target: self, action: #selector(self.onSaveButtonTapped))
        navigationItem.leftBarButtonItems = [backButton]
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        codeViewController?.document = document
        
        // ### needs rework ###
        if let textures = document?.getTextures() {
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
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    @objc func onViewButtonTapped(sender: UIBarButtonItem) {
        //show metal VC
        
//        metalViewPanelVC.modalPresentationStyle = .popover
//        metalViewPanelVC.popoverPresentationController?.barButtonItem = sender
//        metalViewPanelVC.manager?.close(metalViewPanelVC)
//        
//        metalViewPanelContentVC.closing = {
//            sender.isEnabled = !sender.isEnabled
//            
//            //pause mtk view when closing the panel
//            self.metalViewController?.mtkView.isPaused = true
//            self.playBarItem?.title = "Play"
//        }
//        
//        present(metalViewPanelVC, animated: true, completion: nil)
    }
    
    @objc func onPlayButtonTapped(sender: UIBarButtonItem) {
        if !isPlaying {
            
            if let text = codeViewController?.codeView?.text {
                if  metalViewController?.setRenderPipeline(fragmentShader: text) != nil {
                    
                    if #available(iOS 13.0, *) {
                        sender.image = UIImage(systemName: "pause.fill")
                    } else {
                        sender.title = "Pause"
                    }
                    
                    metalViewController?.mtkView.isPaused = false // ### TODO: Merge maybe binding with isPlaying state
                } else {
                    metalViewController?.mtkView.isPaused = true
                }
            }
            
            isPlaying = true
            
        } else {
            if #available(iOS 13.0, *) {
                sender.image = UIImage(systemName: "play.fill")
            } else {
                sender.title = "Play"
            }
            
            metalViewController?.mtkView.isPaused = true
            
            isPlaying = false
        }
    }
    
    @objc func onTexturesButtonTapped(sender: UIBarButtonItem) {
        
        //show texture selector
        textureSelectorPanelContentVC.showPopover(withNavigationController: sender)
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

