//
//  ViewController.swift
//  MetalToy
//
//  Created by Toni Jovanoski on 8/20/17.
//  Copyright © 2017 Toni Jovanoski. All rights reserved.
//

import UIKit

let GutterWidth: CGFloat = 22.0

class CodeViewController: UIViewController {
    
    var codeView: UITextView?
    weak var metalViewController: MetalViewController?
    let textStorage = CodeAttributedString()
    var messageButtons = [CompilerMessageButton]()
    
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
        codeView?.textContainerInset = UIEdgeInsets(top: 10, left: GutterWidth, bottom: 0, right: 0)
        
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
    
    func linePosition(inString: String, lastOccurence: Int) -> String.Index? {
        let splitted = inString.split(separator: "\n")
        
        if lastOccurence > splitted.count - 1 {
            return nil
        } else {
            return splitted[lastOccurence].startIndex
        }
    }
    
    func pointForMessage(lineNumber: Int, columnNumber: Int) -> CGPoint {
        let rangeOfPrecedingNewLine: Int
        let lineNumberPlusOffset = lineNumber - 26 //FIX ME
        
        if let indexPos = linePosition(inString: codeView!.text, lastOccurence: lineNumberPlusOffset) {
            rangeOfPrecedingNewLine = indexPos.encodedOffset
        } else {
            rangeOfPrecedingNewLine = 0
        }
        
        let offendingCharacterIndex = rangeOfPrecedingNewLine + columnNumber
        
        let errorStartPosition = codeView?.position(from: (codeView?.beginningOfDocument)!, offset: offendingCharacterIndex)
        let errorStartPositionPlusOne = codeView?.position(from: errorStartPosition!, offset: 1)
        let textRangeForError = codeView?.textRange(from: errorStartPosition!, to: errorStartPositionPlusOne!)
        let offendingCharacterREct = codeView?.firstRect(for: textRangeForError!)
        
        let y = floor((offendingCharacterREct?.midY)! - ButtonSize * 0.5)
        
        return CGPoint(x: 5, y: y)
    }
    
    func updateViewWithPoints(messages: [CompilerErrorMessage]) {
        messageButtons.forEach { $0.removeFromSuperview() }
        messageButtons = []
        
        for message in messages {
            let buttonOrigin = pointForMessage(lineNumber: message.lineNumber, columnNumber: message.columnNumber)
            let buttonRect = CGRect(x: buttonOrigin.x, y: buttonOrigin.y, width: CGFloat(ButtonSize), height: CGFloat(ButtonSize))
            
            let button = CompilerMessageButton(frame: buttonRect)
            button.message = message.message
            
            codeView?.addSubview(button)
            
            messageButtons.append(button)
        }
    }
    
    func removePoints() {
        messageButtons.forEach {
            $0.removeFromSuperview()
        }
        messageButtons.removeAll()
    }
}
