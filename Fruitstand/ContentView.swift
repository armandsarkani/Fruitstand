//
//  ContentView.swift
//  Fruitstand
//
//  Created by Armand Sarkani on 5/16/21.
//

import SwiftUI

// Global variables
var keyStore = NSUbiquitousKeyValueStore()
let icons: [String: String] = ["Mac": "desktopcomputer", "iPhone": "iphone", "iPad": "ipad", "Apple Watch": "applewatch", "AirPods": "airpodspro", "Apple TV": "appletv.fill", "iPod": "ipod"]

struct ContentView: View {
    @State var showInfoModalView: Bool = false
    @State var showSettingsModalView: Bool = false
    @State var searchText: String = ""
    @State var deviceTypeCounts: [DeviceType: Int] = loadDeviceTypeCounts()
    @Environment(\.presentationMode) var presentation
    var body: some View {
        NavigationView {
            List {
                Section(header: Text("Devices"))
                {
                    ForEach(DeviceType.allCases, id: \.self) { label in
                        NavigationLink(destination: ProductListView(deviceType: label.id, deviceTypeCounts: $deviceTypeCounts)){
                            Label(label.id, systemImage: icons[label.id]!)
                                .fixedSize()
                            Spacer()
                            Text(String(deviceTypeCounts[label]!))
                                .foregroundColor(.gray)
                        }
                    }
                }
                .onAppear {
                    deviceTypeCounts = loadDeviceTypeCounts()
                }
                Section(header: Text("Statistics"))
                {
                    NavigationLink(destination: CountsView()){
                        Label("Counts", systemImage: "sum")
                    }
                    NavigationLink(destination: ValuesView()){
                        Label("Values", systemImage: "dollarsign.circle.fill")
                    }
                }
               
            }
            .listStyle(InsetGroupedListStyle())
            .environment(\.horizontalSizeClass, .regular)
            .navigationTitle(Text("My Collection"))
            .navigationBarItems(trailing:
                    HStack
                    {
                        Button(action: {
                            showSettingsModalView.toggle()
                            }) {
                                Image(systemName: "gearshape")
                                    .imageScale(.large)
                                    .frame(height: 96, alignment: .trailing)
                                }
                        Button(action: {
                            showInfoModalView.toggle()
                            }) {
                                Image(systemName: "plus")
                                    .imageScale(.large)
                                    .frame(height: 96, alignment: .trailing)
                            }
                    })
            
        }
        .sheet(isPresented: $showInfoModalView) {
            AddProductView(showInfoModalView: self.$showInfoModalView)
                .onDisappear {
                    deviceTypeCounts = loadDeviceTypeCounts()

                }
            
        }
        .sheet(isPresented: $showSettingsModalView) {
            SettingsView(deviceTypeCounts: $deviceTypeCounts, showSettingsModalView: self.$showSettingsModalView)
                .onDisappear {
                    deviceTypeCounts = loadDeviceTypeCounts()

                }
        }
        
    }
}
    
struct SettingsView: View {
    @Binding var deviceTypeCounts: [DeviceType: Int]
    @Binding var showSettingsModalView: Bool
    @State private var confirmationShown = false
    @Environment(\.presentationMode) var presentation
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
                                           action: resetDefaults
                            )
                        )
                    }
                    Button(action: {loadSampleCollection()}) {
                        Label("Load Sample Collection", systemImage: "square.and.arrow.down")
                    }
                    Button(action: {}) {
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

struct ProductListView: View {
    var deviceType: String
    @Binding var deviceTypeCounts: [DeviceType: Int]
    @State var modelList: [ModelAndCount]
    @State var showInfoModalView: Bool = false
    init(deviceType: String, deviceTypeCounts: Binding<[DeviceType: Int]>)
    {
        self.deviceType = deviceType
        self.modelList = loadModelList(deviceType: deviceType)
        _deviceTypeCounts = deviceTypeCounts
    }
    var body: some View {
        List
        {
            ForEach($modelList, id: \.self) { $model in
                NavigationLink(destination: ProductView(model: model.model, deviceType: deviceType, deviceTypeCounts: $deviceTypeCounts)){
                    if(model.model.count >= 30)
                    {
                        Label(model.model, systemImage: getProductIcon(product: ProductInfo(type: DeviceType(rawValue: deviceType), model: model.model)))
                            .minimumScaleFactor(0.5)
                    }
                    else
                    {
                        Label(model.model, systemImage: getProductIcon(product: ProductInfo(type: DeviceType(rawValue: deviceType), model: model.model)))
                            .fixedSize()
                    }
                    Spacer()
                    Text(String(model.count!))
                        .foregroundColor(.gray)
                }
            }
        }
        .overlay(Group {
            if modelList.isEmpty {
                VStack(spacing: 15)
                {
                    Image(systemName: icons[deviceType]!)
                        .font(.system(size: 72))
                    Text(deviceType)
                        .font(.title)
                        .fontWeight(.bold)
                    Text("Collection is empty.")
                        .font(.body)
                }
            }
        })
        .navigationTitle(Text(deviceType))     .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            modelList = loadModelList(deviceType: deviceType)
        }
        .navigationBarItems(trailing:
            Button(action: {showInfoModalView.toggle()}) {
                Image(systemName: "plus")
                    .imageScale(.large)
                    .frame(height: 96, alignment: .trailing)
            })
        .sheet(isPresented: $showInfoModalView) {
            AddProductView(showInfoModalView: self.$showInfoModalView)
                .onDisappear {
                    deviceTypeCounts = loadDeviceTypeCounts()
                    modelList = loadModelList(deviceType: deviceType)
                }
       }
    }
}

struct CountsView: View {
    var body: some View {
        VStack(spacing: 15)
        {
            Image(systemName: "sum")
                .font(.system(size: 72))
            Text("Product Count Statistics")
                .font(.title)
                .fontWeight(.bold)
            Text("This feature is coming soon!")
                .font(.body)
        }
            
    }
    
}
struct ValuesView: View {
    var body: some View {
        VStack(spacing: 15)
        {
            Image(systemName: "dollarsign.circle.fill")
                .font(.system(size: 72))
            Text("Product Value Statistics")
                .font(.title)
                .fontWeight(.bold)
            Text("This feature is coming soon!")
                .font(.body)
        }
            
    }
    
}

struct ContentView_Previews: PreviewProvider{
    static var previews: some View {
        Group {
            ContentView()
                .preferredColorScheme(.dark)
        }
    }
}

