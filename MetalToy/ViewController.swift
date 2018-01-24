//
//  ViewController.swift
//  MetalToy
//
//  Created by Toni Jovanoski on 9/26/17.
//  Copyright © 2017 Toni Jovanoski. All rights reserved.
//

import UIKit
//import SplitKit

class ViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let splitController = SplitViewController()
        addChildViewController(splitController)
        
        splitController.view.frame = self.view.bounds
        splitController.view.autoresizingMask = UIViewAutoresizing(rawValue: UIViewAutoresizing.flexibleWidth.rawValue | UIViewAutoresizing.flexibleHeight.rawValue)
        
        view.addSubview(splitController.view)
        splitController.didMove(toParentViewController: self)
        splitController.arrangement = .horizontal
        
        let metalViewController = storyboard?.instantiateViewController(withIdentifier: "MetalViewController") as? MetalViewController
        let codeViewController = storyboard?.instantiateViewController(withIdentifier: "CodeViewController") as? CodeViewController
        
        codeViewController?.playAction = { text in
            if let metalViewController = metalViewController, let text = text {
                metalViewController.mtkView.isPaused = false
                metalViewController.setRenderPipeline(fragmentShader: text)
            }
        }
        
        codeViewController?.pauseAction = {
            if let metalViewController = metalViewController {
                metalViewController.mtkView.isPaused = true
            }
        }
        
        metalViewController?.finishedCompiling = { result, compilerMessages in
            if result {
                if let codeViewController = codeViewController {
                    codeViewController.removePoints()
                }
            } else {
                if let codeViewController = codeViewController, let compilerMessages = compilerMessages {
                    codeViewController.updateViewWithPoints(messages: compilerMessages)
                }
            }
        }
        
        splitController.firstChild = codeViewController
        splitController.secondChild = metalViewController
        
        let playBarItem = UIBarButtonItem(title: "Play", style: .plain, target: codeViewController, action: #selector(codeViewController?.onPlayButtonTapped))
        
        navigationItem.rightBarButtonItems = [playBarItem]
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}

