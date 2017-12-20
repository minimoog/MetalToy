//
//  ViewController.swift
//  MetalToy
//
//  Created by Toni Jovanoski on 8/20/17.
//  Copyright © 2017 Toni Jovanoski. All rights reserved.
//

import UIKit

class CodeViewController: UIViewController {
    
    var codeView: UITextView?
    weak var metalViewController: MetalViewController?
    let textStorage = CodeAttributedString()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        textStorage.language = "cpp"
        let layoutManager = NSLayoutManager()
        textStorage.addLayoutManager(layoutManager)
        
        let textContainer = NSTextContainer(size: view.bounds.size)
        layoutManager.addTextContainer(textContainer)
        
        codeView = UITextView(frame: view.frame, textContainer: textContainer)
        view.addSubview(codeView!)
        
        codeView?.autoresizingMask = [.flexibleHeight, .flexibleWidth]
        codeView?.autocorrectionType = .no
        codeView?.autocapitalizationType = .none
        codeView?.text = DefaultFragmentShader
        codeView?.translatesAutoresizingMaskIntoConstraints = false
        
        //constraints
        codeView?.widthAnchor.constraint(equalTo: view.safeAreaLayoutGuide.widthAnchor).isActive = true
        codeView?.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor).isActive = true
        codeView?.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor).isActive = true
        view.safeAreaLayoutGuide.bottomAnchor.constraint(equalTo: codeView!.bottomAnchor).isActive = true
        
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
                metalViewController.setRenderPipeline(fragmentShader: codeView!.text)
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
        
        self.view.layoutIfNeeded()
        self.view.safeAreaLayoutGuide.bottomAnchor.constraint(equalTo: self.codeView!.bottomAnchor, constant: keyboardFrame.size.height).isActive = true
        
        UIView.animate(withDuration: 0.1, animations: { () -> Void in
            //self.view.safeAreaLayoutGuide.bottomAnchor.constraint(equalTo: self.codeView!.bottomAnchor, constant: keyboardFrame.size.height).isActive = true
            self.view.layoutIfNeeded()
        })
    }
    
    @objc func keyboardWillBeHidden(notification: NSNotification) {
        
        self.view.layoutIfNeeded()
        self.view.safeAreaLayoutGuide.bottomAnchor.constraint(equalTo: self.codeView!.bottomAnchor, constant: 0).isActive = true
        
        UIView.animate(withDuration: 0.1, animations: { () -> Void in
            //self.view.safeAreaLayoutGuide.bottomAnchor.constraint(equalTo: self.codeView!.bottomAnchor).isActive = true
            self.view.layoutIfNeeded()
        })
    }
    
    @objc func keyboardNotification(notification: NSNotification) {
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
