//
//  CSVcollectionModel.swift
//  Fruitstand
//
//  Created by Armand Sarkani on 1/19/22.
//

import Foundation
import SwiftCSV
import CSV
import SwiftUI
import UniformTypeIdentifiers

class CSVCollectionModel
{
    var collectionModel: CollectionModel
    let boolToString: [Bool: String] = [true: "Yes", false: "No"]
    let stringToBool: [String: Bool] = ["Yes": true, "No": false]
    init(collectionModel: CollectionModel)
    {
        self.collectionModel = collectionModel
    }
    func loadImportCollection(CSVStrings: [DeviceType: String])
    {
        for deviceType in CSVStrings.keys
        {
            let dictionary = loadCSVStringToDictionary(CSVString: CSVStrings[deviceType]!)
            loadProductsFromCSV(productData: dictionary, deviceType: deviceType)
        }
    }
    func loadSampleCollection()
    {
        let iPhoneData = loadCSVToDictionary(forResource: "SampleCollection/iPhone")
        let iPadData = loadCSVToDictionary(forResource: "SampleCollection/iPad")
        let MacData = loadCSVToDictionary(forResource: "SampleCollection/Mac")
        let AppleWatchData = loadCSVToDictionary(forResource: "SampleCollection/AppleWatch")
        let AirPodsData = loadCSVToDictionary(forResource: "SampleCollection/AirPods")
        let AppleTVData = loadCSVToDictionary(forResource: "SampleCollection/AppleTV")
        let iPodData = loadCSVToDictionary(forResource: "SampleCollection/iPod")
        loadProductsFromCSV(productData: iPhoneData, deviceType: DeviceType.iPhone)
        loadProductsFromCSV(productData: iPadData, deviceType: DeviceType.iPad)
        loadProductsFromCSV(productData: MacData, deviceType: DeviceType.Mac)
        loadProductsFromCSV(productData: AppleWatchData, deviceType: DeviceType.AppleWatch)
        loadProductsFromCSV(productData: AirPodsData, deviceType: DeviceType.AirPods)
        loadProductsFromCSV(productData: AppleTVData, deviceType: DeviceType.AppleTV)
        loadProductsFromCSV(productData: iPodData, deviceType: DeviceType.iPod)
        
    }

    func loadProductsFromCSV(productData: [[String:String]], deviceType: DeviceType)
    {
        var products: [ProductInfo] = []
        for element in productData
        {
            var product: ProductInfo = ProductInfo(type: deviceType, color: element["Color"] ?? nil, workingStatus: WorkingStatus(rawValue: element["Working Status"] ?? ""), estimatedValue: Int(element["Estimated Value"] ?? ""), condition: Condition(rawValue: element["Condition"] ?? ""), acquiredAs: AcquiredAs(rawValue: element["Acquired As"] ?? ""), physicalDamage: stringToBool[element["Physical Damage"] ?? "No"] ?? false, originalBox: stringToBool[element["Original Box"] ?? "No"] ?? false, warranty: Warranty(rawValue: element["Warranty"] ?? ""), yearAcquired: Int(element["Year Acquired"] ?? ""), comments: (element["Comments"] != "" ? element["Comments"]: nil), storage: element["Storage"] ?? nil, activationLock: stringToBool[element["Activation Lock"] ?? "No"] ?? false, carrier: element["Carrier"] ?? nil, ESNStatus: ESNStatus(rawValue: element["ESN Status"] ?? ""), carrierLockStatus: CarrierLockStatus(rawValue: element["Carrier Lock Status"] ?? ""), connectivity: iPadConnectivity(rawValue: element["iPad Connectivity"] ?? ""), year: element["Year"] ?? nil, formFactor: FormFactor(rawValue: element["Form Factor"] ?? ""), screenSize: Int(element["Screen Size"] ?? ""), processor: element["Processor"] ?? nil, memory: element["Memory"] ?? nil, caseType: WatchCaseType(rawValue: element["Case Type"] ?? ""), caseSize: Int(element["Case Size"] ?? ""), watchConnectivity: WatchConnectivity(rawValue: element["Watch Connectivity"] ?? ""), originalBands: element["Original Bands"] ?? nil, hasRemote: stringToBool[element["Has Remote"] ?? "No"] ?? false, APCaseType: AirPodsCaseType(rawValue: element["AirPods Case"] ?? ""))
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
            products.append(product)
        }
        collectionModel.saveMultipleProducts(products: &products)
            
    }

