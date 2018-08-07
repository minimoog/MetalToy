//
//  TextureSelectorViewController.swift
//  MetalToy
//
//  Created by minimoog on 8/7/18.
//  Copyright © 2018 Toni Jovanoski. All rights reserved.
//

import UIKit

class TextureSelectorViewController: UIViewController, PanelContentDelegate, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var texSelectorTableView: UITableView!
    
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
    
    // MARK: Table View
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 4
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cellTextureUnit", for: indexPath)
        
        let row = indexPath.row
        
        cell.textLabel?.text = "\(row)"
        
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let row = indexPath.row
        
        let viewController = storyboard?.instantiateViewController(withIdentifier: "TextureListViewController") as! TextureListViewController
        panelNavigationController?.pushViewController(viewController, animated: true)
        //navigationController?.pushViewController(viewController, animated: true)
        
        print(row)
    }
}
