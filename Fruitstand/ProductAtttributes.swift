//
//  ProductAtttributes.swift
//  Fruitstand
//
//  Created by Armand Sarkani on 1/8/22.
//

import Foundation
import Combine

enum DeviceType: String, CaseIterable, Identifiable, Codable {
    case Mac
    case iPhone
    case iPad
    case AppleWatch = "Apple Watch"
    case AirPods
    case AppleTV = "Apple TV"
    case iPod
    
    var id: String { self.rawValue }
    
}

enum WorkingStatus: String, CaseIterable, Identifiable, Codable {
    case Working
    case MostlyWorking = "Mostly Working"
    case NotWorking = "Not Working"
    
    var id: String { self.rawValue }
}

enum Condition: String, CaseIterable, Identifiable, Codable {
    case Excellent
    case Good
    case Fair
    case Poor
    case Incomplete
    var id: String { self.rawValue }
}

enum AcquiredAs: String, CaseIterable, Identifiable, Codable {
    case New
    case Used
    case Unopened
    var id: String { self.rawValue }
}

enum ESNStatus: String, CaseIterable, Identifiable, Codable {
    case Clean
    case Bad
    case Unknown
    var id: String { self.rawValue }
}

enum CarrierLockStatus: String, CaseIterable, Identifiable, Codable {
    case Unlocked
    case Locked
    case Unknown
    var id: String { self.rawValue }
}

enum iPadConnectivity: String, CaseIterable, Identifiable, Codable {
    case WiFi = "Wi-Fi"
    case Cellular = "Wi-Fi + Cellular"
    var id: String { self.rawValue }
}

enum WatchConnectivity: String, CaseIterable, Identifiable, Codable {
    case GPS
    case Cellular = "GPS + Cellular"
    var id: String { self.rawValue }
}

enum FormFactor: String, CaseIterable, Identifiable, Codable {
    case Notebook
    case Desktop
    var id: String { self.rawValue }
}

enum StorageType: String, CaseIterable, Identifiable, Codable {
    case HDD = "Hard drive"
    case SSD
    case None
    var id: String { self.rawValue }
}

enum Warranty: String, CaseIterable, Identifiable, Codable {
    case AppleCarePlus = "AppleCare+"
    case Limited = "Limited Warranty"
    case Expired
    var id: String { self.rawValue }
}

enum WatchCaseType: String, CaseIterable, Identifiable, Codable {
    case Aluminum
    case Steel = "Stainless Steel"
    case Ceramic
    case Titanium
    case Gold
    case Other
    var id: String { self.rawValue }
}

enum AirPodsCaseType: String, CaseIterable, Identifiable, Codable {
    case Wired = "Charging Case (wired)"
    case Wireless = "Wireless Charging Case"
    case MagSafe = "MagSafe Wireless Charging Case"
    case Smart = "Smart Case (AirPods Max)"
    case Other
    var id: String { self.rawValue }
}


enum iPhoneModel: String, CaseIterable, Identifiable, Codable {
    // Models
    case _1stGen = "iPhone (1st generation)"
    case _3G = "iPhone 3G"
    case _3GS = "iPhone 3GS"
    case _4 = "iPhone 4"
    case _5 = "iPhone 5"
    case _5c = "iPhone 5c"
    case _5s = "iPhone 5s"
    case _6 = "iPhone 6"
    case _6Plus = "iPhone 6 Plus"
    case _6s = "iPhone 6s"
    case _6sPlus = "iPhone 6s Plus"
    case _SE1stGen = "iPhone SE (1st generation)"
    case _7 = "iPhone 7"
    case _7Plus = "iPhone 7 Plus"
    case _8 = "iPhone 8"
    case _8Plus = "iPhone 8 Plus"
    case _X = "iPhone X"
    case _XR = "iPhone XR"
    case _XS = "iPhone XS"
    case _XSMax = "iPhone XS Max"
    case _11 = "iPhone 11"
    case _11Pro = "iPhone 11 Pro"
    case _11ProMax = "iPhone 11 Pro Max"
    case _SE2ndGen = "iPhone SE (2nd generation)"
    case _12Mini = "iPhone 12 mini"
    case _12 = "iPhone 12"
    case _12Pro = "iPhone 12 Pro"
    case _12ProMax = "iPhone 12 Pro Max"
    case _13Mini = "iPhone 13 mini"
    case _13 = "iPhone 13"
    case _13Pro = "iPhone 13 Pro"
    case _13ProMax = "iPhone 13 Pro Max"
    case Other = "Other"

