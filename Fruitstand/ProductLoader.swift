//
//  ProductLoader.swift
//  Fruitstand
//
//  Created by Armand Sarkani on 1/9/22.
//

import Foundation
import Combine

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

func loadProducts(deviceType: String) -> [ProductInfo]
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

