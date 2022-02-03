//
//  CollectionModel.swift
//  Fruitstand
//
//  Created by Armand Sarkani on 1/19/22.
//

import Foundation
import Combine
import SwiftCSV
import UniformTypeIdentifiers
import SwiftUI
import WidgetKit

class CollectionModel: ObservableObject {
    @Published var collection: [DeviceType: [ProductInfo]] = [DeviceType.iPhone: [], DeviceType.iPad: [], DeviceType.Mac: [], DeviceType.AppleWatch: [], DeviceType.AirPods: [], DeviceType.AppleTV: [], DeviceType.iPod: []]
    @Published var collectionArray: [ProductInfo] = []
    @Published var modelList: [DeviceType: [ModelAndCount]] = [DeviceType.iPhone: [], DeviceType.iPad: [], DeviceType.Mac: [], DeviceType.AppleWatch: [], DeviceType.AirPods: [], DeviceType.AppleTV: [], DeviceType.iPod: []]
    @Published var collectionSize: Int = 0
    @Published var iCloudStatus: Bool = false
    @Published var widgetModel: WidgetModel = WidgetModel(accentColor: Color.accentColor, deviceTypeCounts: [], collectionSize: 0, deviceTypeValues: [], averageValues: [], totalCollectionValue: 0)
    @Published var productJustAdded: Bool = false

