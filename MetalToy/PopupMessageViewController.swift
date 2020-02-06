//
//  PopupMessageViewController.swift
//  MetalToy
//
//  Created by minimoog on 12/22/17.
//  Copyright © 2017 Toni Jovanoski. All rights reserved.
//

import UIKit

// View controller which shows the error text when error button
// in gutter of editor is pressed

let ButtonSize: CGFloat = 16.0
let MaxWidth: CGFloat = 640.0
let MinHeight: CGFloat = 44.0

class PopupMessageViewController: UIViewController {
    internal var contentSize = CGSize()
    fileprivate var messageLabel: UILabel?
    
    public var message: String = "" {
        didSet {
            loadViewIfNeeded()
            
            messageLabel?.text = message
            
            // render the message text in fake label to determine the frame right size
            
            let fakeLabel = UILabel(frame: CGRect(x: 0.0, y: 0.0, width: MaxWidth - 20.0, height: CGFloat.greatestFiniteMagnitude))
            fakeLabel.numberOfLines = 0
            fakeLabel.font = messageLabel?.font
            fakeLabel.text = messageLabel?.text
            fakeLabel.sizeToFit()
            
            preferredContentSize = CGSize(width: MaxWidth, height: fakeLabel.frame.height + MinHeight)
            contentSize = preferredContentSize
            
            messageLabel?.frame = CGRect(x: 10, y: 10, width: fakeLabel.frame.width, height: fakeLabel.frame.height)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        view.backgroundColor = UIColor.clear
        
        let labelBounds = view.bounds
        
        messageLabel = UILabel(frame: labelBounds)
        messageLabel?.isOpaque = false
        messageLabel?.backgroundColor = UIColor.clear
        messageLabel?.text = "test message"
        messageLabel?.numberOfLines = 0
        
        // ### TODO: Make this code extension of UIFont
        guard let monospacedFont = UIFont(name: "Menlo-Regular", size: UIFont.labelFontSize) else {
            fatalError("Menlo where are you")
        }
        
        messageLabel?.font = UIFontMetrics.default.scaledFont(for: monospacedFont)
        messageLabel?.adjustsFontForContentSizeCategory = true
        
        view.addSubview(messageLabel!)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