    var id: String { self.rawValue }
    static var asArray: [iPhoneModel] {return self.allCases}
    func asInt() -> Int {
         return iPhoneModel.asArray.firstIndex(of: self)!
    }
    func getIcon() -> String {
        if(self.asInt() < iPhoneModel._X.asInt() || self == iPhoneModel._SE2ndGen)
        {
            return "iphone.homebutton"
        }
        else
        {
            return "iphone"
        }
    }
}

enum iPadModel: String, CaseIterable, Identifiable, Codable {
    // Models
    case _1stGen = "iPad (1st generation)"
    case _2ndGen = "iPad (2nd generation)"
    case _3rdGen = "iPad (3rd generation)"
    case _4thGen = "iPad (4th generation)"
    case _5thGen = "iPad (5th generation)"
    case _6thGen = "iPad (6th generation)"
    case _7thGen = "iPad (7th generation)"
    case _8thGen = "iPad (8th generation)"
    case _9thGen = "iPad (9th generation)"
    case _Air1stGen = "iPad Air (1st generation)"
    case _Air2ndGen = "iPad Air (2nd generation)"
    case _Air3rdGen = "iPad Air (3rd generation)"
    case _Air4thGen = "iPad Air (4th generation)" // no home button
    case _Mini1stGen = "iPad mini (1st generation)"
    case _Mini2ndGen = "iPad mini (2nd generation)"
    case _Mini3rdGen = "iPad mini (3rd generation)"
    case _Mini4thGen = "iPad mini (4th generation)"
    case _Mini5thGen = "iPad mini (5th generation)"
    case _Mini6thGen = "iPad mini (6th generation)" // no home button
    case _Pro9_7 = "iPad Pro 9.7-inch"
    case _Pro_12_9_1stGen = "iPad Pro 12.9-inch (1st generation)"
    case _Pro10_5 = "iPad Pro 10.5-inch"
    case _Pro_12_9_2ndGen = "iPad Pro 12.9-inch (2nd generation)"
    case _Pro_11_1stGen = "iPad Pro 11-inch (1st generation)" // no home button (all the way down)
    case _Pro_12_9_3rdGen = "iPad Pro 12.9-inch (3rd generation)"
    case _Pro_11_2ndGen = "iPad Pro 11-inch (2nd generation)"
    case _Pro_12_9_4thGen = "iPad Pro 12.9-inch (4th generation)"
    case _Pro_11_3rdGen = "iPad Pro 11-inch (3rd generation)"
    case _Pro_12_9_5thGen = "iPad Pro 12.9-inch (5th generation)"
    case Other = "Other"
    
    var id: String { self.rawValue }
    static var asArray: [iPadModel] {return self.allCases}
    func asInt() -> Int {
         return iPadModel.asArray.firstIndex(of: self)!
    }
    func getIcon() -> String {
        if(self.asInt() <= iPadModel._Air3rdGen.asInt() || (self.asInt() >= iPadModel._Mini1stGen.asInt() && self.asInt() <= iPadModel._Mini5thGen.asInt()) || (self.asInt() >= iPadModel._Pro9_7.asInt() && self.asInt() <= iPadModel._Pro_12_9_2ndGen.asInt()))
        {
            return "ipad.homebutton"
        }
        else
        {
            return "ipad"
        }
    }

}

