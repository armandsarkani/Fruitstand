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
    @StateObject var collectionModel: CollectionModel = CollectionModel()
    @Environment(\.isPresented) var presentation
    var body: some View {
        NavigationView {
            List {
                Section(header: Text("Devices"))
                {
                    ForEach(DeviceType.allCases, id: \.self) { label in
                        NavigationLink(destination: ProductListView(deviceType: label)        .environmentObject(collectionModel)){
                            Label(label.id, systemImage: icons[label.id]!)
                                .fixedSize()
                            Spacer()
                            
                            Text(String(collectionModel.collection[label]!.count))
                                .foregroundColor(.gray)
                        }
                    }
                }
                Section(header: Text("Statistics"))
                {
                    NavigationLink(destination: ValuesView()        .environmentObject(collectionModel)){
                        Label("Values", systemImage: "dollarsign.circle.fill")
                    }
                    HStack
                    {
                        Label("Collection Size", systemImage: "sum")
                            .fixedSize()
                        Spacer()
                        Text(String(collectionModel.collectionSize))
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
            .onAppear {
                collectionModel.loadCollection()
            }
            
        }
        .sheet(isPresented: $showInfoModalView) {
            AddProductView(showInfoModalView: self.$showInfoModalView).environmentObject(collectionModel)
            
        }
        .sheet(isPresented: $showSettingsModalView) {
            SettingsView(showSettingsModalView: self.$showSettingsModalView).environmentObject(collectionModel)
        }

    }
}
    
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

struct ProductListView: View {
    var deviceType: DeviceType
    @EnvironmentObject var collectionModel: CollectionModel
    @State var showInfoModalView: Bool = false
    init(deviceType: DeviceType)
    {
        self.deviceType = deviceType
    }
    var body: some View {
        List
        {
            ForEach(collectionModel.modelList[deviceType]!, id: \.self) { model in
                NavigationLink(destination: ProductView(model: model.model, deviceType: deviceType)              .environmentObject(collectionModel)){
                    if(model.model.count >= 30)
                    {
                        Label(model.model, systemImage: getProductIcon(product: ProductInfo(type: DeviceType(rawValue: deviceType.rawValue), model: model.model)))
                            .minimumScaleFactor(0.5)
                    }
                    else
                    {
                        Label(model.model, systemImage: getProductIcon(product: ProductInfo(type: DeviceType(rawValue: deviceType.rawValue), model: model.model)))
                            .fixedSize()
                    }
                    Spacer()
                    Text(String(model.count!))
                        .foregroundColor(.gray)
                }
            }
        }
        .overlay(Group {
            if(collectionModel.modelList[deviceType]!.isEmpty){
                VStack(spacing: 15)
                {
                    Image(systemName: icons[deviceType.rawValue]!)
                        .font(.system(size: 72))
                    Text(deviceType.rawValue)
                        .font(.title)
                        .fontWeight(.bold)
                    Text("Collection is empty.")
                        .font(.body)
                }
            }
        })
        .navigationTitle(Text(deviceType.rawValue))
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarItems(trailing:
                Button(action: {generator.notificationOccurred(.success); showInfoModalView.toggle()}) {
                Image(systemName: "plus")
                    .imageScale(.large)
                    .frame(height: 96, alignment: .trailing)
            })
        .sheet(isPresented: $showInfoModalView) {
            AddProductView(showInfoModalView: self.$showInfoModalView).environmentObject(collectionModel)
       }
    }
}

struct ValuesView: View {
    @EnvironmentObject var collectionModel: CollectionModel
    var body: some View {
        if(collectionModel.isEmpty()) {
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
                    Text(String(format: "$%d", locale: Locale.current, getTotalCollectionValue(collection: collectionModel.collection)))
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
                            Text(String(format: "$%d", locale: Locale.current, getDeviceTypeValues(collection: collectionModel.collection)[key]!))
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
                             Text(String(format: "$%.2f", locale: Locale.current,        getAverageValues(collection: collectionModel.collection, deviceTypeCounts: collectionModel.getDeviceTypeCounts())[key]!))
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

