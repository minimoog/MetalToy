//
//  ViewController.swift
//  MetalToy
//
//  Created by Toni Jovanoski on 8/20/17.
//  Copyright © 2017 Toni Jovanoski. All rights reserved.
//

import UIKit

class CodeViewController: UIViewController {
    
    @IBOutlet weak var codeView: UITextView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        codeView.text = DefaultFragmentShader
    }
    
    @IBAction func onPlayPauseButtonClicked(_ sender: UIButton) {
        if sender.currentTitle == "Play" {
            sender.setTitle("Pause", for: .normal)
            //mtkView.isPaused = false
            
            //setRenderPipeline(fragmentShader: codeView.text)
            
        } else {
            sender.setTitle("Play", for: .normal)
            //mtkView.isPaused = true
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
