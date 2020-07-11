//
//  AccessoryViewController.swift
//  HomeKitDemo
//
//  Created by Sridhar Karnatapu on 11/07/20.
//  Copyright © 2020 Shankar. All rights reserved.
//

import UIKit
import HomeKit
class AccessoryViewController: UIViewController,UICollectionViewDataSource,UICollectionViewDelegate,UICollectionViewDelegateFlowLayout {
    
    let activityIndicator = UIActivityIndicatorView(frame: CGRect(x: 0, y: 0, width: 20, height: 20))
    var accessories: [HMAccessory] = []
    var home: HMHome?
    let browser = HMAccessoryBrowser()
    var discoveredAccessories: [HMAccessory] = []
    @IBOutlet weak var accessoryCollectionView: UICollectionView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        activityIndicator.tintColor = UIColor.white
        title = "\(home?.name ?? "") Accessories"
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .search, target: self, action: #selector(discoverAccessories(sender:)))
        loadAccessories()
    }
    //MARK:- CollectionView Delegate Methods
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return accessories.count
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let accessory = accessories[indexPath.row]
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "itemCell", for: indexPath) as! AccessoryCell
        cell.accessory = accessory
        return cell
    }
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: true)
        let accessory = accessories[indexPath.row]
        guard
            let characteristic = accessory.find(serviceType: HMServiceTypeLightbulb,
                                                characteristicType: HMCharacteristicMetadataFormatBool) else {
                                                    return
        }
        
        let toggleState = (characteristic.value as! Bool) ? false : true
        characteristic.writeValue(NSNumber(value: toggleState)) { error in
            if error != nil {
                print("Something went wrong.")
            }
            collectionView.reloadData()
        }
        
    }
    
    func collectionView(_ collectionView: UICollectionView,
                           layout collectionViewLayout: UICollectionViewLayout,
                           sizeForItemAt indexPath: IndexPath) -> CGSize {

           return CGSize(width: 125, height: 125)
       }

       func collectionView(_ collectionView: UICollectionView,
                           layout collectionViewLayout: UICollectionViewLayout,
                           minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
           return 1.0
       }

       func collectionView(_ collectionView: UICollectionView, layout
           collectionViewLayout: UICollectionViewLayout,
                           minimumLineSpacingForSectionAt section: Int) -> CGFloat {
           return 1.0
       }
    private func loadAccessories() {
        guard let homeAccessories = home?.accessories else {
            return
        }
        for accessory in homeAccessories {
            if let characteristic = accessory.find(serviceType: HMServiceTypeLightbulb,
                                                   characteristicType: HMCharacteristicMetadataFormatBool) {
                accessories.append(accessory)
                accessory.delegate = self
                characteristic.enableNotification(true) { error in
                    if error != nil {
                        print("Something went wrong.")
                    }
                }
            }
        }
        accessoryCollectionView?.reloadData()
    }
    @objc func discoverAccessories(sender: UIBarButtonItem) {
        activityIndicator.startAnimating()
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: activityIndicator)
        discoveredAccessories.removeAll()
        browser.delegate = self
        browser.startSearchingForNewAccessories()
        perform(#selector(stopDiscoveringAccessories), with: nil, afterDelay: 10)
        
    }
    @objc private func stopDiscoveringAccessories() {
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .search, target: self, action: #selector(discoverAccessories(sender:)))
        if discoveredAccessories.isEmpty {
            let alert = UIAlertController(
                title: "No Accessories Found",
                message: "No Accessories were found.",
                preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Dismiss", style: .default))
            present(alert, animated: true)
        } else {
            let homeName = home?.name
            let message = """
            Found a total of \(discoveredAccessories.count) accessories. \
            Add them to your home \(homeName ?? "")?
            """
            
            let alert = UIAlertController(
                title: "Accessories Found",
                message: message,
                preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Cancel", style: .default))
            alert.addAction(UIAlertAction(title: "OK", style: .default) { _ in
                self.addAccessories(self.discoveredAccessories)
            })
            present(alert, animated: true)
        }
        
    }
    private func addAccessories(_ accessories: [HMAccessory]) {
        for accessory in accessories {
            home?.addAccessory(accessory) { [weak self] error in
                guard let self = self else {
                    return
                }
                if let error = error {
                    print("Failed to add accessory to home: \(error.localizedDescription)")
                } else {
                    self.loadAccessories()
                }
            }
        }
    }
}

