//
//  TextureSelectorViewController.swift
//  MetalToy
//
//  Created by minimoog on 8/7/18.
//  Copyright © 2018 Toni Jovanoski. All rights reserved.
//

import UIKit

class TextureSelectorViewController: UIViewController, PanelContentDelegate {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
