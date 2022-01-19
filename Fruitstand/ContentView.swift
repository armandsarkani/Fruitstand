//
//  ContentView.swift
//  Fruitstand
//
//  Created by Armand Sarkani on 5/16/21.
//

// This module is responsible for the view layouts of the main screen and model list screen.


import SwiftUI

// Global variables
var keyStore = NSUbiquitousKeyValueStore()
let icons: [String: String] = ["Mac": "laptopcomputer", "iPhone": "iphone", "iPad": "ipad", "Apple Watch": "applewatch", "AirPods": "airpodspro", "Apple TV": "appletv.fill", "iPod": "ipod"]
extension View {
    func `if`<Content: View>(_ conditional: Bool, content: (Self) -> Content) -> some View {
         if conditional {
             return AnyView(content(self))
         } else {
             return AnyView(self)
         }
     }
}

struct ContentView: View {
    @State var showInfoModalView: Bool = false
    @State var showSettingsModalView: Bool = false
    @State var searchText: String = ""
    @State var deviceTypeCounts: [DeviceType: Int] = loadDeviceTypeCounts()
    @Environment(\.isPresented) var presentation
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
                    NavigationLink(destination: ValuesView()){
                        Label("Values", systemImage: "dollarsign.circle.fill")
                    }
                    HStack
                    {
                        Label("Collection Size", systemImage: "sum")
                            .fixedSize()
                        Spacer()
                        Text(String(getTotalCollectionSize()))
                            .foregroundColor(.gray)
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
                Button(action: {generator.notificationOccurred(.success); showInfoModalView.toggle()
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
        .if(UIDevice.current.model.hasPrefix("iPhone")) {
            $0.navigationViewStyle(StackNavigationViewStyle())
        }

    }
    func getTotalCollectionSize() -> Int
    {
        return deviceTypeCounts[DeviceType.iPhone]! + deviceTypeCounts[DeviceType.iPad]! + deviceTypeCounts[DeviceType.Mac]! + deviceTypeCounts[DeviceType.AppleWatch]! + deviceTypeCounts[DeviceType.AirPods]! + deviceTypeCounts[DeviceType.AppleTV]! + deviceTypeCounts[DeviceType.iPod]!
    }
}
    
struct SettingsView: View {
    @Binding var deviceTypeCounts: [DeviceType: Int]
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
                                           action: resetDefaults
                            )
                        )
                    }
                    Button(action: {loadSampleCollection()}) {
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
        .navigationTitle(Text(deviceType))    .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            modelList = loadModelList(deviceType: deviceType)
        }
        .navigationBarItems(trailing:
                Button(action: {generator.notificationOccurred(.success); showInfoModalView.toggle()}) {
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

struct ValuesView: View {
    @State var totalCollectionValue: Int = getTotalCollectionValue()
    @State var deviceTypeValues: [DeviceType: Int] = getDeviceTypeValues()
    @State var averageValues: [DeviceType: Double] = getAverageValues()
    var body: some View {
        if collectionIsEmpty() {
            VStack(spacing: 15)
            {
                Image(systemName: "dollarsign.circle.fill")
                    .font(.system(size: 72))
                Text("Values")
                    .font(.title)
                    .fontWeight(.bold)
                Text("Collection is empty.")
                    .font(.body)
            }
        }
       else
        {
            List {
                HStack
                {
                    Label("Total Collection Value", systemImage: "dollarsign.circle.fill")
                        .fixedSize()
                    Spacer()
                    Text(String(format: "$%d", locale: Locale.current, totalCollectionValue))
                        .foregroundColor(.gray)
                }
               Section("Total Value By Device Type")
                {
                    ForEach(DeviceType.allCases, id: \.self) { key in
                        HStack
                        {
                            Label(key.id, systemImage: icons[key.id]!)
                                .fixedSize()
                            Spacer()
                            Text(String(format: "$%d", locale: Locale.current, deviceTypeValues[key]!))
                                .foregroundColor(.gray)
                        }
                    }
                }
                Section("Average Value By Device Type")
                 {
                     ForEach(DeviceType.allCases, id: \.self) { key in
                         HStack
                         {
                             Label(key.id, systemImage: icons[key.id]!)
                                 .fixedSize()
                             Spacer()
                             Text(String(format: "$%.2f", locale: Locale.current, averageValues[key]!))
                                 .foregroundColor(.gray)
                         }
                     }
                 }
            }
            .navigationTitle("Values")
            .navigationBarTitleDisplayMode(.inline)

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

