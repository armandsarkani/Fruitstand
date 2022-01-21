//
//  SampleCollectionLoader.swift
//  Fruitstand
//
//  Created by Armand Sarkani on 1/19/22.
//

import Foundation
import SwiftCSV

func loadNewSampleCollection(collection: CollectionModel)
{
    let iPhoneData = loadCSVFile(forResource: "SampleCollection/iPhone")
    let iPadData = loadCSVFile(forResource: "SampleCollection/iPad")
    let MacData = loadCSVFile(forResource: "SampleCollection/Mac")
    let AppleWatchData = loadCSVFile(forResource: "SampleCollection/AppleWatch")
    let AirPodsData = loadCSVFile(forResource: "SampleCollection/AirPods")
    let AppleTVData = loadCSVFile(forResource: "SampleCollection/AppleTV")
    let iPodData = loadCSVFile(forResource: "SampleCollection/iPod")
    loadNewProductsFromCSV(collection: collection, productData: iPhoneData, deviceType: DeviceType.iPhone)
    loadNewProductsFromCSV(collection: collection, productData: iPadData, deviceType: DeviceType.iPad)
    loadNewProductsFromCSV(collection: collection, productData: MacData, deviceType: DeviceType.Mac)
    loadNewProductsFromCSV(collection: collection, productData: AppleWatchData, deviceType: DeviceType.AppleWatch)
    loadNewProductsFromCSV(collection: collection, productData: AirPodsData, deviceType: DeviceType.AirPods)
    loadNewProductsFromCSV(collection: collection, productData: AppleTVData, deviceType: DeviceType.AppleTV)
    loadNewProductsFromCSV(collection: collection, productData: iPodData, deviceType: DeviceType.iPod)
    
}

func loadNewProductsFromCSV(collection: CollectionModel, productData: [[String:String]], deviceType: DeviceType)
{
    let stringToBool: [String: Bool] = ["Yes": true, "No": false]
    for element in productData
    {
        var product: ProductInfo = ProductInfo(type: deviceType, color: element["Color"] ?? nil, workingStatus: WorkingStatus(rawValue: element["Working Status"] ?? ""), estimatedValue: Int(element["Estimated Value"] ?? ""), condition: Condition(rawValue: element["Condition"] ?? ""), acquiredAs: AcquiredAs(rawValue: element["Acquired As"] ?? ""), physicalDamage: stringToBool[element["Physical Damage"] ?? "No"] ?? false, originalBox: stringToBool[element["Original Box"] ?? "No"] ?? false, warranty: Warranty(rawValue: element["Warranty"] ?? ""), yearAcquired: Int(element["Year Acquired"] ?? ""), comments: (element["Comments"] != "" ? element["Comments"]: nil), storage: element["Storage"] ?? nil, activationLock: stringToBool[element["Activation Lock"] ?? "No"] ?? false, carrier: element["Carrier"] ?? nil, ESNStatus: ESNStatus(rawValue: element["ESN Status"] ?? ""), carrierLockStatus: CarrierLockStatus(rawValue: element["Carrier Lock Status"] ?? ""), connectivity: iPadConnectivity(rawValue: element["iPad Connectivity"] ?? ""), year: element["Year"] ?? nil, formFactor: FormFactor(rawValue: element["Form Factor"] ?? ""), screenSize: Int(element["Screen Size"] ?? ""), processor: element["Processor"] ?? nil, memory: element["Memory"] ?? nil, caseType: WatchCaseType(rawValue: element["Watch Case"] ?? ""), caseSize: Int(element["Case Size"] ?? ""), watchConnectivity: WatchConnectivity(rawValue: element["Connectivity"] ?? ""), originalBands: element["Original Bands"] ?? nil, hasRemote: stringToBool[element["Has Remote"] ?? "No"] ?? false, APCaseType: AirPodsCaseType(rawValue: element["AirPods Case"] ?? ""))
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
        collection.saveOneProduct(product: &product)

    }
        
}

func loadCSVFile(forResource: String) -> [[String: String]]
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