    func loadCSVToDictionary(forResource: String) -> [[String: String]]
    {
        do {
            // From a file (with errors)
            let csvFile: SwiftCSV.CSV = try SwiftCSV.CSV(url: Bundle.main.url(forResource: forResource, withExtension: "csv")!)
            return csvFile.namedRows
        }
        catch {
            print("Could not load file")
            return [[:]]
        }
    }
    
    func loadCSVStringToDictionary(CSVString: String) -> [[String: String]]
    {
        let csvFile: SwiftCSV.CSV = try! SwiftCSV.CSV(string: CSVString)
        print(csvFile.namedRows)
        return csvFile.namedRows
    }
    
    func loadCSVToString(forResource: String) -> String {
        if let filepath = Bundle.main.path(forResource: forResource, ofType: "csv") {
            do {
                let contents = try String(contentsOfFile: filepath)
                return contents
            } catch {
                return ""
                // contents could not be loaded
            }
        } else {
            return ""
            // example.txt not found!
        }
    }
    func getCSVFiles() -> [CSVFile]
    {
        var CSVFileArray: [CSVFile] = []
        CSVFileArray.append(CSVFile(fileData: getiPhoneCollectionAsCSVString(), fileName: "iPhone"))
        CSVFileArray.append(CSVFile(fileData: getiPadCollectionAsCSVString(), fileName: "iPad"))
        CSVFileArray.append(CSVFile(fileData: getMacCollectionAsCSVString(), fileName: "Mac"))
        CSVFileArray.append(CSVFile(fileData: getAppleWatchCollectionAsCSVString(), fileName: "AppleWatch"))
        CSVFileArray.append(CSVFile(fileData: getAirPodsCollectionAsCSVString(), fileName: "AirPods"))
        CSVFileArray.append(CSVFile(fileData: getAppleTVCollectionAsCSVString(), fileName: "AppleTV"))
        CSVFileArray.append(CSVFile(fileData: getiPodCollectionAsCSVString(), fileName: "iPod"))
        return CSVFileArray
    }
    func getiPhoneCollectionAsCSVString() -> String
    {
        let csv = try! CSVWriter(stream: .toMemory())
        try! csv.write(row: ["Model","Color","Year Acquired","Estimated Value","Working Status","Condition","Acquired As","Warranty","Physical Damage","Original Box","Storage","Carrier","ESN Status","Carrier Lock Status","Activation Lock","Comments"])
        for product in collectionModel.collection[DeviceType.iPhone]!
        {
            csv.beginNewRow()
            try! csv.write(row: ["\(((product.model! != "Other") ? product.model!: product.otherModel!))", "\(product.color ?? "")", "\(product.yearAcquired != nil ? String(product.yearAcquired!): "")", "\(product.estimatedValue != nil ? String(product.estimatedValue!): "")", "\(product.workingStatus != nil ? product.workingStatus!.id: "")", "\(product.condition != nil ? product.condition!.id: "")", "\(product.acquiredAs != nil ? product.acquiredAs!.id: "")", "\(product.warranty != nil ? product.warranty!.id: "")", "\(boolToString[product.physicalDamage ?? false]!)", "\(boolToString[product.originalBox ?? false]!)", "\(product.storage ?? "")", "\(product.carrier ?? "")", "\(product.ESNStatus != nil ? product.ESNStatus!.id: "")", "\(product.carrierLockStatus != nil ? product.carrierLockStatus!.id: "")", "\(boolToString[product.activationLock ?? false]!)", "\(product.comments ?? "")"])
            
        }

        let csvData = csv.stream.property(forKey: .dataWrittenToMemoryStreamKey) as! Data
        let csvString = String(data: csvData, encoding: .utf8)!
        return csvString

    }
    func getiPadCollectionAsCSVString() -> String
    {
        let csv = try! CSVWriter(stream: .toMemory())
        try! csv.write(row: ["Model","Color","Year Acquired","Estimated Value","Working Status","Condition","Acquired As","Warranty","Physical Damage","Original Box","Storage", "iPad Connectivity", "Activation Lock","Comments"])
        for product in collectionModel.collection[DeviceType.iPad]!
        {
            csv.beginNewRow()
            try! csv.write(row: ["\(((product.model! != "Other") ? product.model!: product.otherModel!))", "\(product.color ?? "")", "\(product.yearAcquired != nil ? String(product.yearAcquired!): "")", "\(product.estimatedValue != nil ? String(product.estimatedValue!): "")", "\(product.workingStatus != nil ? product.workingStatus!.id: "")", "\(product.condition != nil ? product.condition!.id: "")", "\(product.acquiredAs != nil ? product.acquiredAs!.id: "")", "\(product.warranty != nil ? product.warranty!.id: "")", "\(boolToString[product.physicalDamage ?? false]!)", "\(boolToString[product.originalBox ?? false]!)", "\(product.storage ?? "")", "\(product.connectivity != nil ? product.connectivity!.id: "")", "\(boolToString[product.activationLock ?? false]!)", "\(product.comments ?? "")"])
            
        }

        let csvData = csv.stream.property(forKey: .dataWrittenToMemoryStreamKey) as! Data
        let csvString = String(data: csvData, encoding: .utf8)!
        return csvString


    }
    func getMacCollectionAsCSVString() -> String
    {
        let csv = try! CSVWriter(stream: .toMemory())
        try! csv.write(row: ["Model","Color","Year Acquired","Estimated Value","Working Status","Condition","Acquired As","Warranty","Physical Damage","Original Box","Form Factor", "Screen Size", "Year", "Processor", "Storage", "Memory","Activation Lock","Comments"])
        for product in collectionModel.collection[DeviceType.Mac]!
        {
            csv.beginNewRow()
            try! csv.write(row: ["\(((product.model! != "Other" && product.model! != "Earlier Models") ? product.model!: product.otherModel!))", "\(product.color ?? "")", "\(product.yearAcquired != nil ? String(product.yearAcquired!): "")", "\(product.estimatedValue != nil ? String(product.estimatedValue!): "")", "\(product.workingStatus != nil ? product.workingStatus!.id: "")", "\(product.condition != nil ? product.condition!.id: "")", "\(product.acquiredAs != nil ? product.acquiredAs!.id: "")", "\(product.warranty != nil ? product.warranty!.id: "")", "\(boolToString[product.physicalDamage ?? false]!)", "\(boolToString[product.originalBox ?? false]!)", "\(product.formFactor != nil ? product.formFactor!.id: "")", "\(product.screenSize != nil ? String(product.screenSize!): "")", "\(product.year ?? "")", "\(product.processor ?? "")", "\(product.storage ?? "")", "\(product.memory ?? "")", "\(boolToString[product.activationLock ?? false]!)", "\(product.comments ?? "")"])
            
        }

        let csvData = csv.stream.property(forKey: .dataWrittenToMemoryStreamKey) as! Data
        let csvString = String(data: csvData, encoding: .utf8)!
        return csvString

    }
    func getAppleWatchCollectionAsCSVString() -> String
    {
        let csv = try! CSVWriter(stream: .toMemory())
        try! csv.write(row: ["Model","Color","Year Acquired","Estimated Value","Working Status","Condition","Acquired As","Warranty","Physical Damage","Original Box", "Case Size", "Original Bands", "Case Type", "Watch Connectivity", "Activation Lock", "Comments"])
        for product in collectionModel.collection[DeviceType.AppleWatch]!
        {
            csv.beginNewRow()
            try! csv.write(row: ["\(((product.model! != "Other") ? product.model!: product.otherModel!))", "\(product.color ?? "")", "\(product.yearAcquired != nil ? String(product.yearAcquired!): "")", "\(product.estimatedValue != nil ? String(product.estimatedValue!): "")", "\(product.workingStatus != nil ? product.workingStatus!.id: "")", "\(product.condition != nil ? product.condition!.id: "")", "\(product.acquiredAs != nil ? product.acquiredAs!.id: "")", "\(product.warranty != nil ? product.warranty!.id: "")", "\(boolToString[product.physicalDamage ?? false]!)", "\(boolToString[product.originalBox ?? false]!)", "\(product.caseSize != nil ? String(product.caseSize!): "")", "\(product.originalBands ?? "")", "\(product.caseType != nil ? product.caseType!.id: "")", "\(product.watchConnectivity != nil ? product.watchConnectivity!.id: "")", "\(boolToString[product.activationLock ?? false]!)", "\(product.comments ?? "")"])
            
        }

        let csvData = csv.stream.property(forKey: .dataWrittenToMemoryStreamKey) as! Data
        let csvString = String(data: csvData, encoding: .utf8)!
        return csvString

    }
    func getAppleTVCollectionAsCSVString() -> String
    {
        let csv = try! CSVWriter(stream: .toMemory())
        try! csv.write(row: ["Model","Color","Year Acquired","Estimated Value","Working Status","Condition","Acquired As","Warranty","Physical Damage","Original Box","Storage","Has Remote","Comments"])
        for product in collectionModel.collection[DeviceType.AppleTV]!
        {
            csv.beginNewRow()
            try! csv.write(row: ["\(((product.model! != "Other") ? product.model!: product.otherModel!))", "\(product.color ?? "")", "\(product.yearAcquired != nil ? String(product.yearAcquired!): "")", "\(product.estimatedValue != nil ? String(product.estimatedValue!): "")", "\(product.workingStatus != nil ? product.workingStatus!.id: "")", "\(product.condition != nil ? product.condition!.id: "")", "\(product.acquiredAs != nil ? product.acquiredAs!.id: "")", "\(product.warranty != nil ? product.warranty!.id: "")", "\(boolToString[product.physicalDamage ?? false]!)", "\(boolToString[product.originalBox ?? false]!)", "\(product.storage ?? "")", "\(boolToString[product.hasRemote ?? false]!)", "\(product.comments ?? "")"])
            
        }

        let csvData = csv.stream.property(forKey: .dataWrittenToMemoryStreamKey) as! Data
        let csvString = String(data: csvData, encoding: .utf8)!
        return csvString

    }
    func getAirPodsCollectionAsCSVString() -> String
    {
        let csv = try! CSVWriter(stream: .toMemory())
        try! csv.write(row: ["Model","Color","Year Acquired","Estimated Value","Working Status","Condition","Acquired As","Warranty","Physical Damage","Original Box", "AirPods Case","Comments"])
        for product in collectionModel.collection[DeviceType.AirPods]!
        {
            csv.beginNewRow()
            try! csv.write(row: ["\(((product.model! != "Other") ? product.model!: product.otherModel!))", "\(product.color ?? "")", "\(product.yearAcquired != nil ? String(product.yearAcquired!): "")", "\(product.estimatedValue != nil ? String(product.estimatedValue!): "")", "\(product.workingStatus != nil ? product.workingStatus!.id: "")", "\(product.condition != nil ? product.condition!.id: "")", "\(product.acquiredAs != nil ? product.acquiredAs!.id: "")", "\(product.warranty != nil ? product.warranty!.id: "")", "\(boolToString[product.physicalDamage ?? false]!)", "\(boolToString[product.originalBox ?? false]!)", "\(product.APCaseType != nil ? product.APCaseType!.id: "")", "\(product.comments ?? "")"])
            
        }

        let csvData = csv.stream.property(forKey: .dataWrittenToMemoryStreamKey) as! Data
        let csvString = String(data: csvData, encoding: .utf8)!
        return csvString

    }
    func getiPodCollectionAsCSVString() -> String
    {
        let csv = try! CSVWriter(stream: .toMemory())
        try! csv.write(row: ["Model","Color","Year Acquired","Estimated Value","Working Status","Condition","Acquired As","Warranty","Physical Damage","Original Box","Storage","Activation Lock","Comments"])
        for product in collectionModel.collection[DeviceType.iPod]!
        {
            csv.beginNewRow()
            try! csv.write(row: ["\(((product.model! != "Other") ? product.model!: product.otherModel!))", "\(product.color ?? "")", "\(product.yearAcquired != nil ? String(product.yearAcquired!): "")", "\(product.estimatedValue != nil ? String(product.estimatedValue!): "")", "\(product.workingStatus != nil ? product.workingStatus!.id: "")", "\(product.condition != nil ? product.condition!.id: "")", "\(product.acquiredAs != nil ? product.acquiredAs!.id: "")", "\(product.warranty != nil ? product.warranty!.id: "")", "\(boolToString[product.physicalDamage ?? false]!)", "\(boolToString[product.originalBox ?? false]!)", "\(product.storage ?? "")", "\(boolToString[product.activationLock ?? false]!)", "\(product.comments ?? "")"])
            
        }

        let csvData = csv.stream.property(forKey: .dataWrittenToMemoryStreamKey) as! Data
        let csvString = String(data: csvData, encoding: .utf8)!
        return csvString

    }

}

struct CSVFile: FileDocument {
    // tell the system we support only plain text
    static var readableContentTypes = [UTType.commaSeparatedText]
    static var writableContentTypes = [UTType.commaSeparatedText]

    // by default our document is empty
    var fileData = ""
    var fileName = ""

    // a simple initializer that creates new, empty documents
    init(fileData: String = "", fileName: String = "") {
        self.fileData = fileData
        self.fileName = fileName
    }

    // this initializer loads data that has been saved previously
    init(configuration: ReadConfiguration) throws {
        if let data = configuration.file.regularFileContents {
            fileData = String(decoding: data, as: UTF8.self)
        }
    }
    // this will be called when the system wants to write our data to disk
     func fileWrapper(configuration: WriteConfiguration) throws -> FileWrapper {
         let data = Data(fileData.utf8)
         let fileWrapper = FileWrapper(regularFileWithContents: data)
         fileWrapper.filename = fileName
         return fileWrapper
     }
}


