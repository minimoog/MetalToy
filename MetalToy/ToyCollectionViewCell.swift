//
//  ToyCollectionViewCell.swift
//  MetalToy
//
//  Created by minimoog on 1/23/18.
//  Copyright © 2018 Toni Jovanoski. All rights reserved.
//

import UIKit

class ToyCollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var thumbnailImageView: UIImageView!
    @IBOutlet weak var toyNameLabel: UILabel!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        self.selectedBackgroundView = {
            let view = UIView()
            view.backgroundColor = UIColor.groupTableViewBackground
            return view
        }()
    }
}
