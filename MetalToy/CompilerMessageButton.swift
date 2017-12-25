//
//  CompilerMessageButton.swift
//  MetalToy
//
//  Created by minimoog on 12/26/17.
//  Copyright © 2017 Toni Jovanoski. All rights reserved.
//

import UIKit

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
        button?.addTarget(self, action: #selector(buttonTapped), for: .touchUpInside)
        
        addSubview(button!)
    }
    
    @objc func buttonTapped(sender: UIButton) {
        if let message = message {
            let messageViewController = PopupMessageViewController()
            messageViewController.message = message
            messageViewController.showPopover(sourceView: button!, sourceRect: CGRect(x: 0, y: ButtonSize * 0.5, width: 1.0, height: 1.0))
        }
    }
    
    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */

}
