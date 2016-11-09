//
//  ViewController.swift
//  ForestDBTest
//
//  Created by Andy Steinmann on 10/14/16.
//  Copyright © 2016 McKesson. All rights reserved.
//

import UIKit


class ViewController: UIViewController {
    
    @IBOutlet weak var lblTotalDocCount: UILabel!
    
    
    var database: CBLDatabase? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        deleteDatabase() //If Exists
        openDatabase()
        
        
        for batch in 0...1000 {
            print("Start Batch: \(batch)")
            self.loadInitialData(batch: batch)
            print("Done Batch: \(batch)")
            
        }
        self.lblTotalDocCount.text = "Total Document Count:\(self.database!.documentCount)"
    }
    
    func deleteDatabase(){
        self.openDatabase()
        do {
            try self.database?.delete()
            self.database = nil
        } catch {
            print("error deleting database:\(error)")
        }
    }
    
    func openDatabase() {
        do {
            let options = CBLDatabaseOptions()
            options.encryptionKey = "password"
            options.create = true
            options.storageType = kCBLForestDBStorage
            
            self.database = try CBLManager.sharedInstance().openDatabaseNamed("my-database1", with: options)
            
        } catch {
            print("error opening database:\(error)")
        }
    }
    
    func loadInitialData(batch:Int) {
        guard let path = Bundle.main.url(forResource: "InitialData", withExtension: "json") else {
            print("Error finding initial data file")
            return
        }
        
        guard let jsonData = try? Data(contentsOf: path, options: Data.ReadingOptions.mappedIfSafe) else {
            print("Error opening initial data file")
            return
        }
        
        guard let jsonObj = try? JSONSerialization.jsonObject(with: jsonData, options: JSONSerialization.ReadingOptions.mutableContainers) else {
            print("Error deserializing initial data file")
            return
        }
        
        guard let jsonArray = jsonObj as? [[String: AnyObject]] else {
            print("Error casting data as an array")
            return
        }
        
        for var item in jsonArray {
            guard let idPrefix = item.removeValue(forKey: "id") else {
                continue
            }
            let id = "\(idPrefix)_\(batch)"
            
            let doc = self.database?.document(withID: id)
            
            do {
                try doc?.putProperties(item)
            }
            catch {
                print(error)
            }
        }
    }
}

