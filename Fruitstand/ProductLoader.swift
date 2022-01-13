//
//  ProductLoader.swift
//  Fruitstand
//
//  Created by Armand Sarkani on 1/9/22.
//

import Foundation
import Combine

struct ModelAndCount: Codable, Hashable
{
    var model: String
    var count: Int?
    var rank: Int
}

func loadMatchingUUIDs(deviceType: String) -> [String]
{
    let userDefaults = UserDefaults.standard
    let UUIDArray: [String] = userDefaults.object(forKey: "uuidArray") as? [String] ?? []
    var matchingUUIDArray: [String] = []
    for uuid in UUIDArray
    {
        let delimiterLocation = uuid.firstIndex(of: "_")
        var device = uuid[...delimiterLocation!]
        device.remove(at: delimiterLocation!)
        if(device == "AppleTV")
        {
            device = "Apple TV"
        }
        else if(device == "AppleWatch")
        {
            device = "Apple Watch"
        }
        if(deviceType == device)
        {
            matchingUUIDArray.append(uuid)
        }
    }
    return matchingUUIDArray
                
}

func loadMatchingProducts(deviceType: String) -> [ProductInfo]
{
    let matchingUUIDArray = loadMatchingUUIDs(deviceType: deviceType)
    var products: [ProductInfo] = []
    for uuid in matchingUUIDArray
    {
        if let product = UserDefaults.standard.getCodableObject(dataType: ProductInfo.self, key: uuid)
        {
            products.append(product)
        }
        else
        {
            print("Error! UUID not found.")
        }
    }
    return products
}

func loadMatchingProductsByModel(deviceType: String, model: String) -> [ProductInfo]
{
    let matchingUUIDArray = loadMatchingUUIDs(deviceType: deviceType)
    var products: [ProductInfo] = []
    for uuid in matchingUUIDArray
    {
        if let product = UserDefaults.standard.getCodableObject(dataType: ProductInfo.self, key: uuid)
        {
            if(getProductModel(product: product) == model)
            {
                products.append(product)
            }
        }
        else
        {
            print("Error! UUID not found.")
        }
    }
    return products
}

func typeToRank(deviceType: String, key: String) -> Int
{
    let deviceTypeEnum = DeviceType(rawValue: deviceType)!
    if(deviceTypeEnum == DeviceType.iPhone){
        return iPhoneModel(rawValue: key)!.asInt()
    }
    else if(deviceTypeEnum == DeviceType.iPad){
        return iPadModel(rawValue: key)!.asInt()
    }
    else if(deviceTypeEnum == DeviceType.Mac){
        return MacModel(rawValue: key)!.asInt()
    }
    else if(deviceTypeEnum == DeviceType.AppleWatch){
        return AppleWatchModel(rawValue: key)!.asInt()
    }
    else if(deviceTypeEnum == DeviceType.AirPods){
        return AirPodsModel(rawValue: key)!.asInt()
    }
    else if(deviceTypeEnum == DeviceType.AppleTV){
        return AppleTVModel(rawValue: key)!.asInt()
    }
    else{
        return iPodModel(rawValue: key)!.asInt()
    }
}

func loadModelList(deviceType: String) -> [ModelAndCount]
{
    let matchingProducts = loadMatchingProducts(deviceType: deviceType)
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
        modelCountsArray.append(ModelAndCount(model: key, count: value, rank: typeToRank(deviceType: deviceType, key: key)))
     }
    modelCountsArray.sort{$0.rank < $1.rank}
    return modelCountsArray
    
}

func loadDeviceTypeCounts() -> [DeviceType: Int]
{
    var deviceTypeCounts: [DeviceType: Int] = [:]
    deviceTypeCounts[DeviceType.iPhone] = loadMatchingProducts(deviceType: DeviceType.iPhone.id).count
    deviceTypeCounts[DeviceType.iPad] = loadMatchingProducts(deviceType: DeviceType.iPad.id).count
    deviceTypeCounts[DeviceType.Mac] = loadMatchingProducts(deviceType: DeviceType.Mac.id).count
    deviceTypeCounts[DeviceType.AppleWatch] = loadMatchingProducts(deviceType: DeviceType.AppleWatch.id).count
    deviceTypeCounts[DeviceType.AirPods] = loadMatchingProducts(deviceType: DeviceType.AirPods.id).count
    deviceTypeCounts[DeviceType.AppleTV] = loadMatchingProducts(deviceType: DeviceType.AppleTV.id).count
    deviceTypeCounts[DeviceType.iPod] = loadMatchingProducts(deviceType: DeviceType.iPod.id).count
    return deviceTypeCounts
}


