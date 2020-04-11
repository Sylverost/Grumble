//
//  IOManager.swift
//  Grumble
//
//  Created by Allen Chang on 3/21/20.
//  Copyright © 2020 Cylumn, Inc. All rights reserved.
//

import SwiftUI
import Firebase

private struct DataList: Decodable {
    var foodList: [String: Grub]?
}

//Getter Functions
private func dataPath() -> String {
    let docPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0] as NSString
    let dataPListPath = docPath.appendingPathComponent("data.plist")
    let bundleDataPListURL = Bundle.main.url(forResource: "data", withExtension: "plist")
    do {
        if !FileManager.default.fileExists(atPath: dataPListPath) {
            if let dataBundleURL = bundleDataPListURL {
                //Write Bundle DataPList to DocPList
                let rawData = try Data(contentsOf: dataBundleURL)
                NSData(data: rawData).write(toFile: dataPListPath, atomically: true)
            } else {
                print("error: Bundle data.plist is missing")
            }
        }
        return dataPListPath
    } catch {
        print("error:\(error)")
        return bundleDataPListURL?.path ?? ""
    }
}

//Helper Functions
private func loadPropertyList<T>(_ url: URL?, _ decodable: T.Type) -> T? where T : Decodable {
    guard let url = url else {
        print("error: url is empty")
        return nil
    }
    do {
        if let rawData = FileManager.default.contents(atPath: url.path) {
            let decoder = PropertyListDecoder()
            let data = try decoder.decode(decodable, from: rawData)
            return data
        }
    } catch {
        print("error:\(error)")
    }
    return nil
}

//Data Functions
public func loadLocalData() {
    if let data = loadPropertyList(URL(string: dataPath()), DataList.self) {
        UserCookie.uc().setFoodList(data.foodList ?? [:] as [String: Grub])
    }
}

public func clearLocalData() {
    if let rootDataDictionary = NSMutableDictionary(contentsOfFile: dataPath()) {
        (rootDataDictionary["foodList"] as! NSMutableDictionary).removeAllObjects()
        rootDataDictionary.write(toFile: dataPath(), atomically: true)
    }
}

public func loadCloudData(_ returnData: @escaping (NSDictionary?) -> Void) {
    if let uid = Auth.auth().currentUser?.uid {
        Database.database().reference().child("users").child(uid).observeSingleEvent(of: .value, with: { (snapshot) in
            returnData(snapshot.value as? NSDictionary)
        })
    }
}

//FoodList Functions
public func appendLocalFood(_ key: String, _ foodItem: NSDictionary) {
    if let rootDataDictionary = NSMutableDictionary(contentsOfFile: dataPath()) {
        (rootDataDictionary["foodList"] as! NSDictionary).setValue(foodItem, forKey: key)
        rootDataDictionary.write(toFile: dataPath(), atomically: true)
    }
}

public func appendCloudFood(_ key: String, _ foodItem: NSDictionary) {
    if let uid = Auth.auth().currentUser?.uid {
        Database.database().reference().child("users").child(uid).child("foodList").child(key).setValue(foodItem)
    }
}

public func removeLocalFood(_ key: String) {
    if let rootDataDictionary = NSMutableDictionary(contentsOfFile: dataPath()) {
        (rootDataDictionary["foodList"] as! NSMutableDictionary).removeObject(forKey: key)
        rootDataDictionary.write(toFile: dataPath(), atomically: true)
    }
}

public func removeCloudFood(_ key: String) {
    if let uid = Auth.auth().currentUser?.uid {
        Database.database().reference().child("users").child(uid).child("foodList").child(key).removeValue()
    }
}

//Cloud Observers
private func onCloudFoodAdded(_ snapshot: DataSnapshot) {
    if let foodItem = snapshot.value as? NSDictionary {
        UserCookie.uc().appendFoodList(snapshot.key, Grub(foodItem))
        appendLocalFood(snapshot.key, foodItem)
    }
}

private func onCloudFoodRemoved(_ snapshot: DataSnapshot) {
    UserCookie.uc().removeFoodList(snapshot.key)
    removeLocalFood(snapshot.key)
}

//User Login/Logout
public func onLogin() {
    if let uid = Auth.auth().currentUser?.uid {
        UserCookie.uc().setLoggedIn(true)
        TabRouter.tr().changeTab(.list)
        
        let ref = Database.database().reference()
        ref.child("users").child(uid).child("foodList").observe(DataEventType.childAdded, with: onCloudFoodAdded)
        ref.child("users").child(uid).child("foodList").observe(DataEventType.childRemoved, with: onCloudFoodRemoved)
    }
}

public func onLogout() {
    do {
        if let uid = Auth.auth().currentUser?.uid {
            Database.database().reference().child("users").child(uid).child("foodList").removeAllObservers()
        }
        
        try Auth.auth().signOut()
        UserCookie.uc().setLoggedIn(false)
        UserCookie.uc().setFoodList([:] as [String: Grub])
        clearLocalData()
        
        KeyboardObserver.ko().clearFields()
        KeyboardObserver.ko().appendField(.login)
    } catch {
        print("error:\(error)")
    }
}
