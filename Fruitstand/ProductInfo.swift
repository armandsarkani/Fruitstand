//
//  ProductInfo.swift
//  Fruitstand
//
//  Created by Armand Sarkani on 1/8/22.
//

// This module is responsible for the product model.

import Foundation
import Combine
import SwiftUI

var modelIcons: [String: String] = [:]

extension UserDefaults
{
  func setCodableObject<T: Codable>(_ data: T?, forKey defaultName: String)
  {
    let encoded = try? JSONEncoder().encode(data)
    set(encoded, forKey: defaultName)
   }
}

extension UserDefaults
{
  func getCodableObject<T : Codable>(dataType: T.Type, key: String) -> T?
  {
    guard let userDefaultData = data(forKey: key) else {
      return nil
    }
    return try? JSONDecoder().decode(T.self, from: userDefaultData)
  }
}

extension NSUbiquitousKeyValueStore
{
  func setCodableObject<T: Codable>(_ data: T?, forKey defaultName: String)
  {
    let encoded = try? JSONEncoder().encode(data)
    set(encoded, forKey: defaultName)
   }
}

extension NSUbiquitousKeyValueStore
{
  func getCodableObject<T : Codable>(dataType: T.Type, key: String) -> T?
  {
    guard let userDefaultData = data(forKey: key) else {
      return nil
    }
    return try? JSONDecoder().decode(T.self, from: userDefaultData)
  }
}

extension String {
    func fuzzyMatch(_ needle: String) -> Bool {
        if needle.isEmpty { return true }
        var remainder = needle[...]
        for char in self {
            if char == remainder[remainder.startIndex] {
                remainder.removeFirst()
                if remainder.isEmpty { return true }
            }
        }
        return false
    }
    func smartContains(_ other: String) -> Bool {
        let array : [String] = other.lowercased().components(separatedBy: " ").filter { !$0.isEmpty }
        return array.reduce(true) { !$0 ? false : (self.lowercased().range(of: $1) != nil ) }
    }
}

struct ProductInfo: Codable, Hashable
{
    // Shared with all
    var type: DeviceType?
    var uuid: String?
    var color: String?
    var model: String? 
    var workingStatus: WorkingStatus?
    var estimatedValue: Int?
    var condition: Condition?
    var acquiredAs: AcquiredAs?
    var physicalDamage: Bool? = false
    var originalBox: Bool? = false
    var warranty: Warranty?
    var yearAcquired: Int?
    var comments: String?
    var otherModel: String?
    
    // Shared with iPhone, iPad, Mac, Apple TV, iPod
    var storage: String?
    
    // Shared with iPhone, iPad, Mac, Apple Watch, iPod
    var activationLock: Bool? = false
    
    // iPhone only
    var carrier: String?
    var ESNStatus: ESNStatus?
    var carrierLockStatus: CarrierLockStatus?
    
    // iPad only
    var connectivity: iPadConnectivity?

    // Mac only
    var year: String?
    var formFactor: FormFactor?
    var screenSize: Int?
    var processor: String?
    var memory: String?

    // Apple Watch only
    var caseType: WatchCaseType?
    var caseSize: Int?
    var watchConnectivity: WatchConnectivity?
    var originalBands: String?

    // Apple TV only
    var hasRemote: Bool? = false
    
    // AirPods only
    var APCaseType: AirPodsCaseType?
    
    
    func contains(searchText: String) -> Bool
    {
        let lowercaseSearchText = searchText.lowercased()
        if(getCommonName(product: self, toDisplay: false).lowercased().smartContains(lowercaseSearchText) || getCommonName(product: self, toDisplay: true).lowercased().contains(lowercaseSearchText) || uuid!.lowercased() == lowercaseSearchText || color!.lowercased().contains(lowercaseSearchText) || (comments ?? "").lowercased().contains(lowercaseSearchText) || (originalBands ?? "").lowercased().contains(lowercaseSearchText) || (processor ?? "").lowercased().contains(lowercaseSearchText) || (storage ?? "").lowercased().contains(lowercaseSearchText) ||  lowercaseSearchText == "yearacquired: " + String(yearAcquired ?? 2022) || lowercaseSearchText == "acquired: " + String(yearAcquired ?? 2022) || lowercaseSearchText == "activation lock: " + String(activationLock ?? false) || lowercaseSearchText == "icloud: " + String(activationLock ?? false) || lowercaseSearchText == "icloud lock: " + String(activationLock ?? false) || lowercaseSearchText == "activationlock: " + String(activationLock ?? false) || lowercaseSearchText == "icloudlock: " + String(activationLock ?? false) || (lowercaseSearchText.smartContains((storage ?? "").lowercased()) && lowercaseSearchText.contains(getCommonName(product: self, toDisplay: false).lowercased())))
        {
            return true
        }
        return false
    }
    
}

