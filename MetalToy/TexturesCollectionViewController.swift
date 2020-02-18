//
//  TexturesCollectionViewController.swift
//  MetalToy
//
//  Created by minimoog on 8/14/18.
//  Copyright © 2018 Toni Jovanoski. All rights reserved.
//

import UIKit

private let reuseIdentifier = "TextureCell"

class TexturesCollectionViewController: UICollectionViewController {

    // closure invoked when texture is selected
    public var selectedTexture: ((String) -> ())?

    let texturePaths: [String] = {
        let fm = FileManager.default
        let path = Bundle.main.resourcePath!
        
        let textureFiles = try! fm.contentsOfDirectory(atPath: path)
        let paths = textureFiles.filter{ $0.hasPrefix("tex_") }.map{ path + "/" + $0 }
        
        return paths
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using [segue destinationViewController].
        // Pass the selected object to the new view controller.
    }
    */

    // MARK: UICollectionViewDataSource

    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }


    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return texturePaths.count
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! TextureCollectionViewCell
    
        cell.textureView.image = UIImage(contentsOfFile: texturePaths[indexPath.row])
        
        return cell
    }

    // MARK: UICollectionViewDelegate

    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let row = indexPath.row
        
        collectionView.deselectItem(at: indexPath, animated: true)
                
        if let nc = navigationController {
            nc.popViewController(animated: true)
            
            if let selectedTexture = self.selectedTexture {
                selectedTexture(self.texturePaths[row])
            }
        }
    }
    
    /*
    // Uncomment this method to specify if the specified item should be highlighted during tracking
    override func collectionView(_ collectionView: UICollectionView, shouldHighlightItemAt indexPath: IndexPath) -> Bool {
        return true
    }
    */

    /*
    // Uncomment this method to specify if the specified item should be selected
    override func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
        return true
    }
    */

    /*
    // Uncomment these methods to specify if an action menu should be displayed for the specified item, and react to actions performed on the item
    override func collectionView(_ collectionView: UICollectionView, shouldShowMenuForItemAt indexPath: IndexPath) -> Bool {
        return false
    }

    override func collectionView(_ collectionView: UICollectionView, canPerformAction action: Selector, forItemAt indexPath: IndexPath, withSender sender: Any?) -> Bool {
        return false
    }

    override func collectionView(_ collectionView: UICollectionView, performAction action: Selector, forItemAt indexPath: IndexPath, withSender sender: Any?) {
    
    }
    */

}
