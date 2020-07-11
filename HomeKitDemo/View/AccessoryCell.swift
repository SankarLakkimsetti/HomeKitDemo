//
//  AccessoryCell.swift
//  HomeKitDemo
//
//  Created by Sridhar Karnatapu on 11/07/20.
//  Copyright © 2020 Shankar. All rights reserved.
//

import UIKit
import HomeKit

class AccessoryCell: UICollectionViewCell {
    enum LightbulbState: String {
      case on
      case off
    }
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var label: UILabel!
    
    var accessory: HMAccessory? {
      didSet {
        if let accessory = accessory {
          label.text = accessory.name
          
          let state = getLightbulbState(accessory)
          imageView.image = UIImage(named: state.rawValue)
        }
      }
    }
    
    private func getLightbulbState(_ accessory: HMAccessory) -> LightbulbState {
       guard let characteristic = accessory.find(serviceType: HMServiceTypeLightbulb, characteristicType: HMCharacteristicMetadataFormatBool),
         let value = characteristic.value as? Bool else {
           return .off
       }
       
       return value ? .on : .off
     }
}
