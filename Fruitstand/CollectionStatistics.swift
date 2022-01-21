//
//  CollectionStatistics.swift
//  Fruitstand
//
//  Created by Armand Sarkani on 1/18/22.
//

// This module is responsible for the collection statistics model.

import Foundation

func getDeviceTypeValues(collection: [DeviceType: [ProductInfo]]) -> [DeviceType: Int]
{
    var deviceTypeValues: [DeviceType: Int] = [DeviceType.iPhone: 0, DeviceType.iPad: 0, DeviceType.Mac: 0, DeviceType.AppleWatch: 0, DeviceType.AirPods: 0, DeviceType.AppleTV: 0, DeviceType.iPod: 0]
    for deviceType in collection.keys {
        for device in collection[deviceType]! {
            deviceTypeValues[deviceType]! += device.estimatedValue ?? 0
        }
    }
    return deviceTypeValues
}

func getTotalCollectionValue(collection: [DeviceType: [ProductInfo]]) -> Int
{
    let deviceTypeValues: [DeviceType: Int] = getDeviceTypeValues(collection: collection)
    return deviceTypeValues[DeviceType.iPhone]! + deviceTypeValues[DeviceType.iPad]! + deviceTypeValues[DeviceType.Mac]! + deviceTypeValues[DeviceType.AppleWatch]! + deviceTypeValues[DeviceType.AirPods]! + deviceTypeValues[DeviceType.AppleTV]! + deviceTypeValues[DeviceType.iPod]!

}

func getAverageValues(collection: [DeviceType: [ProductInfo]], deviceTypeCounts: [DeviceType: Int]) -> [DeviceType: Double]
{
    let deviceTypeValues: [DeviceType: Int] = getDeviceTypeValues(collection: collection)
    var averageValues: [DeviceType: Double] = [:]
    for deviceType in deviceTypeValues.keys
    {
        if(deviceTypeCounts[deviceType]! != 0){
            let average = Double(deviceTypeValues[deviceType]!)/Double(deviceTypeCounts[deviceType]!)
            averageValues[deviceType] = average
        }
        else {
            averageValues[deviceType] = 0.0
        }
    }
    return averageValues
}
