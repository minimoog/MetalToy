//
//  ShaderDocumentBrowserViewController.swift
//  MetalToy
//
//  Created by minimoog on 10/17/18.
//  Copyright © 2018 Toni Jovanoski. All rights reserved.
//

import UIKit

class ShaderDocumentBrowserViewController: UIDocumentBrowserViewController, UIDocumentBrowserViewControllerDelegate {

    override func viewDidLoad() {
        super.viewDidLoad()
        delegate = self
        
        allowsDocumentCreation = true
        allowsPickingMultipleItems = false
        
        let examplesBarButton = UIBarButtonItem(title: "Examples", style: .plain, target: self, action: #selector(self.onExamplesButtonTapped))
        
        additionalTrailingNavigationBarButtonItems = [examplesBarButton]
    }
    
    // --- Create new document ---
    
    func documentBrowser(_ controller: UIDocumentBrowserViewController,
                         didRequestDocumentCreationWithHandler importHandler: @escaping (URL?, UIDocumentBrowserViewController.ImportMode) -> Void) {
        let doc = ShaderDocument()
        let url = doc.fileURL
        
        //save to temp
        doc.save(to: url, for: .forCreating) { (saveSuccess) in
            guard saveSuccess else {
                importHandler(nil, .none)
                return
            }
            
            // close document
            
            doc.close(completionHandler: { (closeSuccess) in
                guard closeSuccess else {
                    importHandler(nil, .none)
                    return
                }
                
                importHandler(url, .move)
            })
        }
    }

    // ----- Importing document -------
    
    func documentBrowser(_ controller: UIDocumentBrowserViewController, didImportDocumentAt sourceURL: URL, toDestinationURL destinationURL: URL) {
        presentDocument(at: destinationURL)
    }
    
    // ------ Failed importing document ------
    
    func documentBrowser(_ controller: UIDocumentBrowserViewController, failedToImportDocumentAt documentURL: URL, error: Error?) {
        let alert = UIAlertController(title: "Unable to import document",
                                      message: "error: \(String(describing: error?.localizedDescription))",
                                      preferredStyle: .alert)
        
        let action = UIAlertAction(title: "OK", style: .cancel, handler: nil)
        
        alert.addAction(action)
        
        controller.present(alert, animated: true, completion: nil)
    }
    
    // -------- User selects document --------
    
    func documentBrowser(_ controller: UIDocumentBrowserViewController, didPickDocumentURLs documentURLs: [URL]) {
        assert(controller.allowsPickingMultipleItems == false)
        assert(!documentURLs.isEmpty)
        assert(documentURLs.count <= 1)
        
        guard let url = documentURLs.first else {
            fatalError(" no url? ")
        }
        
        presentDocument(at: url)
    }
    
    func documentBrowser(_ controller: UIDocumentBrowserViewController, didPickDocumentsAt documentURLs: [URL]) {
        
        guard let url = documentURLs.first else {
            fatalError(" no url? ")
        }
        presentDocument(at: url)
    }
    
    // -------- Present document -------
    // - Load main storyboard
    // - instatiate navigation controller
    // - pass shader document to the controller
    // - on open document present the controller
    
    func presentDocument(at url: URL) {
        let storyBoard = UIStoryboard(name: "Main", bundle: nil)
        
        let tempController = storyBoard.instantiateViewController(withIdentifier: "EditorNavigationController")
        
        guard let editorNavigationController = tempController as? EditorNavigationController else {
            fatalError("cannot cast to EditorViewController")
        }
        
        //load editor view
        editorNavigationController.loadViewIfNeeded()
        editorNavigationController.modalPresentationStyle = .fullScreen
        
        let doc = ShaderDocument(fileURL: url)
        
        editorNavigationController.document = doc
        
        doc.open { [weak self] (success) in
            guard success else {
                fatalError("Unable to open shader file")
            }
            
            self?.present(editorNavigationController, animated: true, completion: nil)
        }
    }
    
    // examples
    
    @objc func onExamplesButtonTapped(sender: UIBarButtonItem) {
        
        guard let examplesVC = (storyboard?.instantiateViewController(withIdentifier: "ExamplesViewController") as? ExamplesViewController) else { fatalError("Cannot instantiate ExampleViewController") }
        
        examplesVC.showPopover(rootViewController: self, barButtonItem: sender) {
            url in
            
            self.revealDocument(at: url, importIfNeeded: true) {
                url, error in
                
                //if let url = url { print(url) }
                //if let error = error { print(error) }
            }
        }
    }
}
