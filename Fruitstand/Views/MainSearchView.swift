//
//  MainSearchView.swift
//  Fruitstand
//
//  Created by Armand Sarkani on 1/21/22.
//

import Foundation
import SwiftUI

struct MainSearchView: View {
    @EnvironmentObject var collectionModel: CollectionModel
    @State private var searchText = ""
    @State var deviceTypeFilter: String = "All Devices"
    let deviceTypeFilters = ["All Devices", "Mac", "iPhone", "iPad", "Apple Watch", "AirPods", "Apple TV", "iPod"]
    var suggestions: [String] {
        return getSearchSuggestions(deviceTypeFilter: deviceTypeFilter)
    }
    var searchResults: [ProductInfo] {
           if searchText.isEmpty {
               return []
           }
           else {
               if(deviceTypeFilter != "All Devices")
               {
                   return collectionModel.collectionArray.filter { $0.contains(searchText: searchText) && $0.type == DeviceType(rawValue: deviceTypeFilter)}
               }
               return collectionModel.collectionArray.filter { $0.contains(searchText: searchText)}

           }
    }
    var resultsText: String {
        if searchText.isEmpty {
            return ""
        }
        else {
            return "\(searchResults.count) Results"
        }
    }
    // Get edit/delete working refresh this view
    var body: some View {
        if(!searchText.isEmpty)
        {
            Spacer()
            Picker(selection: $deviceTypeFilter, label: Label("Device Type", systemImage: "square.3.layers.3d.down.left")) {
                ForEach(deviceTypeFilters, id: \.self) { filter in
                    Image(systemName: (icons[filter] ?? "circle.hexagongrid"))
                }
            }
            .pickerStyle(.segmented)
            #if targetEnvironment(macCatalyst)
            .frame(maxWidth: (UIScreen.main.bounds.width * 0.35))
            #else
            .frame(maxWidth: (UIDevice.current.model.hasPrefix("iPad") ? (UIScreen.main.bounds.width * 0.6): (UIScreen.main.bounds.width * 0.9)))
            #endif
            Spacer()

        }
        Form
        {
            if(!searchText.isEmpty)
            {
                Section(header: Text(resultsText).fontWeight(.medium).font(.title3).textCase(nil)) {}
                .listRowInsets(EdgeInsets(top: 20, leading: 7, bottom: -500, trailing: 200))
            }
            if(searchText.isEmpty)
            {
                Section("Suggestions")
                {
                    ForEach(suggestions.choose(4), id: \.self) { suggestion in
                        Button(action: {generator.notificationOccurred(.success); searchText = suggestion})
                        {
                            Label{Text(suggestion).foregroundColor(.primary)} icon: {Image(systemName: "arrow.up.right")}
                            
                        }
                    }
                }
                Picker("Filter By Device Type", selection: $deviceTypeFilter) {
                    ForEach(deviceTypeFilters, id: \.self) { filter in
                        Label(filter, systemImage: (icons[filter] ?? "circle.hexagongrid"))
                    }
                }
                .pickerStyle(.inline)
            }
            ForEach(searchResults, id: \.self) { product in
                Section {
                    ProductCardView(product: product, fullSearchable: true).environmentObject(collectionModel)
                }
            }
        }
        .searchable(text: $searchText, placement: .navigationBarDrawer(displayMode: .always), prompt: "Search all products ").autocapitalization(.none)
        .navigationTitle("Search")
        .navigationBarTitleDisplayMode(.large)
    }
    func getSearchSuggestions(deviceTypeFilter: String) -> [String]
    {
        if(deviceTypeFilter == "All Devices")
        {
            return ["M1 Max", "M1", "64GB", "2019", "2020", "2021", "2022", "Intel Core i5", "Intel Core i7", "Intel Core i9", "iPad Pro", "MacBook Air (retina)", "MacBook Pro (retina)", "MacBook Pro (unibody)", "iPad Air", "Retina", "AirPods Pro", "Unable to power on", "Activation Lock", "AirPods Max", "iPhone 13 Pro Max"]
        }
        else if(deviceTypeFilter == "iPhone")
        {
            return ["iPhone 13", "iPhone 13 mini", "iPhone 13 Pro", "iPhone 13 Pro Max", "iPhone SE", "Unable to power on", "First iPhone", "64GB", "128GB", "256GB", "512GB", "Activation Lock", "AppleCare+"]
        }
        else if(deviceTypeFilter == "iPad")
        {
            return ["iPad Pro", "iPad Air", "iPad mini", "Unable to power on", "First iPad", "64GB", "128GB", "256GB", "512GB", "Activation Lock", "AppleCare+"]
        }
        else if(deviceTypeFilter == "Mac")
        {
            return ["M1 Max", "M1", "2019", "2020", "2021", "2022", "Intel Core i5", "Intel Core i7", "Intel Core i9", "MacBook Air (retina)", "MacBook Pro (retina)", "MacBook Pro (unibody)", "iMac Pro", "Retina", "Unable to power on", "SSD", "First Mac", "Activation Lock", "AppleCare+"]
        }
        else if(deviceTypeFilter == "Apple Watch")
        {
            return ["Apple Watch SE", "Apple Watch Series 7", "Apple Watch Series 6", "Unable to power on", "First Apple Watch", "Titanium", "Stainless steel", "Aluminum", "Activation Lock", "AppleCare+"]

        }
        else if(deviceTypeFilter == "AirPods")
        {
            return ["AirPods Pro", "3rd gen", "AirPods Max", "First AirPods", "MagSafe", "AppleCare+"]

        }
        else if(deviceTypeFilter == "Apple TV")
        {
            return ["Apple TV 4K", "Apple TV HD", "First Apple TV", "AppleCare+"]
        }
        else
        {
            return ["32GB", "16GB", "8GB", "iPod classic", "iPod touch", "iPod nano", "iPod shuffle", "iPod + HP", "First iPod", "AppleCare+"]

        }
    }
}