enum MacModel: String, CaseIterable, Identifiable, Codable {
    // Models
    case _MBP = "MacBook Pro (original)"
    case _MBPUnibody = "MacBook Pro (unibody)"
    case _MBPRetina = "MacBook Pro (Retina, original)"
    case _MBPRetinaTB = "MacBook Pro (Retina, Thunderbolt)"
    case _MBPRetinaAS = "MacBook Pro (Apple Silicon)"
    case _MBA = "MacBook Air (non-Retina)"
    case _MBARetina = "MacBook Air (Retina)"
    case _MBAAS = "MacBook Air (Apple Silicon)"
    case _MB = "MacBook (polycarbonate)"
    case _MBUnibody = "MacBook (polycarbonate, unibody)"
    case _MBAl = "MacBook (aluminum, unibody)"
    case _MB12 = "MacBook (Retina)"
    case _iMac = "iMac (Intel)"
    case _iMacAS = "iMac (Apple Silicon)"
    case _iMacPro = "iMac Pro"
    case _MacMini = "Mac mini (Intel)"
    case _MacMiniAS = "Mac mini (Apple Silicon)"
    case _MacPro = "Mac Pro"
    case Other = "Other"
    case Earlier = "Earlier Model (PowerPC, 68k)"
    
    var id: String { self.rawValue }
    static var asArray: [MacModel] {return self.allCases}
    func asInt() -> Int {
         return MacModel.asArray.firstIndex(of: self)!
    }
    func getIcon() -> String {
        if(self.asInt() < MacModel._iMac.asInt())
        {
            return "laptopcomputer"
        }
        else if(self.asInt() >= MacModel._iMac.asInt() && self.asInt() <= MacModel._iMacPro.asInt())
        {
            return "desktopcomputer"
        }
        else if(self.asInt() >= MacModel._MacMini.asInt() && self.asInt() <= MacModel._MacMiniAS.asInt())
        {
            return "macmini"
        }
        else if(self.asInt() >= MacModel._MacPro.asInt() && self.asInt() < MacModel.Other.asInt())
        {
            return "macpro.gen3"
        }
        else
        {
            return "desktopcomputer"
        }
    }
}

enum AppleWatchModel: String, CaseIterable, Identifiable, Codable {
    // Models
    case _S0 = "Apple Watch (1st generation)"
    case _S1 = "Apple Watch Series 1"
    case _S2 = "Apple Watch Series 2"
    case _S3 = "Apple Watch Series 3"
    case _S4 = "Apple Watch Series 4"
    case _S5 = "Apple Watch Series 5"
    case _S6 = "Apple Watch Series 6"
    case _SE = "Apple Watch SE"
    case _S7 = "Apple Watch Series 7"
    case Other = "Other"
    
    var id: String { self.rawValue }
    static var asArray: [AppleWatchModel] {return self.allCases}
    func asInt() -> Int {
         return AppleWatchModel.asArray.firstIndex(of: self)!
    }
    func getIcon() -> String {
        return "applewatch"
    }
    
}
enum AirPodsModel: String, CaseIterable, Identifiable, Codable {
    // Models
    case _1stGen = "AirPods (1st generation)"
    case _2ndGen = "AirPods (2nd generation)"
    case _3rdGen = "AirPods (3rd generation)"
    case _Pro = "AirPods Pro"
    case _Max = "AirPods Max"
    case Other = "Other"
    
    var id: String { self.rawValue }
    static var asArray: [AirPodsModel] {return self.allCases}
    func asInt() -> Int {
         return AirPodsModel.asArray.firstIndex(of: self)!
    }
    func getIcon() -> String {
        if(self.asInt() < AirPodsModel._3rdGen.asInt())
        {
            return "airpods"
        }
        else if(self.asInt() >= AirPodsModel._3rdGen.asInt() && self.asInt() < AirPodsModel._Pro.asInt())
        {
            return "airpods.gen3"
        }
        else if(self.asInt() >= AirPodsModel._Max.asInt() && self.asInt() < AirPodsModel.Other.asInt())
        {
            return "airpodsmax"
        }
        else
        {
            return "airpodspro"
        }
    }
}

