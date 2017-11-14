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
    
    //let textStorage = CodeAttributedString()
    var textStorage = MetalHighlightTextStorage()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        //let attrs = [NSAttributedStringKey.font : UIFont.preferredFont(forTextStyle: UIFontTextStyle.body)]
        //let attrsString = NSAttributedString(string: note.contents, attributes: attrs)
        let layoutManager = NSLayoutManager()
        textStorage.addLayoutManager(layoutManager)
        textStorage.update()
        
        let textContainer = NSTextContainer(size: view.bounds.size)
        layoutManager.addTextContainer(textContainer)
        
        codeView = UITextView(frame: view.frame, textContainer: textContainer)
        codeView?.autoresizingMask = [.flexibleHeight, .flexibleWidth]
        codeView?.autocorrectionType = .no
        codeView?.autocapitalizationType = .none
        
        view.addSubview(codeView!)
        
        codeView?.text = DefaultFragmentShader
        codeView?.translatesAutoresizingMaskIntoConstraints = false
        codeView?.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 20)
        codeView?.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20)
        view.safeAreaLayoutGuide.trailingAnchor.constraint(equalTo: codeView!.trailingAnchor, constant: 20)
        
        //keyboardHeightLayoutConstraint = NSLayoutConstraint(item: view.safeAreaLayoutGuide, attribute: .bottom, relatedBy: .equal, toItem: codeView, attribute: .bottom, multiplier: 1.0, constant: 20)
        
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
        
        UIView.animate(withDuration: 0.1, animations: { () -> Void in
            //self.keyboardHeightLayoutConstraint.constant = keyboardFrame.size.height + 20
            
            self.view.safeAreaLayoutGuide.bottomAnchor.constraint(equalTo: self.codeView!.bottomAnchor, constant: keyboardFrame.size.height + 20)
        })
    }
    
    @objc func keyboardWillBeHidden(notification: NSNotification) {
        UIView.animate(withDuration: 0.1, animations: { () -> Void in
            //self.keyboardHeightLayoutConstraint.constant = 20
            
            self.view.safeAreaLayoutGuide.bottomAnchor.constraint(equalTo: self.codeView!.bottomAnchor, constant: 20)
        })
    }
    
    @objc func keyboardNotification(notification: NSNotification) {
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
