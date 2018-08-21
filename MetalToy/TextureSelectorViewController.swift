//
//  TextureSelectorViewController.swift
//  MetalToy
//
//  Created by minimoog on 8/7/18.
//  Copyright © 2018 Toni Jovanoski. All rights reserved.
//

import UIKit

struct TextureUnit {
    let filename: String
    
    var textureName: String {
        get {
            let urlPath = URL(fileURLWithPath: filename)
            return urlPath.deletingPathExtension().lastPathComponent
        }
    }
}

class TextureSelectorViewController: UIViewController, PanelContentDelegate, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var texSelectorTableView: UITableView!
    
    public var selectedTextureOnTextureUnit: ((String, Int) -> ())?
    
    public var textureUnits = [TextureUnit](repeating: TextureUnit(filename: "NULL"), count: 4)
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        panelNavigationController?.navigationBar.barTintColor = UIColor(red: CGFloat(24.0/255.0), green: CGFloat(25.0/255.0), blue: CGFloat(20.0/255.0), alpha: 1.0)
        panelNavigationController?.navigationBar.tintColor = UIColor(red: CGFloat(220.0/255.0), green: CGFloat(207.0/255.0), blue: CGFloat(143.0/255.0), alpha: 1.0)
        
        view.tintColor = UIColor(red: CGFloat(220.0/255.0), green: CGFloat(207.0/255.0), blue: CGFloat(143.0/255.0), alpha: 1.0)
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
        return textureUnits.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cellTextureUnit", for: indexPath)
        
        let row = indexPath.row
        
        cell.textLabel?.text = textureUnits[row].textureName
        
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let viewController = storyboard?.instantiateViewController(withIdentifier: "TexturesCollectionViewController") as! TexturesCollectionViewController
        
        viewController.selectedTexture = {
            filename in
            
            self.panelNavigationController?.popViewController(animated: true)
            
            if let selectedIndexPath = self.texSelectorTableView.indexPathForSelectedRow {
                let selectedRow = selectedIndexPath.row
                
                self.textureUnits[selectedRow] = TextureUnit(filename: filename)
                self.texSelectorTableView.reloadRows(at: [selectedIndexPath], with: .automatic)
                self.texSelectorTableView.deselectRow(at: selectedIndexPath, animated: true)
                
                if let selectedTextureOnTextureUnit = self.selectedTextureOnTextureUnit {
                    selectedTextureOnTextureUnit(filename, selectedRow)
                }
            }
        }
        
        panelNavigationController?.pushViewController(viewController, animated: true)
    }
}
