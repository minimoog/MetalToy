//
//  МetalViewPanelContentController.swift
//  MetalToy
//
//  Created by minimoog on 3/1/18.
//  Copyright © 2018 Toni Jovanoski. All rights reserved.
//

import UIKit

class MetalViewPanelContentController: UIViewController, PanelContentDelegate {
    
    var metalViewController: MetalViewController?

    public var closing: (() -> ())?
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Navigation

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let destination = segue.destination
        
        if let metalViewController = destination as? MetalViewController {
            self.metalViewController = metalViewController
        }
    }

    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent // .default
    }
    
    // MARK: PanelContentDelegate
    
    var preferredPanelContentSize: CGSize {
        return CGSize(width: 320, height: 500)
    }
    
    var maximumPanelContentSize: CGSize {
        return CGSize(width: 512, height: 600)
    }
    
    var preferredPanelPinnedWidth: CGFloat {
        return 500
    }
    
    func closed() {
        if let closing = closing {
            closing()
        }
    }
}
