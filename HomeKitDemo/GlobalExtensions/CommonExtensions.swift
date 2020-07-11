//
//  CommonExtensions.swift
//  HomeKitDemo
//
//  Created by Sridhar Karnatapu on 11/07/20.
//  Copyright © 2020 Shankar. All rights reserved.
//

import Foundation
import HomeKit

extension AccessoryViewController: HMAccessoryBrowserDelegate {
    func accessoryBrowser(_ browser: HMAccessoryBrowser, didFindNewAccessory accessory: HMAccessory) {
        discoveredAccessories.append(accessory)
    }
}
extension AccessoryViewController: HMAccessoryDelegate {
    func accessory(_ accessory: HMAccessory, service: HMService,
                   didUpdateValueFor characteristic: HMCharacteristic) {
        accessoryCollectionView?.reloadData()
    }
}
extension HMAccessory {
    func find(serviceType: String, characteristicType: String) -> HMCharacteristic? {
        return services.lazy
            .filter { $0.serviceType == serviceType }
            .flatMap { $0.characteristics }
            .first { $0.metadata?.format == characteristicType }
    }
}