enum AppleTVModel: String, CaseIterable, Identifiable, Codable {
    // Models
    case _1stGen = "Apple TV (1st generation)"
    case _2ndGen = "Apple TV (2nd generation)"
    case _3rdGen = "Apple TV (3rd generation)"
    case _HD = "Apple TV HD"
    case _4K1stGen = "Apple TV 4K (1st generation)"
    case _4K2ndGen = "Apple TV 4K (2nd generation)"
    case Other = "Other"
    
    var id: String { self.rawValue }
    static var asArray: [AppleTVModel] {return self.allCases}
    func asInt() -> Int {
         return AppleTVModel.asArray.firstIndex(of: self)!
    }
    func getIcon() -> String {
        return "appletv.fill"
    }
}

enum iPodModel: String, CaseIterable, Identifiable, Codable {
    // Models
    case _1stGen = "iPod (1st generation)"
    case _2ndGen = "iPod (2nd generation)"
    case _3rdGen = "iPod (3rd generation)"
    case _4thGen = "iPod (4th generation)"
    case _4thGenHP = "iPod (4th generation, HP)"
    case _4thGenPhoto = "iPod (4th generation, photo)"
    case _4thGenPhotoHP = "iPod (4th generation, HP, photo)"
    case _U2 = "iPod U2"
    case _U2Photo = "iPod U2 (photo)"
    case _5thGen = "iPod 5th generation"
    case _U25thGen = "iPod U2 (5th generation)"
    case _Classic = "iPod classic"
    case _Classic09 = "iPod classic (Late 2009)"
    case _Mini1stGen = "iPod mini (1st generation)"
    case _Mini1stGenHP =  "iPod mini + HP (1st generation)"
    case _Mini2ndGen = "iPod mini (2nd generation)"
    case _Mini2ndGenHP = "iPod mini + HP (2nd generation)"
    case _Nano1stGen = "iPod nano (1st generation)"
    case _Nano2ndGen = "iPod nano (2nd generation)"
    case _Nano3rdGen = "iPod nano (3rd generation)"
    case _Nano4thGen = "iPod nano (4th generation)"
    case _Nano5thGen = "iPod nano (5th generation)"
    case _Nano6thGen = "iPod nano (6th generation)"
    case _Nano7thGen = "iPod nano (7th generation)"
    case _Shuffle1stGen = "iPod shuffle (1st generation)"
    case _Shuffle1stGenHP = "iPod shuffle + HP (1st generation)"
    case _Shuffle2ndGen = "iPod shuffle (2nd generation)"
    case _Shuffle3rdGen = "iPod shuffle (3rd generation)"
    case _Shuffle4thGen = "iPod shuffle (4th generation)"
    case _Touch1stGen = "iPod touch (1st generation)"
    case _Touch2ndGen = "iPod touch (2nd generation)"
    case _Touch3rdGen = "iPod touch (3rd generation)"
    case _Touch4thGen = "iPod touch (4th generation)"
    case _Touch5thGen = "iPod touch (5th generation)"
    case _Touch6thGen = "iPod touch (6th generation)"
    case _Touch7thGen = "iPod touch (7th generation)"
    case Other = "Other"
    
    var id: String { self.rawValue }
    static var asArray: [iPodModel] {return self.allCases}
    func asInt() -> Int {
         return iPodModel.asArray.firstIndex(of: self)!
    }
    func getIcon() -> String {
        if(self == iPodModel._Shuffle1stGen || self == iPodModel._Shuffle1stGenHP)
        {
            return "ipodshuffle.gen1"
        }
        else if(self == iPodModel._Shuffle2ndGen)
        {
            return "ipodshuffle.gen2"
        }
        else if(self == iPodModel._Shuffle3rdGen)
        {
            return "ipodshuffle.gen3"
        }
        else if(self == iPodModel._Shuffle4thGen)
        {
            return "ipodshuffle.gen4"
        }
        else if(self.asInt() >= iPodModel._Touch1stGen.asInt() && self.asInt() < iPodModel.Other.asInt())
        {
            return "ipodtouch"
        }
        else
        {
            return "ipod"
        }
    }
}



