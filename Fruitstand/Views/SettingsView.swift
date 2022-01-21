//
//  SettingsView.swift
//  Fruitstand
//
//  Created by Armand Sarkani on 1/21/22.
//

import Foundation
import SwiftUI

struct SettingsView: View {
    @EnvironmentObject var collectionModel: CollectionModel
    @Binding var showSettingsModalView: Bool
    @State private var confirmationShown = false
    @Environment(\.isPresented) var presentation
    var body: some View {
        NavigationView {
            List
            {
                Section("General")
                {
                    Button(action: {confirmationShown.toggle()}) {
                        Label("Erase All Products", systemImage: "trash")
                            .foregroundColor(.red)
                    }
                    
                    .alert(isPresented: $confirmationShown) {
                        Alert(
                            title: Text("Erase All Products?"),
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
                    Button(action: {loadNewSampleCollection(collection: collectionModel)}) {
                        Label("Load Sample Collection", systemImage: "square.and.arrow.down")
                    }
                    Button(action: {NSUbiquitousKeyValueStore.default.synchronize()}) {
                        Label("Sync with iCloud", systemImage: "icloud.fill")
                            .foregroundColor(.blue)
                    }
                }
                Section("Fruitstand Info"){
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
            .navigationTitle(Text("Settings"))
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarItems(
                leading: Button(action: {self.showSettingsModalView.toggle()}, label: {Text("Close").fontWeight(.regular)}))
        }
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
