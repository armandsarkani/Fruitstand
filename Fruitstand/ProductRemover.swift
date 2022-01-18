//
//  ProductRemover.swift
//  Fruitstand
//
//  Created by Armand Sarkani on 1/18/22.
//

import Foundation
import Combine

func resetDefaults() {
    let userDefaults = UserDefaults.standard
    let dictionary = userDefaults.dictionaryRepresentation()
    dictionary.keys.forEach { key in
        userDefaults.removeObject(forKey: key)
    }
    print("Reset to default settings.")
}

func resetCloudDefaults() {
    let allKeys = NSUbiquitousKeyValueStore.default.dictionaryRepresentation.keys
    for key in allKeys {
        NSUbiquitousKeyValueStore.default.removeObject(forKey: key)
    }
}

func removeFromUUIDArray(uuid: String)
{
    let userDefaults = UserDefaults.standard
    var UUIDArray: [String] = userDefaults.object(forKey: "uuidArray") as? [String] ?? []
    if let index = UUIDArray.firstIndex(of: uuid) {
      UUIDArray.remove(at: index)
    }
    userDefaults.set(UUIDArray, forKey: "uuidArray")
    
}

func eraseProduct(uuid: String) {
    let userDefaults = UserDefaults.standard
    userDefaults.removeObject(forKey: uuid)
    removeFromUUIDArray(uuid: uuid)
}

