//
//  ViewController.swift
//  MetalToy
//
//  Created by Toni Jovanoski on 8/20/17.
//  Copyright © 2017 Toni Jovanoski. All rights reserved.
//

import UIKit

let GutterWidth: CGFloat = 22.0

enum KeywordState {
    case entering, other
}

extension String {
    func isAlphaNumeric() -> Bool {
        return rangeOfCharacter(from: CharacterSet.alphanumerics.inverted) == nil && self != ""
    }
}

class CodeViewController: UIViewController, UITextViewDelegate {
    var document: ShaderDocument?
    
    var codeView: UITextView?
    var previousBarItems: [UIBarButtonItem] = []
    var undoBarItem: UIBarButtonItem?
    var redoBarItem: UIBarButtonItem?
    let textStorage = CodeAttributedString()
    let inputAssistantView: InputAssistantView = InputAssistantView()
    var messageButtons = [CompilerMessageButton]()
    var bottomConstraint: NSLayoutConstraint?
    
    let allSuggestions = SuggestionList
    let fixedSuggestion = ["[ ]", "{ }"]
    var matchedSuggestions: [String] = []
    
    var keywordBuffer: String = String()
    var suggestionKeyWordState: KeywordState = .other
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        textStorage.language = "cpp"
        
        if traitCollection.userInterfaceStyle == .dark {
            textStorage.highlightr.setTheme(to: "qtcreator_dark")
        } else {
            textStorage.highlightr.setTheme(to: "qtcreator_light")
        }
        
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
        
