//
//  ExamplesViewController.swift
//  MetalToy
//
//  Created by Antonie Jovanoski on 11/13/19.
//  Copyright © 2019 Toni Jovanoski. All rights reserved.
//

import UIKit

class ExamplesViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, KUIPopOverUsable {
    
    @IBOutlet weak var tableView: UITableView!
    var contentSize = CGSize(width: 280, height: 600)
    
    var selectedHandler: ((URL) -> ())?
    
    let examples: [String] = {
        let fm = FileManager.default
        
        let subdir = Bundle.main.resourceURL!.appendingPathComponent("examples").path
        
        return try! fm.contentsOfDirectory(atPath: subdir)
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    // MARK: UITableViewDataSource
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        examples.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "exampleCell", for: indexPath)
        let row = indexPath.row
        
        cell.textLabel?.text = examples[row]
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let row = indexPath.row
        
        let folderUrl = Bundle.main.resourceURL!.appendingPathComponent("examples", isDirectory: true)
        let fileUrl = folderUrl.appendingPathComponent(examples[row])
        
        dismissPopover(animated: true)
        
        if let closure = selectedHandler {
            closure(fileUrl)
        }
    }
}

extension ExamplesViewController {
    func showPopover(barButtonItem: UIBarButtonItem, selectedClosure: ((URL) -> ())?) {
        selectedHandler = selectedClosure
        
        showPopover(barButtonItem: barButtonItem)
    }
}