    init()
    {
        checkiCloudStatus()
        if(iCloudStatus)
        {
            NotificationCenter.default.addObserver(self,
                selector: #selector(CollectionModel.ubiquitousKeyValueStoreDidChange),
                name: NSUbiquitousKeyValueStore.didChangeExternallyNotification,
                object: NSUbiquitousKeyValueStore.default)
        }
    }
    func saveMultipleProducts(products: inout [ProductInfo])
    {
        for (index, product) in products.enumerated() {
            if(collectionSize >= 1000)
            {
                break
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
            products[index].uuid = uuid
            
            // Save to collection
            collection[product.type ?? DeviceType.Mac]!.append(products[index])
            collectionSize += 1
            collectionArray.append(products[index])

            // Save to UserDefaults/iCloud
            if(iCloudStatus)
            {
                let userDefaults = NSUbiquitousKeyValueStore.default
                var UUIDArray: [String] = userDefaults.object(forKey: "uuidArray") as? [String] ?? []
                UUIDArray.append(uuid)
                userDefaults.set(UUIDArray, forKey: "uuidArray")
                userDefaults.setCodableObject(products[index], forKey: uuid)
                NSUbiquitousKeyValueStore.default.synchronize()
            }
            else
            {
                let userDefaults = UserDefaults.standard
                var UUIDArray: [String] = userDefaults.object(forKey: "uuidArray") as? [String] ?? []
                UUIDArray.append(uuid)
                userDefaults.set(UUIDArray, forKey: "uuidArray")
                userDefaults.setCodableObject(products[index], forKey: uuid)
                userDefaults.synchronize()
            }
        }
        saveWidgetModel()
        loadModelList()
    }
    func saveOneProduct(product: inout ProductInfo)
    {
        // Complete product
        if(collectionSize >= 1000)
        {
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
        if(getModelListIndex(product: product) != -1) // model already exists in collection, optimized update
        {
            let currentModelAndCount: ModelAndCount = modelList[product.type!]![getModelListIndex(product: product)]
            let newModelAndCount: ModelAndCount = ModelAndCount(model: product.model!, count: currentModelAndCount.count! + 1, rank: currentModelAndCount.rank)
            modelList[product.type!]![getModelListIndex(product: product)] = newModelAndCount
        }
        else
        {
            loadModelList()
        }
       
        collectionSize += 1
        collectionArray.append(product)
        saveWidgetModel()

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
        collectionArray[returnCollectionArrayIndexByProduct(product: product)] = product
        loadModelList()
        saveWidgetModel()
        
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
    @objc func ubiquitousKeyValueStoreDidChange(notification: NSNotification) {
        print("iCloud Sync Update Received")
        DispatchQueue.main.async {
            self.loadCollection(count: 0)
        }
    }
    func loadCollection(count: Int)
    {
        if(count > 1)
        {
            return
        }
        collection = [DeviceType.iPhone: [], DeviceType.iPad: [], DeviceType.Mac: [], DeviceType.AppleWatch: [], DeviceType.AirPods: [], DeviceType.AppleTV: [], DeviceType.iPod: []]
        collectionArray = []
        collectionSize = 0
        var dictionary: [String: Any]
        var UUIDArray: [String]
        if(iCloudStatus)
        {
            NSUbiquitousKeyValueStore.default.set(false, forKey: "_UIConstraintBasedLayoutLogUnsatisfiable")
            UUIDArray = NSUbiquitousKeyValueStore.default.object(forKey: "uuidArray") as? [String] ?? []
            dictionary = NSUbiquitousKeyValueStore.default.dictionaryRepresentation
        }
        else
        {
            UserDefaults.standard.set(false, forKey: "_UIConstraintBasedLayoutLogUnsatisfiable")
            UUIDArray = UserDefaults.standard.object(forKey: "uuidArray") as? [String] ?? []
            dictionary = UserDefaults.standard.dictionaryRepresentation()
        }
        // Loads entire collection from UserDefaults into memory
        for uuid in UUIDArray
        {
            if(dictionary[uuid] != nil)
            {
                var product: ProductInfo
                product = try! JSONDecoder().decode(ProductInfo.self, from: dictionary[uuid] as! Data)
                collection[product.type ?? DeviceType.Mac]!.append(product)
                collectionArray.append(product)
                collectionSize += 1
            }
            else
            {
                print("UUID not found!")
            }
        }
        loadModelList()
        saveWidgetModel()
      
    }
    func resetCollection() {
        // Update collection
        collection = [DeviceType.iPhone: [], DeviceType.iPad: [], DeviceType.Mac: [], DeviceType.AppleWatch: [], DeviceType.AirPods: [], DeviceType.AppleTV: [], DeviceType.iPod: []]
        modelList = [DeviceType.iPhone: [], DeviceType.iPad: [], DeviceType.Mac: [], DeviceType.AppleWatch: [], DeviceType.AirPods: [], DeviceType.AppleTV: [], DeviceType.iPod: []]
        collectionArray = []
        collectionSize = 0
        saveWidgetModel()
        
        // Update UserDefaults/iCloud
        if(iCloudStatus)
        {
            let userDefaults = NSUbiquitousKeyValueStore.default
            let dictionary = userDefaults.dictionaryRepresentation
            dictionary.keys.forEach { key in
                if(key != "userColor" && key != "launchedBefore") {
                    userDefaults.removeObject(forKey: key)
                }
            }
            NSUbiquitousKeyValueStore.default.synchronize()
        }
        else
        {
            let userDefaults = UserDefaults.standard
            let dictionary = userDefaults.dictionaryRepresentation()
            dictionary.keys.forEach { key in
                if(key != "userColor" && key != "launchedBefore") {
                    userDefaults.removeObject(forKey: key)
                }
            }
            userDefaults.synchronize()
        }
        print("Reset collection to default settings.")
    }
    func eraseProduct(product: ProductInfo) {
       // Save to collection
        collection[product.type!]!.remove(at: returnCollectionIndexByProduct(product: product))
        collectionArray.remove(at: returnCollectionArrayIndexByProduct(product: product))
        let currentModelAndCount: ModelAndCount = modelList[product.type!]![getModelListIndex(product: product)]
        if(currentModelAndCount.count! - 1 == 0)
        {
            modelList[product.type!]!.remove(at: getModelListIndex(product: product))
        }
        else
        {
            let newModelAndCount: ModelAndCount = ModelAndCount(model: product.model!, count: currentModelAndCount.count! - 1, rank: currentModelAndCount.rank)
            modelList[product.type!]![getModelListIndex(product: product)] = newModelAndCount
        }
        
        collectionSize -= 1
        saveWidgetModel()
        
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
    func returnCollectionArrayIndexByProduct(product: ProductInfo) -> Int
    {
        for (index, element) in collectionArray.enumerated()
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
    func getDeviceTypeCountsSorted() -> [DeviceTypeCount]
    {
        var deviceTypeCounts: [DeviceTypeCount] = []
        for deviceType in collection.keys
        {
            deviceTypeCounts.append(DeviceTypeCount(deviceType: deviceType, count: collection[deviceType]!.count))
        }
        deviceTypeCounts.sort{$0.count > $1.count}
        return deviceTypeCounts
    }
    func checkiCloudStatus()
    {
        iCloudStatus = FileManager.default.ubiquityIdentityToken != nil ? true : false
        
    }
    func saveWidgetModel()
    {
        widgetModel.accentColor = Color(UserDefaults.standard.colorForKey(key: "userColor") ??  UIColor.tintColor)
        widgetModel.deviceTypeCounts = getDeviceTypeCountsSorted()
        widgetModel.collectionSize = collectionSize
        widgetModel.deviceTypeValues = getDeviceTypeValuesSorted(collection: self.collection)
        widgetModel.averageValues = getAverageValuesSorted(collection: self.collection, deviceTypeCounts: getDeviceTypeCounts())
        widgetModel.totalCollectionValue = getTotalCollectionValue(collection: self.collection)
        
        let userDefaultsAppGroup = UserDefaults(suiteName: "group.armandsarkani.fruitstand")!
        userDefaultsAppGroup.setCodableObject(widgetModel, forKey: "widgetModel")
        WidgetCenter.shared.reloadAllTimelines()
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
    func getModelListIndex(product: ProductInfo) -> Int
    {
        for (index, model) in modelList[product.type!]!.enumerated() {
            if(product.model == model.model)
            {
                return index
            }
        }
        return -1
    }
    func getModelCount(model: String) -> Int
    {
        for deviceType in modelList.keys {
            for modelAndCount in modelList[deviceType]! {
                if(modelAndCount.model == model)
                {
                    return modelAndCount.count!
                }
            }
        }
        return 0
    }


}

struct ModelAndCount: Codable, Hashable
{
    var model: String
    var count: Int?
    var rank: Int
}