        if #available(iOS 13.0, *) {
            codeView?.backgroundColor = UIColor.systemBackground
        } else {
            codeView?.backgroundColor = textStorage.highlightr.theme.themeBackgroundColor
        }
 
        //constraints
        codeView?.widthAnchor.constraint(equalTo: view.safeAreaLayoutGuide.widthAnchor).isActive = true
        codeView?.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor).isActive = true
        codeView?.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor).isActive = true
        
        //codeView delegate
        codeView?.delegate = self
        
        bottomConstraint = view.safeAreaLayoutGuide.bottomAnchor.constraint(equalTo: codeView!.bottomAnchor)
        bottomConstraint?.isActive = true
       
        //keyboard
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWasShown), name: UIResponder.keyboardDidShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillBeHidden), name: UIResponder.keyboardWillHideNotification, object: nil)
        
        //input assistant view
        inputAssistantView.delegate = self
        inputAssistantView.dataSource = self
        inputAssistantView.attach(to: codeView!)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        //install undo/redo buttons
        if #available(iOS 13.0, *) {
            undoBarItem = UIBarButtonItem(image: UIImage(systemName: "arrow.uturn.left.circle"),
                                          style: .plain,
                                          target: self,
                                          action: #selector(self.onUndoButtonTapped))
            
            redoBarItem = UIBarButtonItem(image: UIImage(systemName: "arrow.uturn.right.circle"),
                                          style: .plain,
                                          target: self,
                                          action: #selector(self.onRedoButtonTapped))
        } else {
            undoBarItem = UIBarButtonItem(barButtonSystemItem: .undo, target: self, action: #selector(self.onUndoButtonTapped))
            redoBarItem = UIBarButtonItem(barButtonSystemItem: .redo, target: self, action: #selector(self.onRedoButtonTapped))
        }
        
        if let parent = parent, let leftBarItems = parent.navigationItem.leftBarButtonItems {
            previousBarItems = leftBarItems
            parent.navigationItem.leftBarButtonItems = previousBarItems + [undoBarItem!, redoBarItem!]
        }
        
        guard let doc = document else { fatalError("document is null") }
        
        codeView?.text = doc.shaderInfo?.fragment
        
        updateUndoButtons()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        //remove undo/redo buttons
        if let parent = parent {
            parent.navigationItem.leftBarButtonItems = previousBarItems
        }
        
        guard let doc = document else { fatalError("document is null") }
        
        doc.close { [weak self] (success) in
            guard success else { fatalError("failed closing the document") }
            
            print("Success closing the document")
        }
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        
        if traitCollection.userInterfaceStyle != previousTraitCollection?.userInterfaceStyle {
            if traitCollection.userInterfaceStyle == .dark {
                textStorage.highlightr.setTheme(to: "qtcreator_dark")
                textStorage.highlightr.theme.setCodeFont(UIFont(name: "Menlo-Regular", size: 16)!) //yeah sets need to be set again
            } else {
                textStorage.highlightr.setTheme(to: "qtcreator_light")
                textStorage.highlightr.theme.setCodeFont(UIFont(name: "Menlo-Regular", size: 16)!)
            }
        }
    }
    
    @objc func keyboardWasShown(notification: NSNotification) {
        let info = notification.userInfo!
        let keyboardFrame: CGRect = (info[UIResponder.keyboardFrameEndUserInfoKey] as! NSValue).cgRectValue
        
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
    
    @objc func onUndoButtonTapped(sender: UIBarButtonItem) {
        codeView?.undoManager?.undo()
        updateUndoButtons()
    }
    
    @objc func onRedoButtonTapped(sender: UIBarButtonItem) {
        codeView?.undoManager?.redo()
        updateUndoButtons()
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
    
    func updateUndoButtons() {
        undoBarItem?.isEnabled = codeView?.undoManager?.canUndo ?? false
        redoBarItem?.isEnabled = codeView?.undoManager?.canRedo ?? false
    }
    
    // MARK: - UITextViewDelegate
    
    func textViewDidChange(_ textView: UITextView) {
        guard let doc = document else { fatalError("No document set") }
        
        doc.shaderInfo?.fragment = textView.text
        doc.updateChangeCount(.done)
        
        updateUndoButtons()
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        guard let doc = document else { fatalError("No document set") }
        
        doc.shaderInfo?.fragment = textView.text
        doc.updateChangeCount(.done)
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        matchedSuggestions = []
        
        if range.length == 1 { //delete
            //remove character from keyword buffer
            
            if !keywordBuffer.isEmpty {
                keywordBuffer.removeLast()
            }
        } else {
            
            if text.isAlphaNumeric() {
                suggestionKeyWordState = .entering
                keywordBuffer.append(text)
                
                matchedSuggestions = allSuggestions.filter { $0.hasPrefix(keywordBuffer) }
            } else {
                suggestionKeyWordState = .other
                keywordBuffer = String()
            }
        }
        
        //matchedSuggestions.append(contentsOf: fixedSuggestion)
        
        inputAssistantView.reloadData()
        
        return true
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
    
    func pointForMessage(lineNumber: Int, columnNumber: Int) -> CGPoint? {
        let rangeOfPrecedingNewLine: Int
        let lineNumberPlusOffset = lineNumber - 25 - 1 //FIX ME
        
        if let indexPos = linePosition(inString: codeView!.text, lastOccurence: lineNumberPlusOffset) {
            //rangeOfPrecedingNewLine = indexPos.encodedOffset
            rangeOfPrecedingNewLine = indexPos.utf16Offset(in: codeView!.text)
        } else {
            rangeOfPrecedingNewLine = 0
        }
        
        let offendingCharacterIndex = rangeOfPrecedingNewLine + columnNumber
        
        guard let beginningOfDocument = codeView?.beginningOfDocument else { return nil }
        guard let errorStartPosition = codeView?.position(from: beginningOfDocument, offset: offendingCharacterIndex) else { return nil }
        guard let errorStartPositionPlusOne = codeView?.position(from: errorStartPosition, offset: 1) else { return nil }
        guard let textRangeForError = codeView?.textRange(from: errorStartPosition, to: errorStartPositionPlusOne) else { return nil }
        guard let offendingCharacterREct = codeView?.firstRect(for: textRangeForError) else { return nil }
        
        let y = floor(offendingCharacterREct.midY - ButtonSize * 0.5)
        
        return CGPoint(x: 5, y: y)
    }
    
    func updateViewWithPoints(messages: [CompilerErrorMessage]) {
        messageButtons.forEach { $0.removeFromSuperview() }
        messageButtons = []
        
        for message in messages {
            guard let buttonOrigin = pointForMessage(lineNumber: message.lineNumber, columnNumber: message.columnNumber) else { continue }
            let buttonRect = CGRect(x: buttonOrigin.x, y: buttonOrigin.y,width: CGFloat(ButtonSize), height: CGFloat(ButtonSize))
            
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

extension CodeViewController: InputAssistantViewDataSource {
    func textForEmptySuggestionsInInputAssistantView() -> String? {
        return nil
    }
    
    func numberOfSuggestionsInInputAssistantView() -> Int {
        return matchedSuggestions.count + fixedSuggestion.count
    }
    
    func inputAssistantView(_ inputAssistantView: InputAssistantView, nameForSuggestionAtIndex index: Int) -> String {
        return (matchedSuggestions + fixedSuggestion)[index]
    }
}

extension CodeViewController: InputAssistantViewDelegate {
    func inputAssistantView(_ inputAssistantView: InputAssistantView, didSelectSuggestionAtIndex index: Int) {
        if index < (matchedSuggestions.endIndex - fixedSuggestion.count) {
            
            let lengthOfMatched = matchedSuggestions[index].count
            let textToInsert = matchedSuggestions[index].suffix(lengthOfMatched - keywordBuffer.count)
            
            self.codeView!.insertText(String(textToInsert))
        } else {
            self.codeView!.insertText(matchedSuggestions[index])
        }
    }
}
