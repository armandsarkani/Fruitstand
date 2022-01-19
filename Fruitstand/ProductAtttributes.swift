//
//  ProductAtttributes.swift
//  Fruitstand
//
//  Created by Armand Sarkani on 1/8/22.
//

// This module is responsible for the enum types used in the product model.

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
    case None
    var id: String { self.rawValue }
}

enum FormFactor: String, CaseIterable, Identifiable, Codable {
    case Notebook
    case Desktop
    case AllinOne = "All-in-one"
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
    case Wired = "Wired Charging Case"
    case Wireless = "Wireless Charging Case"
    case MagSafe = "MagSafe Case"
    case Smart = "Smart Case"
    case Other
    var id: String { self.rawValue }
}


enum iPhoneModel: String, CaseIterable, Identifiable, Codable {
    // Models
    case _1stGen = "iPhone (1st gen.)"
    case _3G = "iPhone 3G"
    case _3GS = "iPhone 3GS"
    case _4 = "iPhone 4"
    case _4s = "iPhone 4s"
    case _5 = "iPhone 5"
    case _5c = "iPhone 5c"
    case _5s = "iPhone 5s"
    case _6 = "iPhone 6"
    case _6Plus = "iPhone 6 Plus"
    case _6s = "iPhone 6s"
    case _6sPlus = "iPhone 6s Plus"
    case _SE1stGen = "iPhone SE (1st gen.)"
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
    case _SE2ndGen = "iPhone SE (2nd gen.)"
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
    case _1stGen = "iPad (1st gen.)"
    case _2ndGen = "iPad (2nd gen.)"
    case _3rdGen = "iPad (3rd gen.)"
    case _4thGen = "iPad (4th gen.)"
    case _5thGen = "iPad (5th gen.)"
    case _6thGen = "iPad (6th gen.)"
    case _7thGen = "iPad (7th gen.)"
    case _8thGen = "iPad (8th gen.)"
    case _9thGen = "iPad (9th gen.)"
    case _Air1stGen = "iPad Air (1st gen.)"
    case _Air2ndGen = "iPad Air (2nd gen.)"
    case _Air3rdGen = "iPad Air (3rd gen.)"
    case _Air4thGen = "iPad Air (4th gen.)" // no home button
    case _Mini1stGen = "iPad mini (1st gen.)"
    case _Mini2ndGen = "iPad mini (2nd gen.)"
    case _Mini3rdGen = "iPad mini (3rd gen.)"
    case _Mini4thGen = "iPad mini (4th gen.)"
    case _Mini5thGen = "iPad mini (5th gen.)"
    case _Mini6thGen = "iPad mini (6th gen.)" // no home button
    case _Pro9_7 = "iPad Pro 9.7-inch"
    case _Pro_12_9_1stGen = "iPad Pro 12.9-inch (1st gen.)"
    case _Pro10_5 = "iPad Pro 10.5-inch"
    case _Pro_12_9_2ndGen = "iPad Pro 12.9-inch (2nd gen.)"
    case _Pro_11_1stGen = "iPad Pro 11-inch (1st gen.)" // no home button (all the way down)
    case _Pro_12_9_3rdGen = "iPad Pro 12.9-inch (3rd gen.)"
    case _Pro_11_2ndGen = "iPad Pro 11-inch (2nd gen.)"
    case _Pro_12_9_4thGen = "iPad Pro 12.9-inch (4th gen.)"
    case _Pro_11_3rdGen = "iPad Pro 11-inch (3rd gen.)"
    case _Pro_12_9_5thGen = "iPad Pro 12.9-inch (5th gen.)"
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
    case _MBPRetina = "MacBook Pro (Retina)"
    case _MBPRetinaTB = "MacBook Pro (Retina, Thunderbolt)"
    case _MBPRetinaAS = "MacBook Pro (Apple Silicon)"
    case _MBA = "MacBook Air (non-Retina)"
    case _MBARetina = "MacBook Air (Retina)"
    case _MBAAS = "MacBook Air (Apple Silicon)"
    case _MB = "MacBook (polycarbonate)"
    case _MBUnibody = "MacBook (unibody)"
    case _MBAl = "MacBook (aluminum, unibody)"
    case _MB12 = "MacBook (Retina)"
    case _iMac = "iMac (Intel)"
    case _iMacAS = "iMac (Apple Silicon)"
    case _iMacPro = "iMac Pro"
    case _MacMini = "Mac mini (Intel)"
    case _MacMiniAS = "Mac mini (Apple Silicon)"
    case _MacPro = "Mac Pro"
    case Other = "Other"
    case Earlier = "Earlier Models"
    
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
    case _S0 = "Apple Watch (1st gen.)"
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
    case _1stGen = "AirPods (1st gen.)"
    case _2ndGen = "AirPods (2nd gen.)"
    case _3rdGen = "AirPods (3rd gen.)"
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
    case _1stGen = "Apple TV (1st gen.)"
    case _2ndGen = "Apple TV (2nd gen.)"
    case _3rdGen = "Apple TV (3rd gen.)"
    case _HD = "Apple TV HD"
    case _4K1stGen = "Apple TV 4K (1st gen.)"
    case _4K2ndGen = "Apple TV 4K (2nd gen.)"
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
    case _1stGen = "iPod (1st gen.)"
    case _2ndGen = "iPod (2nd gen.)"
    case _3rdGen = "iPod (3rd gen.)"
    case _4thGen = "iPod (4th gen.)"
    case _4thGenHP = "iPod + HP (4th gen.)"
    case _4thGenPhoto = "iPod (4th gen., photo)"
    case _4thGenPhotoHP = "iPod + HP (4th gen., photo)"
    case _U2 = "iPod U2"
    case _U2Photo = "iPod U2 (photo)"
    case _5thGen = "iPod 5th gen."
    case _U25thGen = "iPod U2 (5th gen.)"
    case _Classic = "iPod classic"
    case _Classic09 = "iPod classic (Late 2009)"
    case _Mini1stGen = "iPod mini (1st gen.)"
    case _Mini1stGenHP =  "iPod mini + HP (1st gen.)"
    case _Mini2ndGen = "iPod mini (2nd gen.)"
    case _Mini2ndGenHP = "iPod mini + HP (2nd gen.)"
    case _Nano1stGen = "iPod nano (1st gen.)"
    case _Nano2ndGen = "iPod nano (2nd gen.)"
    case _Nano3rdGen = "iPod nano (3rd gen.)"
    case _Nano4thGen = "iPod nano (4th gen.)"
    case _Nano5thGen = "iPod nano (5th gen.)"
    case _Nano6thGen = "iPod nano (6th gen.)"
    case _Nano7thGen = "iPod nano (7th gen.)"
    case _Shuffle1stGen = "iPod shuffle (1st gen.)"
    case _Shuffle1stGenHP = "iPod shuffle + HP (1st gen.)"
    case _Shuffle2ndGen = "iPod shuffle (2nd gen.)"
    case _Shuffle3rdGen = "iPod shuffle (3rd gen.)"
    case _Shuffle4thGen = "iPod shuffle (4th gen.)"
    case _Touch1stGen = "iPod touch (1st gen.)"
    case _Touch2ndGen = "iPod touch (2nd gen.)"
    case _Touch3rdGen = "iPod touch (3rd gen.)"
    case _Touch4thGen = "iPod touch (4th gen.)"
    case _Touch5thGen = "iPod touch (5th gen.)"
    case _Touch6thGen = "iPod touch (6th gen.)"
    case _Touch7thGen = "iPod touch (7th gen.)"
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



