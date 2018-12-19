//
//  ViewController.swift
//  MetalToy
//
//  Created by Toni Jovanoski on 8/20/17.
//  Copyright © 2017 Toni Jovanoski. All rights reserved.
//

import UIKit

let GutterWidth: CGFloat = 22.0

class CodeViewController: UIViewController, UITextViewDelegate {
    var document: ShaderDocument?
    
    var codeView: UITextView?
    let textStorage = CodeAttributedString()
    var messageButtons = [CompilerMessageButton]()
    var bottomConstraint: NSLayoutConstraint?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        textStorage.language = "cpp"
        textStorage.highlightr.setTheme(to: "Pojoaque")
        textStorage.highlightr.theme.setCodeFont(UIFont(name: "Menlo-Regular", size: 16)!)
        
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
        codeView?.textContainerInset = UIEdgeInsets(top: 10, left: GutterWidth, bottom: 8, right: 0)
        codeView?.backgroundColor = textStorage.highlightr.theme.themeBackgroundColor
 
        //constraints
        codeView?.widthAnchor.constraint(equalTo: view.safeAreaLayoutGuide.widthAnchor).isActive = true
        codeView?.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor).isActive = true
        codeView?.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor).isActive = true
        
        //codeView delegate
        codeView?.delegate = self
        
        bottomConstraint = view.safeAreaLayoutGuide.bottomAnchor.constraint(equalTo: codeView!.bottomAnchor)
        bottomConstraint?.isActive = true
       
        //keyboard
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWasShown), name: NSNotification.Name.UIKeyboardDidShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillBeHidden), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        guard let doc = document else { fatalError("document is null") }
        
        codeView?.text = doc.shaderInfo?.fragment
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        guard let doc = document else { fatalError("document is null") }
        
        doc.close { [weak self] (success) in
            guard success else { fatalError("failed closing the document") }
            
            print("Success closing the document")
        }
    }
    
    @objc func keyboardWasShown(notification: NSNotification) {
        let info = notification.userInfo!
        let keyboardFrame: CGRect = (info[UIKeyboardFrameEndUserInfoKey] as! NSValue).cgRectValue
        
        //self.view.layoutIfNeeded()
        
        UIView.animate(withDuration: 0.1, animations: { () -> Void in
            self.bottomConstraint?.constant = keyboardFrame.size.height
            self.view.layoutIfNeeded()
        })
    }
    
    @objc func keyboardWillBeHidden(notification: NSNotification) {
        
        //self.view.layoutIfNeeded()
        
        UIView.animate(withDuration: 0.1, animations: { () -> Void in
            self.bottomConstraint?.constant = 0
            self.view.layoutIfNeeded()
        })
    }
    
    @objc func keyboardNotification(notification: NSNotification) {
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent // .default
    }
    
    func setTexture(filename: String, index: Int) {
        guard let doc = document else { fatalError("No document set") }
        
        //convert from full filename to texture name  ### needs rework
        let urlPath = URL(fileURLWithPath: filename)
        let textureName = urlPath.lastPathComponent
        
        doc.shaderInfo?.textures[index] = textureName
        doc.updateChangeCount(.done)
    }
    
    // MARK: - UITextViewDelegate
    
    func textViewDidChange(_ textView: UITextView) {
        guard let doc = document else { fatalError("No document set") }
        
        doc.shaderInfo?.fragment = textView.text
        doc.updateChangeCount(.done)
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        guard let doc = document else { fatalError("No document set") }
        
        doc.shaderInfo?.fragment = textView.text
        doc.updateChangeCount(.done)
    }
    
    // MARK: private functions
    
    func linePosition(inString: String, lastOccurence: Int) -> String.Index? {
        let splitted = inString.split(separator: "\n", maxSplits: Int.max, omittingEmptySubsequences: false)
        
        if lastOccurence > splitted.count - 1 {
            return nil
        } else {
            return splitted[lastOccurence].startIndex
        }
    }
    
    func pointForMessage(lineNumber: Int, columnNumber: Int) -> CGPoint {
        let rangeOfPrecedingNewLine: Int
        let lineNumberPlusOffset = lineNumber - 25 - 1 //FIX ME
        
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
