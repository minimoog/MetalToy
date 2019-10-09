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
    
    var codeViewController: CodeViewController?
    var metalViewController: MetalViewController?

    var textureSelectorPanelContentVC: TextureSelectorViewController!
    
    var playBarItem: UIBarButtonItem?
    var viewBarItem: UIBarButtonItem?
    var texturesBarItem: UIBarButtonItem?
    
    @IBOutlet weak var trailingMVCconstraint: NSLayoutConstraint!
    @IBOutlet weak var topMVCconstraint: NSLayoutConstraint!
    @IBOutlet weak var widthConstraint: NSLayoutConstraint!
    @IBOutlet weak var heightConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var metalContainerView: UIView!
    
    var isPlaying: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        guard let codeController = children.first as? CodeViewController else {
            fatalError("Check storyboard for CodeViewController")
        }
        
        guard let metalController = children.last as? MetalViewController else {
            fatalError("Check storyboard for MetalViewController")
        }
        
        codeViewController = codeController
        metalViewController = metalController
        
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
        
        if metalContainerView.isHidden {
            metalContainerView.isHidden = false
            
            if #available(iOS 13.0, *) {
                sender.image = UIImage(systemName: "eye.slash")
            } else {
                // Fallback on earlier versions
            }
            
        } else {
            metalContainerView.isHidden = true
            
            if #available(iOS 13.0, *) {
                sender.image = UIImage(systemName: "eye")
            } else {
                // Fallback on earlier versions
            }
        }
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
    
    @IBAction func metalVCPanning(_ panGestureRecognizer: UIPanGestureRecognizer) {
        guard let view = panGestureRecognizer.view else { return }
        
        let translation = panGestureRecognizer.translation(in: view)
        
        trailingMVCconstraint.constant -= translation.x
        if trailingMVCconstraint.constant < 20 {
            trailingMVCconstraint.constant = 20
        }
        
        topMVCconstraint.constant += translation.y
        if topMVCconstraint.constant < 20 {
            topMVCconstraint.constant = 20
        }
        
        panGestureRecognizer.setTranslation(.zero, in: view)
    }
    
    @IBAction func metalVCPinching(_ pinchGestureRecognizer: UIPinchGestureRecognizer) {
        let scale = pinchGestureRecognizer.scale
        
        heightConstraint.constant *= scale
        
        if heightConstraint.constant < 200 { heightConstraint.constant = 200 }
        if heightConstraint.constant > 600 { heightConstraint.constant = 600 }
        
        widthConstraint.constant *= scale
        
        if widthConstraint.constant < 200 { widthConstraint.constant = 200 }
        if widthConstraint.constant > 600 { widthConstraint.constant = 600 }
        
        pinchGestureRecognizer.scale = 1.0
    }
    
    // MARK: - Navigation
}

