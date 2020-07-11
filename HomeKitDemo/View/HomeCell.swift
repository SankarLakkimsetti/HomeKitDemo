//
//  HomeCell.swift
//  HomeKitDemo
//
//  Created by Sridhar Karnatapu on 11/07/20.
//  Copyright © 2020 Shankar. All rights reserved.
//

import UIKit
import HomeKit

class HomeCell: UICollectionViewCell {
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var label: UILabel!
    
    var home: HMHome? {
      didSet {
        if let home = home {
          label.text = home.name
        }
      }
    }
}
