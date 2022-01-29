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

struct SettingsView: View {
    @EnvironmentObject var collectionModel: CollectionModel
    @Binding var showSettingsModalView: Bool
    @State private var noiCloudAccount: Bool = false
    @State private var isExporting: Bool = false
    @State private var isImporting: Bool = false
    @State private var importSuccessful: Bool = false
    @State private var loadSampleCollectionSuccessful: Bool = false
    @State private var collectionFull: Bool = false
    @State private var importError: Bool = false
    @State private var confirmationShown = false
    @EnvironmentObject var accentColor: AccentColor
    let appearances: [SwiftUI.ColorScheme] = [.light, .dark]
    @Environment(\.colorScheme) var colorScheme
    @Environment(\.isPresented) var presentation
    var body: some View {
        NavigationView {
            List
            {
                Section(header: Text("General").font(.subheadline))
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
                Section(header: Text("Manage Collection").font(.subheadline))
                {
                    Button(action: {
                        CSVCollectionModel(collectionModel: collectionModel).loadSampleCollection()
                        if(collectionModel.collectionSize >= 1000) {
                            collectionFull.toggle()
                        }
                        else {
                            loadSampleCollectionSuccessful.toggle()
                        }
                        
                    }) {
                        Label("Load Sample Collection", systemImage: "square.and.arrow.down")
                    }
                    .alert(isPresented: $loadSampleCollectionSuccessful) {
                        Alert(
                            title: Text("Sample Collection Successfully Loaded"),
                            message: Text("The sample products have been successfully loaded into your collection."),
                            dismissButton: .default(Text("OK"))
                        )
                    }
                    Button(action: {isExporting.toggle()}) {
                        Label("Export Collection to CSV", systemImage: "arrow.up.doc.fill")
                    }
                    Button(action: {isImporting.toggle()}) {
                        Label("Import Collection from CSV", systemImage: "arrow.down.doc.fill")
                    }
                }
                Section(header: Text("Appearance").font(.subheadline))
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
                Section(header: Text("Fruitstand Info").font(.subheadline))
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
                            if(!acceptableFileNames.contains(fileName))
                            {
                                importError.toggle()
                                break
                            }
                            guard let CSVString = String(data: try Data(contentsOf: file), encoding: .utf8) else { return }
                            CSVStrings[fileNamesToDeviceTypes[fileName]!] = CSVString
                        }
                        CSVCollectionModel(collectionModel: collectionModel).loadImportCollection(CSVStrings: CSVStrings)
                        if(collectionModel.collectionSize >= 1000)
                        {
                            collectionFull.toggle()
                        }
                        else {
                            importSuccessful.toggle()
                        }
                    }
                    catch {
                    }
            }
            .alert(isPresented: $importError) {
                Alert(
                    title: Text("File Naming Error"),
                    message: Text("Some of your files were not imported. Please rename your CSV files for each product type as follows: \n iPhone.csv \n iPad.csv \n Mac.csv \n AppleWatch.csv \n AirPods.csv \n AppleTV.csv \n iPod.csv"),
                    dismissButton: .default(Text("OK"))
                )
            }
            .alert(isPresented: $importSuccessful) {
                Alert(
                    title: Text("Import Successful"),
                    message: Text("Your products have been loaded into your collection."),
                    dismissButton: .default(Text("OK"))
                )
            }
            .padding(.top, -15)
            .navigationTitle(Text("Settings"))
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading)
                {
                    Button(action: {self.showSettingsModalView.toggle()}, label: {Text("Close").fontWeight(.regular)})
                }
            }
        }
        .alert(isPresented: $collectionFull) {
            Alert(
                title: Text("1000 Product Limit Reached"),
                message: Text("Some products may not have been loaded into your collection."),
                dismissButton: .default(Text("OK"))
            )
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

