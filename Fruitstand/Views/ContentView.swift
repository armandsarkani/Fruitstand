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
                        NavigationLink(destination: ProductListView(deviceType: label).environmentObject(collectionModel)){
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
            .navigationBarItems(
                leading:
                    Button(action: {
                            showSettingsModalView.toggle()
                            }) {
                                Image(systemName: "gearshape")
                                    .imageScale(.large)
                                    .frame(height: 96, alignment: .trailing)
                                },
                    trailing:
                    HStack
                    {
                        NavigationLink(destination: MainSearchView().environmentObject(collectionModel))
                        {
                            Image(systemName: "magnifyingglass")
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

struct ContentView_Previews: PreviewProvider{
    static var previews: some View {
        Group {
            ContentView()
                .preferredColorScheme(.dark)
        }
    }
}

