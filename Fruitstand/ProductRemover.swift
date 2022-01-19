//
//  ProductRemover.swift
//  Fruitstand
//
//  Created by Armand Sarkani on 1/18/22.
//

// This module is responsible for removing products from/into UserDefaults/iCloud.

import Foundation
import Combine

func resetDefaults() {
    let userDefaults = NSUbiquitousKeyValueStore.default
    let dictionary = userDefaults.dictionaryRepresentation
    dictionary.keys.forEach { key in
        userDefaults.removeObject(forKey: key)
    }
    NSUbiquitousKeyValueStore.default.synchronize()
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
    let userDefaults = NSUbiquitousKeyValueStore.default
    var UUIDArray: [String] = userDefaults.object(forKey: "uuidArray") as? [String] ?? []
    if let index = UUIDArray.firstIndex(of: uuid) {
      UUIDArray.remove(at: index)
    }
    userDefaults.set(UUIDArray, forKey: "uuidArray")
    NSUbiquitousKeyValueStore.default.synchronize()
    
}

func eraseProduct(uuid: String) {
    let userDefaults = NSUbiquitousKeyValueStore.default
    userDefaults.removeObject(forKey: uuid)
    removeFromUUIDArray(uuid: uuid)
}

