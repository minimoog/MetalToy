//
//  PopupMessageViewController.swift
//  MetalToy
//
//  Created by minimoog on 12/22/17.
//  Copyright © 2017 Toni Jovanoski. All rights reserved.
//

import UIKit

let ButtonSize: CGFloat = 16.0
let MaxWidth: CGFloat = 320.0
let MinHeight: CGFloat = 44.0

class PopupMessageViewController: UIViewController {
    var messageLabel: UILabel?
    
    var message: String = "" {
        didSet {
            loadViewIfNeeded()
            
            messageLabel?.text = message
            
            let fakeLabel = UILabel(frame: CGRect(x: 0.0, y: 0.0, width: MaxWidth - 20.0, height: CGFloat.greatestFiniteMagnitude))
            fakeLabel.numberOfLines = 0
            fakeLabel.numberOfLines = 0
            fakeLabel.font = messageLabel?.font
            fakeLabel.text = messageLabel?.text
            fakeLabel.sizeToFit()
            
            preferredContentSize = CGSize(width: MaxWidth, height: fakeLabel.frame.height + MinHeight)
            
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
        
        view.addSubview(messageLabel!)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
