//
//  TextureSelectorViewController.swift
//  MetalToy
//
//  Created by minimoog on 8/7/18.
//  Copyright © 2018 Toni Jovanoski. All rights reserved.
//

import UIKit

// ### TODO: This should be a model
struct TextureUnit {
    let filename: String
    
    var textureName: String {
        get {
            let urlPath = URL(fileURLWithPath: filename)
            return urlPath.deletingPathExtension().lastPathComponent
        }
    }
}

class TextureSelectorViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, KUIPopOverUsable {
    internal var contentSize: CGSize = CGSize(width: 512, height: 600)
    
    @IBOutlet weak var texSelectorTableView: UITableView!
    
    // closure invoke when user selects texture unit
    public var selectedTextureOnTextureUnit: ((String, Int) -> ())?
    
    public var textureUnits = [TextureUnit](repeating: TextureUnit(filename: "NULL"), count: 4)
    
    override func viewDidLoad() {
        super.viewDidLoad()
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
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "TexSelectorToTextureSegue" {
            if let texturesCollectionViewController = segue.destination as? TexturesCollectionViewController {
                
                //setup closures from texture collection view controller
                
                // when user select texture from texture list
                texturesCollectionViewController.selectedTexture = {
                    filename in
                    
                    // pop the textures list
                    //self.panelNavigationController?.popViewController(animated: true)
                    self.navigationController?.popViewController(animated: true)
                    
                    // update the current table view
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
                
                texturesCollectionViewController.dismissed = {
                    if let selectedIndexPath = self.texSelectorTableView.indexPathForSelectedRow {
                        self.texSelectorTableView.deselectRow(at: selectedIndexPath, animated: true)
                    }
                }
            }
        }
    }
    
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
}
