//
//  BlockBarButtonItem.swift
//  PanelKit
//
//  Created by Louis D'hauwe on 11/03/2017.
//  Copyright © 2017 Silver Fox. All rights reserved.
//

import UIKit

class BlockBarButtonItem: UIBarButtonItem {

	private var actionHandler: (() -> Void)?

    convenience init(title: String?, style: UIBarButtonItem.Style, actionHandler: (() -> Void)?) {
		self.init(title: title, style: style, target: nil, action: #selector(barButtonItemPressed))
		self.target = self
		self.actionHandler = actionHandler
	}

    convenience init(image: UIImage?, style: UIBarButtonItem.Style, actionHandler: (() -> Void)?) {
		self.init(image: image, style: style, target: nil, action: #selector(barButtonItemPressed))
		self.target = self
		self.actionHandler = actionHandler
	}

	@objc func barButtonItemPressed(sender: UIBarButtonItem) {
		actionHandler?()
	}

    //hacky
    override var title: String? {
        didSet {
            
            if #available(iOS 13.0, *) {
                if self.title == "Close" {
                    self.image = UIImage(systemName: "xmark.circle")
                } else if self.title == "⬇︎" {
                    self.image = UIImage(systemName: "arrow.down.circle")
                }
            }
        }
    }
}
