//
//  CompilerMessageButton.swift
//  MetalToy
//
//  Created by minimoog on 12/26/17.
//  Copyright © 2017 Toni Jovanoski. All rights reserved.
//

import UIKit

// Button showed in the gutter in code editor when there is compiler error

class CompilerMessageButton: UIView {
    open var message: String?
    fileprivate var button: UIButton?
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("not implemented")
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        button = UIButton(frame: bounds)
        button?.contentMode = .scaleAspectFill
        button?.setImage(#imageLiteral(resourceName: "gutter"), for: .normal)
        button?.addTarget(self, action: #selector(buttonTapped), for: .touchUpInside)
        
        addSubview(button!)
    }
    
    @objc func buttonTapped(sender: UIButton) {
        
        // Show the error message when button is tapped
        
        if let message = message {
            let messageViewController = PopupMessageViewController()
            messageViewController.message = message
            messageViewController.showPopover(sourceView: button!)
        }
    }
}
