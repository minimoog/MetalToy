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
    @IBOutlet weak var keyboardHeightLayoutConstraint: NSLayoutConstraint!
    weak var metalViewController: MetalViewController?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        codeView.text = DefaultFragmentShader
        
        //keyboard
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWasShown), name: NSNotification.Name.UIKeyboardDidShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillBeHidden), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    @objc func onPlayButtonTapped(sender: UIBarButtonItem) {
        if sender.title == "Play" {
            sender.title = "Pause"
            
            if let metalViewController = metalViewController {
                metalViewController.mtkView.isPaused = false
                metalViewController.setRenderPipeline(fragmentShader: codeView.text)
            }
        } else {
            sender.title = "Play"
            
            if let metalViewController = metalViewController {
                metalViewController.mtkView.isPaused = true
            }
        }
    }
    
    @objc func keyboardWasShown(notification: NSNotification) {
        let info = notification.userInfo!
        let keyboardFrame: CGRect = (info[UIKeyboardFrameEndUserInfoKey] as! NSValue).cgRectValue
        
        UIView.animate(withDuration: 0.1, animations: { () -> Void in
            self.keyboardHeightLayoutConstraint.constant = keyboardFrame.size.height + 20
        })
    }
    
    @objc func keyboardWillBeHidden(notification: NSNotification) {
        UIView.animate(withDuration: 0.1, animations: { () -> Void in
            self.keyboardHeightLayoutConstraint.constant = 20
        })
    }
    
    @objc func keyboardNotification(notification: NSNotification) {
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
