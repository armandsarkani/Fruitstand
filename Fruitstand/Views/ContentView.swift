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
    @State private var collectionFull: Bool = false
    @State var showSettingsModalView: Bool = false
    @State var count = 1
    @EnvironmentObject var collectionModel: CollectionModel
    @EnvironmentObject var accentColor: AccentColor
    @Environment(\.isPresented) var presentation
    var body: some View {
        NavigationView {
            List {
                Section(header: Text("Devices"))
                {
                    ForEach(DeviceType.allCases, id: \.self) { label in
                        NavigationLink(destination: ProductListView(deviceType: label).environmentObject(collectionModel).environmentObject(accentColor)){
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
                    NavigationLink(destination: ValuesView().environmentObject(collectionModel)){
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
                        NavigationLink(destination: SearchView().environmentObject(collectionModel).environmentObject(accentColor))
                        {
                            Image(systemName: "magnifyingglass")
                                .imageScale(.large)
                                .frame(height: 96, alignment: .trailing)
                        }
                        .keyboardShortcut("f", modifiers: .command)
                        Button(action: {
                            if(collectionModel.collectionSize >= 1000)
                            {
                                generator.notificationOccurred(.error)
                                collectionFull.toggle()
                            }
                            else {
                                generator.notificationOccurred(.success)
                                showInfoModalView.toggle()
                            }
                            }) {
                                Image(systemName: "plus")
                                    .imageScale(.large)
                                    .frame(height: 96, alignment: .trailing)
                            }
                            #if targetEnvironment(macCatalyst)
                            .keyboardShortcut("a", modifiers: .command)
                            #else
                            .keyboardShortcut("+", modifiers: .command)
                            #endif

                        })
                        .alert(isPresented: $collectionFull) {
                            Alert(
                                title: Text("1000 Product Limit Reached"),
                                message: Text("Remove at least one product from your collection before adding new ones."),
                                dismissButton: .default(Text("OK"))
                            )
                        }


            .onAppear {
                collectionModel.loadCollection(count: count)
                count += 1
            }
            
        }
        .sheet(isPresented: $showInfoModalView) {
            AddProductView(showInfoModalView: self.$showInfoModalView).environmentObject(collectionModel).environmentObject(accentColor)
            
        }
        .sheet(isPresented: $showSettingsModalView) {
            SettingsView(showSettingsModalView: self.$showSettingsModalView).environmentObject(collectionModel).environmentObject(accentColor)
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

