//
//  CollectionModel.swift
//  Fruitstand
//
//  Created by Armand Sarkani on 1/19/22.
//

import Foundation
import Combine
import SwiftCSV

struct ModelAndCount: Codable, Hashable
{
    var model: String
    var count: Int?
    var rank: Int
}

class CollectionModel: ObservableObject {
    @Published var collection: [DeviceType: [ProductInfo]] = [DeviceType.iPhone: [], DeviceType.iPad: [], DeviceType.Mac: [], DeviceType.AppleWatch: [], DeviceType.AirPods: [], DeviceType.AppleTV: [], DeviceType.iPod: []]
    @Published var collectionArray: [ProductInfo] = []
    @Published var modelList: [DeviceType: [ModelAndCount]] = [DeviceType.iPhone: [], DeviceType.iPad: [], DeviceType.Mac: [], DeviceType.AppleWatch: [], DeviceType.AirPods: [], DeviceType.AppleTV: [], DeviceType.iPod: []]
    @Published var collectionSize: Int = 0
    @Published var iCloudStatus: Bool = false
    init()
    {
        loadCollection()
        loadModelList()
        checkiCloudStatus()
    }
    func saveOneProduct(product: inout ProductInfo)
    {
        // Complete product
        if(collectionSize >= 1000)
        {
            print("Cannot save this product. Max number of products reached.")
            return
        }
        var uuidPrefix = product.type!.id
        if(product.type!.id == "Apple TV")
        {
            uuidPrefix = "AppleTV"
        }
        else if(product.type!.id == "Apple Watch")
        {
            uuidPrefix = "AppleWatch"
        }
        let uuid = uuidPrefix + "_" + UUID().uuidString
        product.uuid = uuid
        
        // Save to collection
        collection[product.type ?? DeviceType.Mac]!.append(product)
        loadModelList()
        collectionSize += 1

        // Save to UserDefaults/iCloud
        if(iCloudStatus)
        {
            let userDefaults = NSUbiquitousKeyValueStore.default
            var UUIDArray: [String] = userDefaults.object(forKey: "uuidArray") as? [String] ?? []
            UUIDArray.append(uuid)
            userDefaults.set(UUIDArray, forKey: "uuidArray")
            userDefaults.setCodableObject(product, forKey: uuid)
            NSUbiquitousKeyValueStore.default.synchronize()
        }
        else
        {
            let userDefaults = UserDefaults.standard
            var UUIDArray: [String] = userDefaults.object(forKey: "uuidArray") as? [String] ?? []
            UUIDArray.append(uuid)
            userDefaults.set(UUIDArray, forKey: "uuidArray")
            userDefaults.setCodableObject(product, forKey: uuid)
            userDefaults.synchronize()
        }

    }
    func updateOneProduct(product: ProductInfo)
    {
        // Save to collection
        collection[product.type!]![returnCollectionIndexByProduct(product: product)] = product
        loadModelList()
        
        // Save changes to UserDefaults/iCloud
        if(iCloudStatus)
        {
            let userDefaults = NSUbiquitousKeyValueStore.default
            userDefaults.setCodableObject(product, forKey: product.uuid ?? "Error_UUID")
            NSUbiquitousKeyValueStore.default.synchronize()
        }
        else
        {
            let userDefaults = UserDefaults.standard
            userDefaults.setCodableObject(product, forKey: product.uuid ?? "Error_UUID")
            userDefaults.synchronize()
        }
    }
    func loadCollection()
    {
        collection = [DeviceType.iPhone: [], DeviceType.iPad: [], DeviceType.Mac: [], DeviceType.AppleWatch: [], DeviceType.AirPods: [], DeviceType.AppleTV: [], DeviceType.iPod: []]
        collectionArray = []
        collectionSize = 0
        var UUIDArray: [String]
        if(iCloudStatus)
        {
            NSUbiquitousKeyValueStore.default.set(false, forKey: "_UIConstraintBasedLayoutLogUnsatisfiable")
            UUIDArray = NSUbiquitousKeyValueStore.default.object(forKey: "uuidArray") as? [String] ?? []
        }
        else
        {
            UserDefaults.standard.set(false, forKey: "_UIConstraintBasedLayoutLogUnsatisfiable")
            UUIDArray = UserDefaults.standard.object(forKey: "uuidArray") as? [String] ?? []
        }
        // Loads entire collection from UserDefaults into memory
        for uuid in UUIDArray
        {
            var product: ProductInfo
            if(iCloudStatus)
            {
                product = NSUbiquitousKeyValueStore.default.getCodableObject(dataType: ProductInfo.self, key: uuid) ?? ProductInfo(model: "nil")
            }
            else
            {
                product = UserDefaults.standard.getCodableObject(dataType: ProductInfo.self, key: uuid) ?? ProductInfo(model: "nil")
            }
            if(product.model != "nil")
            {
                collection[product.type ?? DeviceType.Mac]!.append(product)
                collectionArray.append(product)
                collectionSize += 1
            }
            else
            {
                print("UUID not found.")
            }
            
        }
        loadModelList()
    }
    func resetCollection() {
        // Update collection
        collection = [DeviceType.iPhone: [], DeviceType.iPad: [], DeviceType.Mac: [], DeviceType.AppleWatch: [], DeviceType.AirPods: [], DeviceType.AppleTV: [], DeviceType.iPod: []]
        modelList = [DeviceType.iPhone: [], DeviceType.iPad: [], DeviceType.Mac: [], DeviceType.AppleWatch: [], DeviceType.AirPods: [], DeviceType.AppleTV: [], DeviceType.iPod: []]
        collectionSize = 0
        
        // Update UserDefaults/iCloud
        if(iCloudStatus)
        {
            let userDefaults = NSUbiquitousKeyValueStore.default
            let dictionary = userDefaults.dictionaryRepresentation
            dictionary.keys.forEach { key in
                userDefaults.removeObject(forKey: key)
            }
            NSUbiquitousKeyValueStore.default.synchronize()
        }
        else
        {
            let userDefaults = UserDefaults.standard
            let dictionary = userDefaults.dictionaryRepresentation()
            dictionary.keys.forEach { key in
                userDefaults.removeObject(forKey: key)
            }
            userDefaults.synchronize()
        }
        print("Reset collection to default settings.")
    }
    func eraseProduct(product: ProductInfo) {
       // Save to collection
        collection[product.type!]!.remove(at: returnCollectionIndexByProduct(product: product))
        loadModelList()
        collectionSize -= 1
        
        // Save changes to UserDefaults/iCloud
        if(iCloudStatus)
        {
            let userDefaults = NSUbiquitousKeyValueStore.default
            userDefaults.removeObject(forKey: product.uuid!)
        }
        else
        {
            let userDefaults = UserDefaults.standard
            userDefaults.removeObject(forKey: product.uuid!)
        }
        removeProductFromUUIDArray(uuid: product.uuid!)
    }
    func removeProductFromUUIDArray(uuid: String)
    {
        if(iCloudStatus)
        {
            let userDefaults = NSUbiquitousKeyValueStore.default
            var UUIDArray: [String] = userDefaults.object(forKey: "uuidArray") as? [String] ?? []
            if let index = UUIDArray.firstIndex(of: uuid) {
              UUIDArray.remove(at: index)
            }
            userDefaults.set(UUIDArray, forKey: "uuidArray")
            NSUbiquitousKeyValueStore.default.synchronize()
        }
        else
        {
            let userDefaults = UserDefaults.standard
            var UUIDArray: [String] = userDefaults.object(forKey: "uuidArray") as? [String] ?? []
            if let index = UUIDArray.firstIndex(of: uuid) {
              UUIDArray.remove(at: index)
            }
            userDefaults.set(UUIDArray, forKey: "uuidArray")
            userDefaults.synchronize()
        }

    }
    func returnCollectionIndexByProduct(product: ProductInfo) -> Int
    {
        for (index, element) in collection[product.type!]!.enumerated()
        {
            if(element.uuid == product.uuid)
            {
                return index
            }
        }
        print("Failed to find product in collection.")
        return 0
                
    }
    func isEmpty() -> Bool
    {
        if(collectionSize == 0)
        {
            return true
        }
        return false
    }
    func getDeviceTypeCounts() -> [DeviceType: Int]
    {
        var deviceTypeCounts: [DeviceType: Int] = [:]
        for deviceType in collection.keys
        {
            deviceTypeCounts[deviceType] = collection[deviceType]!.count
        }
        return deviceTypeCounts
    }
    func checkiCloudStatus()
    {
        iCloudStatus = FileManager.default.ubiquityIdentityToken != nil ? true : false
        
    }
    // View Model functions
    func loadMatchingProductsByModel(deviceType: DeviceType, model: String) -> [ProductInfo]
    {
        return collection[deviceType]!.filter{$0.model == model}
    }
    func loadModelList()
    {
        for deviceType in collection.keys
        {
            let matchingProducts = collection[deviceType]!
            var modelStrings: [String] = []
            for product in matchingProducts
            {
                modelStrings.append(product.model!)
            }
            let mappedItems = modelStrings.map { ($0, 1) }
            let modelCounts = Dictionary(mappedItems, uniquingKeysWith: +)
            var modelCountsArray: [ModelAndCount] = []
            for (key, value) in modelCounts
            {
                modelCountsArray.append(ModelAndCount(model: key, count: value, rank: typeToRank(deviceType: deviceType.rawValue, key: key)))
            }
            modelCountsArray.sort{$0.rank < $1.rank}
            modelList[deviceType] = modelCountsArray
        }
    }


}

