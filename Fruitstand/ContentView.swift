//
//  ContentView.swift
//  Fruitstand
//
//  Created by Armand Sarkani on 5/16/21.
//

import SwiftUI

var keyStore = NSUbiquitousKeyValueStore()

let icons: [String: String] = ["Mac": "desktopcomputer", "iPhone": "iphone", "iPad": "ipad", "Apple Watch": "applewatch", "AirPods": "airpodspro", "Apple TV": "appletv.fill", "iPod": "ipod"]
struct ContentView: View {
    @State var showInfoModalView: Bool = false
    @State var showSettingsModalView: Bool = false
    @State var searchText: String = ""
    @Environment(\.presentationMode) var presentation
    var body: some View {
        NavigationView {
            List {
                Section(header: Text("Devices"))
                {
                    ForEach(DeviceType.allCases, id: \.self) { label in
                        NavigationLink(destination: ProductListView(deviceType: label.id)){
                            Label(label.id, systemImage: icons[label.id]!)
                                .fixedSize()
                            Spacer()
                            Text(String(loadDeviceTypeCounts()[label]!))
                                .foregroundColor(.gray)
                        }
                    }
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
            AddProductView(showInfoModalView: self.$showInfoModalView) }
        .sheet(isPresented: $showSettingsModalView) {
            SettingsView(showSettingsModalView: self.$showSettingsModalView) }
        }
    }
    
struct SettingsView: View {
    @Binding var showSettingsModalView: Bool
    @State private var confirmationShown = false
    @Environment(\.presentationMode) var presentation
    var body: some View {
        NavigationView {
            List
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
            }
            .navigationTitle(Text("Settings"))
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarItems(
                leading: Button(action: {self.showSettingsModalView.toggle()}, label: {Text("Close").fontWeight(.regular)}))
           
        }
    }
   
}

struct ProductListView: View {
    var deviceType: String
    @State var modelList: [ModelAndCount]
    init(deviceType: String)
    {
        self.deviceType = deviceType
        self.modelList = loadModelList(deviceType: deviceType)

    }
    var body: some View {
        if(modelList.isEmpty)
        {
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
        else
        {
            List
            {
                ForEach($modelList, id: \.self) { $model in
                    NavigationLink(destination: ProductView(model: model.model, deviceType: deviceType)){
                        if(DeviceType(rawValue: deviceType) == DeviceType.iPhone){
                            Label(model.model, systemImage: iPhoneModel(rawValue: model.model)!.getIcon())
                                .fixedSize()
                        }
                        if(DeviceType(rawValue: deviceType) == DeviceType.iPad){
                            Label(model.model, systemImage: iPadModel(rawValue: model.model)!.getIcon())
                                .fixedSize()
                        }
                        if(DeviceType(rawValue: deviceType) == DeviceType.Mac){
                            Label(model.model, systemImage: MacModel(rawValue: model.model)!.getIcon())
                                .fixedSize()
                        }
                        if(DeviceType(rawValue: deviceType) == DeviceType.AppleWatch){
                            Label(model.model, systemImage: AppleWatchModel(rawValue: model.model)!.getIcon())
                                .fixedSize()
                        }
                        if(DeviceType(rawValue: deviceType) == DeviceType.AirPods){
                            Label(model.model, systemImage: AirPodsModel(rawValue: model.model)!.getIcon())
                                .fixedSize()
                        }
                        if(DeviceType(rawValue: deviceType) == DeviceType.AppleTV){
                            Label(model.model, systemImage: AppleTVModel(rawValue: model.model)!.getIcon())
                                .fixedSize()
                        }
                        if(DeviceType(rawValue: deviceType) == DeviceType.iPod){
                            Label(model.model, systemImage: iPodModel(rawValue: model.model)!.getIcon())
                                .fixedSize()
                        }
                        Spacer()
                        Text(String(model.count!))
                            .foregroundColor(.gray)
                    }
                }
                
            }.navigationTitle(Text(deviceType))        .navigationBarTitleDisplayMode(.inline)
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

struct ProductListView_Previews: PreviewProvider{
    static var previews: some View {
        Group {
            ProductListView(deviceType: "iPhone")
                .preferredColorScheme(.dark)
        }
    }
}
