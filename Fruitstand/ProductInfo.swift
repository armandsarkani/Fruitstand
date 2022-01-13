//
//  ProductInfo.swift
//  Fruitstand
//
//  Created by Armand Sarkani on 1/8/22.
//

import Foundation
import Combine

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
    
    // Model names for each device type
    var iPhoneModel: iPhoneModel?
    var iPadModel: iPadModel?
    var MacModel: MacModel?
    var AppleWatchModel: AppleWatchModel?
    var AirPodsModel: AirPodsModel?
    var AppleTVModel: AppleTVModel?
    var iPodModel: iPodModel?
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
    var storageType: StorageType?
    var memory: String?

    // Apple Watch only
    var caseType: WatchCaseType?
    var caseSize: Int?
    var watchConnectivity: WatchConnectivity?
    var originalBands: String?

    // Apple TV only
    var hasRemote: Bool? = false
    
    // AirPods only
    var AirPodsCaseType: AirPodsCaseType?
    
}

func getProductModel(product: ProductInfo) -> String
{
    var model: String
    if(product.type == DeviceType.iPhone){
        model = product.iPhoneModel!.rawValue
    }
    else if(product.type == DeviceType.iPad){
        model = product.iPadModel!.rawValue
    }
    else if(product.type == DeviceType.Mac){
        model = product.MacModel!.rawValue
    }
    else if(product.type == DeviceType.AppleWatch){
        model = product.AppleWatchModel!.rawValue
    }
    else if(product.type == DeviceType.AirPods){
        model = product.AirPodsModel!.rawValue
    }
    else if(product.type == DeviceType.AppleTV){
        model = product.AppleTVModel!.rawValue
    }
    else{
        model = product.iPodModel!.rawValue
    }
    return model
}

func getProductIcon(product: ProductInfo) -> String
{
    var model: String
    if(product.type == DeviceType.iPhone){
        model = product.iPhoneModel!.getIcon()
    }
    else if(product.type == DeviceType.iPad){
        model = product.iPadModel!.getIcon()
    }
    else if(product.type == DeviceType.Mac){
        model = product.MacModel!.getIcon()
    }
    else if(product.type == DeviceType.AppleWatch){
        model = product.AppleWatchModel!.getIcon()
    }
    else if(product.type == DeviceType.AirPods){
        model = product.AirPodsModel!.getIcon()
    }
    else if(product.type == DeviceType.AppleTV){
        model = product.AppleTVModel!.getIcon()
    }
    else{
        model = product.iPodModel!.getIcon()
    }
    return model
}

class ProductInfoManager: ObservableObject
{
    var uuid: String
    @Published var product: ProductInfo!
    {
        didSet
        {
            UserDefaults.standard.setCodableObject(product, forKey: uuid) // once product variable modified by view, set UserDefaults
            
        }
    }
    init(uuid: String)
    {
        self.uuid = uuid
        if((UserDefaults.standard.getCodableObject(dataType: ProductInfo.self, key: uuid)) != nil)
        {
            self.product = UserDefaults.standard.getCodableObject(dataType: ProductInfo.self, key: uuid)
        }
    }
}