func getCommonHeaderName(product: ProductInfo, toDisplay: Bool) -> String
{
    if(product.type == DeviceType.Mac) {
        
        return "\(product.year ?? "Unknown Year") \(product.screenSize != nil ? "\(String(product.screenSize!))-inch": "")"
    }
    if(product.type == DeviceType.iPhone && toDisplay)
    {
        return product.storage ?? "Unknown Storage"
        
    }
    else if(product.type == DeviceType.iPad && toDisplay)
    {
        return "\(product.storage ?? "Unknown Storage") \(product.connectivity != nil ? product.connectivity!.id: "")"
        
    }
    else if(product.type == DeviceType.iPad && !toDisplay)
    {
        return "\(product.connectivity != nil ? product.connectivity!.id: "")"
        
    }
    else if(product.type == DeviceType.AppleWatch)
    {
        if(product.caseSize == nil && product.caseType == nil && product.watchConnectivity == nil)
        {
            return "Unknown Model"
        }
        if(product.watchConnectivity == WatchConnectivity.None) {
            return "\(product.caseSize != nil ? "\(String(product.caseSize!))mm": "Unknown Case Size") \(product.caseType != nil ? product.caseType!.id: "Unknown Case Type")"
        }
        return "\(product.caseSize != nil ? "\(String(product.caseSize!))mm": "Unknown Case Size") \(product.caseType != nil ? product.caseType!.id: "Unknown Case Type") \(product.watchConnectivity != nil ? product.watchConnectivity!.id: "Unknown Connectivity")"
    }
    else if(product.type == DeviceType.AirPods)
    {
        return (product.APCaseType != nil ? product.APCaseType!.id: "Unknown Case Type")
    }
    else if(product.type == DeviceType.AppleTV && toDisplay)
    {
       return product.storage ?? "Unknown Storage"
    }
    else if(product.type == DeviceType.iPod && toDisplay)
    {
        return product.storage ?? "Unknown Storage"
    }
    return ""
}

func getCommonName(product: ProductInfo, toDisplay: Bool) -> String
{
    var commonName: String = ""
    if(product.model != "Other" && product.model != "Earlier Models")
    {
        commonName += (product.model! + " ")
    }
    commonName += getCommonHeaderName(product: product, toDisplay: toDisplay)
    return commonName
    
}

func typeToRank(deviceType: String, key: String) -> Int
{
    let deviceTypeEnum = DeviceType(rawValue: deviceType)!
    if(deviceTypeEnum == DeviceType.iPhone){
        return (iPhoneModel(rawValue: key) ?? iPhoneModel.Other).asInt()
    }
    else if(deviceTypeEnum == DeviceType.iPad){
        return (iPadModel(rawValue: key) ?? iPadModel.Other).asInt()
    }
    else if(deviceTypeEnum == DeviceType.Mac){
        return (MacModel(rawValue: key) ?? MacModel.Other).asInt()
    }
    else if(deviceTypeEnum == DeviceType.AppleWatch){
        return (AppleWatchModel(rawValue: key) ?? AppleWatchModel.Other).asInt()
    }
    else if(deviceTypeEnum == DeviceType.AirPods){
        return (AirPodsModel(rawValue: key) ?? AirPodsModel.Other).asInt()
    }
    else if(deviceTypeEnum == DeviceType.AppleTV){
        return (AppleTVModel(rawValue: key) ?? AppleTVModel.Other).asInt()
    }
    else{
        return (iPodModel(rawValue: key) ?? iPodModel.Other).asInt()
    }
}

func getProductIcon(product: ProductInfo) -> String
{
    var icon: String
    if(product.type == DeviceType.iPhone){
        icon = (iPhoneModel(rawValue: product.model ?? "Other") ?? iPhoneModel.Other).getIcon()
    }
    else if(product.type == DeviceType.iPad){
        icon = (iPadModel(rawValue: product.model ?? "Other") ?? iPadModel.Other).getIcon()
    }
    else if(product.type == DeviceType.Mac){
        if(MacModel(rawValue: product.model ?? "Other/Earlier Models") != nil) {
            icon = MacModel(rawValue: product.model ?? "Other/Earlier Models")!.getIcon()
        }
        else {
            if(product.formFactor == FormFactor.Notebook) {
                icon = "laptopcomputer"
            }
            else if(product.formFactor == FormFactor.AllinOne) {
                icon = "desktopcomputer"
            }
            else {
                icon = "macmini"
            }
        }
    }
    else if(product.type == DeviceType.AppleWatch){
        icon = (AppleWatchModel(rawValue: product.model ?? "Other") ?? AppleWatchModel.Other).getIcon()
    }
    else if(product.type == DeviceType.AirPods){
        icon = (AirPodsModel(rawValue: product.model ?? "Other") ?? AirPodsModel.Other).getIcon()
    }
    else if(product.type == DeviceType.AppleTV){
        icon = (AppleTVModel(rawValue: product.model ?? "Other") ?? AppleTVModel.Other).getIcon()
    }
    else{
        icon = (iPodModel(rawValue: product.model ?? "Other") ?? iPodModel.Other).getIcon()
    }
    modelIcons[product.model ?? "Unknown Model"] = icon

    return icon
}

