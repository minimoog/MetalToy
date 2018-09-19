//
//  ToyCollectionViewController.swift
//  MetalToy
//
//  Created by minimoog on 1/23/18.
//  Copyright © 2018 Toni Jovanoski. All rights reserved.
//

import UIKit

private let reuseIdentifier = "ToyCell"

extension UINavigationController {
    open override var preferredStatusBarStyle: UIStatusBarStyle {
        return topViewController?.preferredStatusBarStyle ?? .default
    }
}

class ToyCollectionViewController: UICollectionViewController {
    var selectionMode: Bool = false
    var documentManager: DocumentManager = DocumentManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Do any additional setup after loading the view.
        
        restoreDefaultRightButtonsAndState()
        
        setNeedsStatusBarAppearanceUpdate();
        
        let backButton = UIBarButtonItem(title: "Save", style: .done, target: nil, action: nil)
        navigationItem.backBarButtonItem = backButton
        
        documentManager.refreshFiles()
        collectionView?.reloadData()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }

    func restoreDefaultRightButtonsAndState() {
        let addButton = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(ToyCollectionViewController.plusButtonClicked))
        let selectButton = UIBarButtonItem(title: "Select", style: .plain, target: self, action: #selector(self.selectButtonClicked))
        
        navigationItem.setRightBarButtonItems([addButton, selectButton], animated: true)
        
        collectionView?.allowsMultipleSelection = false
        
        //deselect everything
        guard let indexPaths = collectionView?.indexPathsForSelectedItems else { return }
        
        for indexPath in indexPaths {
            collectionView?.deselectItem(at: indexPath, animated: true)
        }
    }
    
    @objc func plusButtonClicked() {
        if let editorViewController = storyboard?.instantiateViewController(withIdentifier: "EditorViewController") as? EditorViewController {
            if let navigator = navigationController {
                navigator.pushViewController(editorViewController, animated: true)
            }
            
            editorViewController.savedDocumentAction = {
                //we should append files not refresh but currently it does the job
                
                self.documentManager.refreshFiles()
                self.collectionView?.reloadData()
            }
        }
    }
    
    @objc func selectButtonClicked() {
        let deleteButton = UIBarButtonItem(barButtonSystemItem: .trash, target: self, action: #selector(self.trashButtonClicked))
        let cancelButton = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(self.cancelButtonClicked))
        
        navigationItem.setRightBarButtonItems([deleteButton, cancelButton], animated: true)
        
        collectionView?.allowsMultipleSelection = true
    }
    
    @objc func trashButtonClicked() {
        defer {
            restoreDefaultRightButtonsAndState()
        }
        
        guard let selectedIndexPaths = collectionView?.indexPathsForSelectedItems else { return }
        let selectedItems = selectedIndexPaths.map { $0.item }
        
        documentManager.removeDocuments(indices: selectedItems)
        
        // ### TODO: Invoke alert here
        
        collectionView?.deleteItems(at: selectedIndexPaths) //could be problematicß
    }
    
    @objc func cancelButtonClicked() {
        
        restoreDefaultRightButtonsAndState()
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
        return documentManager.count
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! ToyCollectionViewCell
        
        cell.toyNameLabel.text = documentManager.namePathComponent(index: indexPath.item)
        
        let imageFilePath: String = documentManager.imagePathComponent(index: indexPath.item)
        
        if let image = UIImage(contentsOfFile: imageFilePath) {
            cell.thumbnailImageView.image = image
        }
        
        return cell
    }

    // MARK: UICollectionViewDelegate

    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        //if it's in selected mode
        if collectionView.allowsMultipleSelection {
            return
        }
        
        let documentURL = documentManager[indexPath.item]
        
        //collectionView.selectItem(at: indexPath, animated: true, scrollPosition: .top)
        
        if let editorViewController = storyboard?.instantiateViewController(withIdentifier: "EditorViewController") as? EditorViewController {
            editorViewController.documentURL = documentURL
            
            if let navigator = navigationController {
                navigator.pushViewController(editorViewController, animated: true)
            }
            
            editorViewController.savedDocumentAction = {
                //we should append files not refresh but currently it does the job
                
                self.documentManager.refreshFiles()
                self.collectionView?.reloadData()
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
