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

class TextureSelectorViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    internal var contentSize: CGSize = CGSize(width: 280, height: 600)
    internal var selectedFilename: String? = nil
    
    @IBOutlet weak var texSelectorTableView: UITableView!
    
    // closure invoke when user selects texture unit
    public var selectedTextureOnTextureUnit: ((String, Int) -> ())?
    
    public var textureUnits = [TextureUnit](repeating: TextureUnit(filename: "NULL"), count: 4)
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        
        // update the current table view
        if let selectedIndexPath = texSelectorTableView.indexPathForSelectedRow {
            let selectedRow = selectedIndexPath.row
            texSelectorTableView.deselectRow(at: selectedIndexPath, animated: true)
            
            if let filename = selectedFilename {
                textureUnits[selectedRow] = TextureUnit(filename: filename)
                texSelectorTableView.reloadRows(at: [selectedIndexPath], with: .automatic)
                
                if let selectedTextureOnTextureUnit = selectedTextureOnTextureUnit {
                    selectedTextureOnTextureUnit(filename, selectedRow)
                }
            }
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Navigation

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "TexSelectorToTextureSegue" {
            if let texturesCollectionViewController = segue.destination as? TexturesCollectionViewController {
                selectedFilename = nil
                
                //setup closures from texture collection view controller
                
                // when user select texture from texture list
                texturesCollectionViewController.selectedTexture = {
                    self.selectedFilename = $0
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
