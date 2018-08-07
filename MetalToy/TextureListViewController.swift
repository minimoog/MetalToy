//
//  TextureListViewController.swift
//  MetalToy
//
//  Created by minimoog on 8/8/18.
//  Copyright © 2018 Toni Jovanoski. All rights reserved.
//

import UIKit

class TextureListViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var textureListTableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
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

    // MARK: Table View
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 5
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cellTexture", for: indexPath)
        
        let row = indexPath.row
        
        cell.textLabel?.text = "\(row)"
        
        return cell
    }
}
