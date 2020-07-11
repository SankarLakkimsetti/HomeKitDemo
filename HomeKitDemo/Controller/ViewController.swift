//
//  ViewController.swift
//  HomeKitDemo
//
//  Created by Sridhar Karnatapu on 11/07/20.
//  Copyright © 2020 Shankar. All rights reserved.
//

import UIKit
import HomeKit

class ViewController: UIViewController,UICollectionViewDelegate,UICollectionViewDataSource,HMHomeManagerDelegate,UICollectionViewDelegateFlowLayout {
    
    @IBOutlet weak var homeCollectionView: UICollectionView!
    var homes: [HMHome] = []
    let homeManager = HMHomeManager()
    required init?(coder aDecoder: NSCoder) {
      super.init(coder: aDecoder)
      homeManager.delegate = self
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Homes"
        self.homeCollectionView.delegate = self
        self.homeCollectionView.dataSource = self
        addHomes(homeManager.homes)
        homeCollectionView?.reloadData()
    }
    
    @IBAction func AddNewHomeClicked(_ sender: UIBarButtonItem) {
        showInputDialog { homeName, roomName in
            self.homeManager.addHome(withName: homeName) { [weak self] home, error in
                guard let self = self else {
                    return
                }
                if let error = error {
                    print("Failed to add home: \(error.localizedDescription)")
                }
                if let discoveredHome = home {
                    discoveredHome.addRoom(withName: roomName) { _, error  in
                        if let error = error {
                            print("Failed to add room: \(error.localizedDescription)")
                        } else {
                            self.homes.append(discoveredHome)
                            self.homeCollectionView?.reloadData()
                        }
                    }
                }
            }
            
        }
    }
    func showInputDialog(_ handler: @escaping ((String, String) -> Void)) {
        let alertController = UIAlertController(title: "Create new Home?",
                                                message: "Enter the name of your new home and give it a Room",
                                                preferredStyle: .alert)
        
        let confirmAction = UIAlertAction(title: "Create", style: .default) { _ in
            guard let homeName = alertController.textFields?[0].text,
                let roomName = alertController.textFields?[1].text else {
                    return
            }
            
            handler(homeName, roomName)
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
        
        alertController.addTextField { textField in
            textField.placeholder = "Enter Home name"
        }
        alertController.addTextField { textField in
            textField.placeholder = "Enter Room name"
        }
        alertController.addAction(confirmAction)
        alertController.addAction(cancelAction)
        present(alertController, animated: true)
    }
    func addHomes(_ homes: [HMHome]) {
        self.homes.removeAll()
        for home in homes {
            self.homes.append(home)
        }
        homeCollectionView?.reloadData()
    }
    
    //MARK:- CollectionView Delegate Methods
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return homes.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "itemCell", for: indexPath) as! HomeCell
        cell.home = homes[indexPath.row]
        
        return cell
    }
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: true)
        
        let target = navigationController?.storyboard?.instantiateViewController(withIdentifier: "AccessoryViewController") as! AccessoryViewController
        target.home = homes[indexPath.row]
        navigationController?.pushViewController(target, animated: true)
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
    
    func homeManagerDidUpdateHomes(_ manager: HMHomeManager) {
        addHomes(manager.homes)
    }
    
}

