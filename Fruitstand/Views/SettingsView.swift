//
//  SettingsView.swift
//  Fruitstand
//
//  Created by Armand Sarkani on 1/21/22.
//

import Foundation
import SwiftUI
import UniformTypeIdentifiers
import SwiftCSV
import AlertToast

enum FileError: Error {
    case fileNameError
    case collectionSizeError
    case decodeError
}

struct AlertInfo: Identifiable {

    enum AlertType {
        case importSuccessful
        case loadSampleCollectionSuccessful
        case fileNameError
        case collectionSizeError
        case decodeError
    }
    
    let id: AlertType
    let title: String
    let message: String
}



struct SettingsView: View {
    @EnvironmentObject var collectionModel: CollectionModel
    @Binding var showSettingsModalView: Bool
    @State private var noiCloudAccount: Bool = false
    @State private var showSyncToast: Bool = false
    @State private var isExporting: Bool = false
    @State private var isImporting: Bool = false
    @State private var alertInfo: AlertInfo?
    @State private var confirmationShown = false
    @EnvironmentObject var accentColor: AccentColor
    let appearances: [SwiftUI.ColorScheme] = [.light, .dark]
    @Environment(\.colorScheme) var colorScheme
    @Environment(\.isPresented) var presentation
    var body: some View {
        NavigationView {
            List
            {
                Section(header: Text("General").customSectionHeader())
                {
                    Button(action: {confirmationShown.toggle()}) {
                        Label("Erase Collection", systemImage: "trash")
                            .foregroundColor(.red)
                    }
                    
                    .alert(isPresented: $confirmationShown) {
                        Alert(
                            title: Text("Erase Collection?"),
                            message: Text("Your collection will be reset to default settings."),
                            primaryButton: .default(
                                           Text("Cancel"),
                                           action: {}
                            ),
                            secondaryButton: .destructive(
                                           Text("Erase"),
                                           action: collectionModel.resetCollection
                            )
                        )
                    }
                    Button(action: {
                        if(collectionModel.iCloudStatus){
                            NSUbiquitousKeyValueStore.default.synchronize()
                            showSyncToast.toggle()
                        }
                        else {
                            noiCloudAccount.toggle()
                        }
                        
                    }) {
                        Label("Sync with iCloud", systemImage: "icloud.fill").foregroundColor(.blue)
                    }
                    .alert(isPresented: $noiCloudAccount) {
                        Alert(
                            title: Text("iCloud Account Not Found"),
                            message: Text("Sign in to iCloud to sync your collection with all of your devices."),
                            primaryButton: .default(Text("Settings"), action: {
                                UIApplication.shared.open(URL(string: "App-Prefs:root=CASTLE")!)
                            }),
                            secondaryButton: .default(Text("OK"))
                        )
                    }
                }
                //.headerProminence(.increased)

                Section(header: Text("Manage Collection").customSectionHeader())
                {
                    Button(action: {
                        CSVCollectionModel(collectionModel: collectionModel).loadSampleCollection()
                        if(collectionModel.collectionSize >= 1000) {
                            alertInfo = AlertInfo(id: .collectionSizeError, title: "1000 Product Limit Reached", message: "Some products may not have been loaded into your collection.")
                        }
                        else {
                            alertInfo = AlertInfo(id: .collectionSizeError, title: "Sample Collection Successfully Loaded", message: "The sample products have been successfully loaded into your collection.")
                        }
                        
                    }) {
                        Label("Load Sample Collection", systemImage: "square.and.arrow.down")
                    }
                    Button(action: {isExporting.toggle()}) {
                        Label("Export Collection to CSV", systemImage: "arrow.up.doc.fill")
                    }
                    Button(action: {isImporting.toggle()}) {
                        Label("Import Collection from CSV", systemImage: "arrow.down.doc.fill")
                    }
                }
                //.headerProminence(.increased)

                Section(header: Text("Appearance").customSectionHeader())
                {
                    HStack {
                        Text("Accent Color")
                        Spacer()
                        ColorPicker("", selection: $accentColor.color, supportsOpacity: false)
                            .onChange(of: accentColor.color, perform: { value in
                                accentColor.saveColor()
                                collectionModel.saveWidgetModel()
                        })
                        #if targetEnvironment(macCatalyst)
                            .frame(width: 100)
                        #endif
                            .contextMenu {
                                Button(action: {accentColor.color = Color.accentColor; accentColor.saveColor()}) {
                                    Label("Reset to Default", systemImage: "arrow.counterclockwise")

                                }
                            }
                    }
                }
                //.headerProminence(.increased)

                Section(header: Text("Fruitstand Info").customSectionHeader())
                {
                    HStack {
                        Text("Version Number")
                        Spacer()
                        Text(getVersionNumber()).foregroundColor(.gray)
                    }
                    HStack {
                        Text("Build Number")
                        Spacer()
                        Text(getBuildNumber()).foregroundColor(.gray)
                    }
                }
                //.headerProminence(.increased)

            }

            
            .fileExporter(isPresented: $isExporting, documents: CSVCollectionModel(collectionModel: collectionModel).getCSVFiles(), contentType: UTType.commaSeparatedText) { result in
                switch result {
                    case .success(let url):
                        print("Saved to \(url)")
                    case .failure(let error):
                        print(error.localizedDescription)
                }
            }
            .fileImporter(
                isPresented: $isImporting, allowedContentTypes: [UTType.commaSeparatedText], allowsMultipleSelection: true) { result in
                    do {
                        let acceptableFileNames = ["iPhone.csv", "iPad.csv", "Mac.csv", "AppleWatch.csv", "AirPods.csv", "AppleTV.csv", "iPod.csv"]
                        let fileNamesToDeviceTypes: [String: DeviceType] = ["iPhone.csv": DeviceType.iPhone, "iPad.csv": DeviceType.iPad, "Mac.csv": DeviceType.Mac, "AppleWatch.csv": DeviceType.AppleWatch, "AirPods.csv": DeviceType.AirPods, "AppleTV.csv": DeviceType.AppleTV, "iPod.csv": DeviceType.iPod]
                        let selectedFiles: [URL] = try result.get()
                        var CSVStrings: [DeviceType: String] = [:]
                        print(selectedFiles)
                        for file in selectedFiles
                        {
                            let fileName = String(file.lastPathComponent)
                            if(!acceptableFileNames.contains(fileName)) {
                                
                                throw FileError.fileNameError
                            }
                            if file.startAccessingSecurityScopedResource() {
                                guard let CSVString = String(data: try Data(contentsOf: file), encoding: .utf8) else {throw FileError.decodeError }
                                CSVStrings[fileNamesToDeviceTypes[fileName]!] = CSVString
                                do { file.stopAccessingSecurityScopedResource() }
                            }
                            else {
                               print("Access denied!")
                            }
                        }
                        CSVCollectionModel(collectionModel: collectionModel).loadImportCollection(CSVStrings: CSVStrings)
                        if(collectionModel.collectionSize >= 1000)
                        {
                            throw FileError.collectionSizeError
                        }
                        else {
                            alertInfo = AlertInfo(id: .importSuccessful, title: "Import Successful", message: "Your products have been loaded into your collection.")
                        }
                    }
                    catch {
                        print(error.localizedDescription)
                        switch(error)
                        {
                        case FileError.decodeError:
                            alertInfo = AlertInfo(id: .fileNameError, title: "File Decoding Error", message: "Error decoding file. Please try again.")
                        case FileError.fileNameError:
                            alertInfo = AlertInfo(id: .fileNameError, title: "File Naming Error", message: "Some of your files were not imported. Please rename your CSV files for each product type as follows: \n iPhone.csv \n iPad.csv \n Mac.csv \n AppleWatch.csv \n AirPods.csv \n AppleTV.csv \n iPod.csv")
                        case FileError.collectionSizeError:
                            alertInfo = AlertInfo(id: .collectionSizeError, title: "1000 Product Limit Reached", message: "Some products may not have been loaded into your collection.")
                        default:
                            alertInfo = AlertInfo(id: .collectionSizeError, title: "Unknown Error", message: "Please try again.")
                            
                        }
                    }
                  
            }
            .alert(item: $alertInfo, content: { info in
                Alert(title: Text(info.title),
                    message: Text(info.message),
                    dismissButton: .default(Text("OK")))
            })
            .toast(isPresenting: $showSyncToast, duration: 1) {
                AlertToast(type: .systemImage("cloud.fill", Color.blue), title: "Sync in Progress", style: AlertToast.AlertStyle.style(titleFont: Font.system(.title3, design: .rounded).bold()))
            }
            .navigationTitle(Text("Settings"))
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading)
                {
                    Button(action: {self.showSettingsModalView.toggle()}, label: {Text("Close").fontWeight(.regular)})
                }
            }
        }
        .accentColor(accentColor.color)
    }
    func getVersionNumber() -> String
    {
        let appVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String
        return appVersion!
    }
    func getBuildNumber() -> String
    {
        let build = Bundle.main.infoDictionary?["CFBundleVersion"] as? String
        return build!
    }
   
}

