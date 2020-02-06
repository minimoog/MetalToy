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
    internal var rootvc: UIViewController? = nil
    
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
    
    convenience init(frame: CGRect, rootViewController: UIViewController) {
        self.init(frame: frame)
        self.rootvc = rootViewController
    }
    
    // ### TODO: Actually this should be closure instead passing root view controller
    
    @objc func buttonTapped(sender: UIButton) {
        
        // Show the error message when button is tapped
        
        if let message = message {
            let messageViewController = PopupMessageViewController()
            messageViewController.message = message
            
            messageViewController.modalPresentationStyle = .popover
            let popVc = messageViewController.popoverPresentationController
            popVc?.sourceView = button
            
            rootvc?.present(messageViewController, animated: true)
        }
    }
}
