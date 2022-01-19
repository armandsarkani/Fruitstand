//
//  ProductLoader.swift
//  Fruitstand
//
//  Created by Armand Sarkani on 1/9/22.
//

// This module is responsible for loading and saving products from/into UserDefaults/iCloud.

import Foundation
import Combine
import SwiftCSV

struct ModelAndCount: Codable, Hashable
{
    var model: String
    var count: Int?
    var rank: Int
}

func loadMatchingUUIDs(deviceType: String) -> [String]
{
    let userDefaults = NSUbiquitousKeyValueStore.default
    userDefaults.set(false, forKey: "_UIConstraintBasedLayoutLogUnsatisfiable")
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

func loadCollection() -> [DeviceType: [ProductInfo]]
{
    var collection: [DeviceType: [ProductInfo]] = [:]
    collection[DeviceType.iPhone] = loadMatchingProducts(deviceType: DeviceType.iPhone.id)
    collection[DeviceType.iPad] = loadMatchingProducts(deviceType: DeviceType.iPad.id)
    collection[DeviceType.Mac] = loadMatchingProducts(deviceType: DeviceType.Mac.id)
    collection[DeviceType.AppleWatch] = loadMatchingProducts(deviceType: DeviceType.AppleWatch.id)
    collection[DeviceType.AirPods] = loadMatchingProducts(deviceType: DeviceType.AirPods.id)
    collection[DeviceType.AppleTV] = loadMatchingProducts(deviceType: DeviceType.AppleTV.id)
    collection[DeviceType.iPod] = loadMatchingProducts(deviceType: DeviceType.iPod.id)
    return collection

}

func loadMatchingProducts(deviceType: String) -> [ProductInfo]
{
    let matchingUUIDArray = loadMatchingUUIDs(deviceType: deviceType)
    var products: [ProductInfo] = []
    let userDefaults = NSUbiquitousKeyValueStore.default
    for uuid in matchingUUIDArray
    {
        if let product = userDefaults.getCodableObject(dataType: ProductInfo.self, key: uuid)
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
    let userDefaults = NSUbiquitousKeyValueStore.default
    for uuid in matchingUUIDArray
    {
        if let product = userDefaults.getCodableObject(dataType: ProductInfo.self, key: uuid)
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
    var deviceTypeCounts: [DeviceType: Int] = [DeviceType.iPhone: 0, DeviceType.iPad: 0, DeviceType.Mac: 0, DeviceType.AppleWatch: 0, DeviceType.AirPods: 0, DeviceType.AppleTV: 0, DeviceType.iPod: 0]
    deviceTypeCounts[DeviceType.iPhone] = loadMatchingProducts(deviceType: DeviceType.iPhone.id).count
    deviceTypeCounts[DeviceType.iPad] = loadMatchingProducts(deviceType: DeviceType.iPad.id).count
    deviceTypeCounts[DeviceType.Mac] = loadMatchingProducts(deviceType: DeviceType.Mac.id).count
    deviceTypeCounts[DeviceType.AppleWatch] = loadMatchingProducts(deviceType: DeviceType.AppleWatch.id).count
    deviceTypeCounts[DeviceType.AirPods] = loadMatchingProducts(deviceType: DeviceType.AirPods.id).count
    deviceTypeCounts[DeviceType.AppleTV] = loadMatchingProducts(deviceType: DeviceType.AppleTV.id).count
    deviceTypeCounts[DeviceType.iPod] = loadMatchingProducts(deviceType: DeviceType.iPod.id).count
    return deviceTypeCounts
}

func loadSampleCollection()
{
    let iPhoneData = loadCSV(forResource: "SampleCollection/iPhone")
    let iPadData = loadCSV(forResource: "SampleCollection/iPad")
    let MacData = loadCSV(forResource: "SampleCollection/Mac")
    let AppleWatchData = loadCSV(forResource: "SampleCollection/AppleWatch")
    let AirPodsData = loadCSV(forResource: "SampleCollection/AirPods")
    let AppleTVData = loadCSV(forResource: "SampleCollection/AppleTV")
    let iPodData = loadCSV(forResource: "SampleCollection/iPod")
    loadAllProductsFromCSV(productData: iPhoneData, deviceType: DeviceType.iPhone)
    loadAllProductsFromCSV(productData: iPadData, deviceType: DeviceType.iPad)
    loadAllProductsFromCSV(productData: MacData, deviceType: DeviceType.Mac)
    loadAllProductsFromCSV(productData: AppleWatchData, deviceType: DeviceType.AppleWatch)
    loadAllProductsFromCSV(productData: AirPodsData, deviceType: DeviceType.AirPods)
    loadAllProductsFromCSV(productData: AppleTVData, deviceType: DeviceType.AppleTV)
    loadAllProductsFromCSV(productData: iPodData, deviceType: DeviceType.iPod)
    
    
}

func loadAllProductsFromCSV(productData: [[String:String]], deviceType: DeviceType)
{
    let stringToBool: [String: Bool] = ["Yes": true, "No": false]
    for element in productData
    {
        var product: ProductInfo = ProductInfo(type: deviceType, color: element["Color"] ?? nil, workingStatus: WorkingStatus(rawValue: element["Working Status"] ?? ""), estimatedValue: Int(element["Estimated Value"] ?? ""), condition: Condition(rawValue: element["Condition"] ?? ""), acquiredAs: AcquiredAs(rawValue: element["Acquired As"] ?? ""), physicalDamage: stringToBool[element["Physical Damage"] ?? "No"] ?? false, originalBox: stringToBool[element["Original Box"] ?? "No"] ?? false, warranty: Warranty(rawValue: element["Warranty"] ?? ""), yearAcquired: Int(element["Year Acquired"] ?? ""), comments: (element["Comments"] != "" ? element["Comments"]: nil), storage: element["Storage"] ?? nil, activationLock: stringToBool[element["Activation Lock"] ?? "No"] ?? false, carrier: element["Carrier"] ?? nil, ESNStatus: ESNStatus(rawValue: element["ESN Status"] ?? ""), carrierLockStatus: CarrierLockStatus(rawValue: element["Carrier Lock Status"] ?? ""), connectivity: iPadConnectivity(rawValue: element["iPad Connectivity"] ?? ""), year: element["Year"] ?? nil, formFactor: FormFactor(rawValue: element["Form Factor"] ?? ""), screenSize: Int(element["Screen Size"] ?? ""), processor: element["Processor"] ?? nil, memory: element["Memory"] ?? nil, caseType: WatchCaseType(rawValue: element["Watch Case"] ?? ""), caseSize: Int(element["Case Size"] ?? ""), watchConnectivity: WatchConnectivity(rawValue: element["Connectivity"] ?? ""), originalBands: element["Original Bands"] ?? nil, hasRemote: stringToBool[element["Has Remote"] ?? "No"] ?? false, AirPodsCaseType: AirPodsCaseType(rawValue: element["AirPods Case"] ?? ""))
        if(deviceType == DeviceType.iPhone){
            product.iPhoneModel = iPhoneModel(rawValue: element["Model"] ?? "Other") ?? iPhoneModel.Other
            product.model = (product.iPhoneModel ?? iPhoneModel.Other).id
        }
        if(deviceType == DeviceType.iPad){
            product.iPadModel = iPadModel(rawValue: element["Model"] ?? "Other") ?? iPadModel.Other
            product.model = (product.iPadModel ?? iPadModel.Other).id
        }
        if(deviceType == DeviceType.Mac){
            product.MacModel = MacModel(rawValue: element["Model"] ?? "Other") ?? MacModel.Earlier
            product.model = (product.MacModel ?? MacModel.Other).id
        }
        if(deviceType == DeviceType.AppleWatch){
            product.AppleWatchModel = AppleWatchModel(rawValue: element["Model"] ?? "Other") ?? AppleWatchModel.Other
            product.model = (product.AppleWatchModel ?? AppleWatchModel.Other).id
        }
        if(deviceType == DeviceType.AirPods){
            product.AirPodsModel = AirPodsModel(rawValue: element["Model"] ?? "Other") ?? AirPodsModel.Other
            product.model = (product.AirPodsModel ?? AirPodsModel.Other).id
        }
        if(deviceType == DeviceType.AppleTV){
            product.AppleTVModel = AppleTVModel(rawValue: element["Model"] ?? "Other") ?? AppleTVModel.Other
            product.model = (product.AppleTVModel ?? AppleTVModel.Other).id
        }
        if(deviceType == DeviceType.iPod){
            product.iPodModel = iPodModel(rawValue: element["Model"] ?? "Other") ?? iPodModel.Other
            product.model = (product.iPodModel ?? iPodModel.Other).id
        }
        if(product.model == "Other" || product.model == "Earlier Models") {
            product.otherModel = element["Model"]
        }
        saveOneProduct(product: &product)

    }
        
}

func updateOneProduct(product: ProductInfo)
{
    let userDefaults = NSUbiquitousKeyValueStore.default
    userDefaults.setCodableObject(product, forKey: product.uuid ?? "Error_UUID")
    NSUbiquitousKeyValueStore.default.synchronize()
}

func saveOneProduct(product: inout ProductInfo)
{
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
    let userDefaults = NSUbiquitousKeyValueStore.default
    var UUIDArray: [String] = userDefaults.object(forKey: "uuidArray") as? [String] ?? []
    UUIDArray.append(uuid)
    userDefaults.set(UUIDArray, forKey: "uuidArray")
    userDefaults.setCodableObject(product, forKey: uuid)
    NSUbiquitousKeyValueStore.default.synchronize()
}


func loadCSV(forResource: String) -> [[String: String]]
{
    do {
        // From a file (with errors)
        let csvFile: CSV = try CSV(url: Bundle.main.url(forResource: forResource, withExtension: "csv")!)
        return(csvFile.namedRows)
    }
    catch {
        print("Could not load file")
        return [[:]]
    }
}
