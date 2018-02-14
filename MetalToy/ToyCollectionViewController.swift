//
//  ToyCollectionViewController.swift
//  MetalToy
//
//  Created by minimoog on 1/23/18.
//  Copyright © 2018 Toni Jovanoski. All rights reserved.
//

import UIKit

private let reuseIdentifier = "ToyCell"

public func localDocumentDir() -> URL {
    let dirpaths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
    
    return dirpaths[0]
}

class ToyCollectionViewController: UICollectionViewController {
    var fileList: [String] = [String]()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Do any additional setup after loading the view.
        let addButton = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(ToyCollectionViewController.plusButtonClicked))
        navigationItem.rightBarButtonItem = addButton
        
        let backButton = UIBarButtonItem(title: "Save", style: .done, target: nil, action: nil)
        navigationItem.backBarButtonItem = backButton
        
        refreshFiles()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func refreshFiles() {
        fileList = []
        
        let localDir = localDocumentDir()
        let localDocuments = try? FileManager.default.contentsOfDirectory(at: localDir, includingPropertiesForKeys: nil, options: .skipsHiddenFiles)
        
        if let documents = localDocuments {
            for document in documents {
                fileList.append(document.lastPathComponent)
            }
        }
        
        collectionView?.reloadData()
    }
    
    @objc func plusButtonClicked() {
        if let editorViewController = storyboard?.instantiateViewController(withIdentifier: "EditorViewController") as? ViewController {
            if let navigator = navigationController {
                navigator.pushViewController(editorViewController, animated: true)
            }
            
            editorViewController.savedDocumentAction = {
                //we should append files not refresh but currently it does the job
                
                self.refreshFiles()
            }
        }
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
        return fileList.count
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! ToyCollectionViewCell
        
        if let name = try? String(contentsOfFile: localDocumentDir().path + "/" + fileList[indexPath.item] + "/name.txt", encoding: .utf8) {
            cell.toyNameLabel.text = name
        }
        
        let imageFilePath = localDocumentDir().path + "/" + fileList[indexPath.item] + "/thumbnail.png"
        
        if let image = UIImage(contentsOfFile: imageFilePath) {
            cell.thumbnailImageView.image = image
        }
        
        return cell
    }

    // MARK: UICollectionViewDelegate

    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let fileName = fileList[indexPath.item]
        
        if let editorViewController = storyboard?.instantiateViewController(withIdentifier: "EditorViewController") as? ViewController {
            editorViewController.fileName = fileName
            
            if let navigator = navigationController {
                navigator.pushViewController(editorViewController, animated: true)
            }
            
            editorViewController.savedDocumentAction = {
                //we should append files not refresh but currently it does the job
                
                self.refreshFiles()
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
