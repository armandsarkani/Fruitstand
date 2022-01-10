//
//  ProductAtttributes.swift
//  Fruitstand
//
//  Created by Armand Sarkani on 1/8/22.
//

import Foundation
import Combine
import CoreData

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
