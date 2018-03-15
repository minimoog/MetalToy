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
    
    override func viewDidLoad() {
        super.viewDidLoad()

        panelNavigationController?.navigationBar.barTintColor = UIColor(red: CGFloat(24.0 / 255.0), green: CGFloat(25.0 / 255.0), blue: CGFloat(20.0 / 255.0), alpha: 1.0)
        panelNavigationController?.navigationBar.tintColor = UIColor(red: CGFloat(220.0 / 255.0), green: CGFloat(207.0 / 255.0), blue: CGFloat(143.0 / 255.0), alpha: 1.0)
        
        view.tintColor = UIColor(red: CGFloat(220.0 / 255.0), green: CGFloat(207.0 / 255.0), blue: CGFloat(143.0 / 255.0), alpha: 1.0)
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
}
