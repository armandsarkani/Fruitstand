//
//  CollectionStatistics.swift
//  Fruitstand
//
//  Created by Armand Sarkani on 1/18/22.
//

// This module is responsible for the collection statistics model.

import Foundation

struct DeviceTypeValue: Hashable {
    var deviceType: DeviceType
    var totalValue: Int?
    var averageValue: Double?
}

func getDeviceTypeValuesSorted(collection: [DeviceType: [ProductInfo]]) -> [DeviceTypeValue]
{
    var deviceTypeValues: [DeviceTypeValue] = []
    for deviceType in collection.keys {
        var totalValue = 0
        for device in collection[deviceType]! {
            totalValue += device.estimatedValue ?? 0
        }
        deviceTypeValues.append(DeviceTypeValue(deviceType: deviceType, totalValue: totalValue))
        
    }
    deviceTypeValues.sort{$0.totalValue ?? 0 > $1.totalValue ?? 0}
    return deviceTypeValues
}

func getDeviceTypeValuesUnsorted(collection: [DeviceType: [ProductInfo]]) -> [DeviceType: Int]
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
    let deviceTypeValues: [DeviceType: Int] = getDeviceTypeValuesUnsorted(collection: collection)
    return deviceTypeValues[DeviceType.iPhone]! + deviceTypeValues[DeviceType.iPad]! + deviceTypeValues[DeviceType.Mac]! + deviceTypeValues[DeviceType.AppleWatch]! + deviceTypeValues[DeviceType.AirPods]! + deviceTypeValues[DeviceType.AppleTV]! + deviceTypeValues[DeviceType.iPod]!

}

func getAverageValuesSorted(collection: [DeviceType: [ProductInfo]], deviceTypeCounts: [DeviceType: Int]) -> [DeviceTypeValue]
{
    let deviceTypeValues: [DeviceType: Int] = getDeviceTypeValuesUnsorted(collection: collection)
    var averageValues: [DeviceTypeValue] = []
    for deviceType in deviceTypeValues.keys
    {
        if(deviceTypeCounts[deviceType]! != 0){
            let average = Double(deviceTypeValues[deviceType]!)/Double(deviceTypeCounts[deviceType]!)
            averageValues.append(DeviceTypeValue(deviceType: deviceType, averageValue: average))
        }
        else {
            averageValues.append(DeviceTypeValue(deviceType: deviceType, averageValue: 0.0))
            
        }
    }
    averageValues.sort{$0.averageValue ?? 0.0 > $1.averageValue ?? 0.0}
    return averageValues
}
