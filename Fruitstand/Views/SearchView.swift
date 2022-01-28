//
//  SearchView.swift
//  Fruitstand
//
//  Created by Armand Sarkani on 1/21/22.
//

import Foundation
import SwiftUI

struct SearchView: View {
    @EnvironmentObject var collectionModel: CollectionModel
    @EnvironmentObject var accentColor: AccentColor
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
    var body: some View {
        Spacer()
        if(!searchText.isEmpty)
        {
            Picker(selection: $deviceTypeFilter, label: Label("Device Type", systemImage: "square.3.layers.3d.down.left")) {
                ForEach(deviceTypeFilters, id: \.self) { filter in
                    Image(systemName: (icons[filter] ?? "circle.hexagongrid"))
                }
            }
            .if(UIDevice.current.model.hasPrefix("iPhone"))
            {
                $0.frame(maxWidth: (UIScreen.main.bounds.width * 0.9))
            }

            .if(UIDevice.current.model.hasPrefix("iPad"))
            {
                $0.scaleEffect(0.9)
            }
            .scaledToFit()
            .pickerStyle(.segmented)
        }
        Form
        {
            if(!searchText.isEmpty)
            {
                Section(header: Text(resultsText).fontWeight(.medium).font(.system(.title3, design: .rounded)).textCase(nil)) {}
                .listRowInsets(EdgeInsets(top: 15, leading: 7, bottom: -1000, trailing: 0))
            }
            if(searchText.isEmpty)
            {
                Section(header: Text("Suggestions").font(.subheadline))
                {
                    ForEach(suggestions.choose(4), id: \.self) { suggestion in
                        Button(action: {generator.notificationOccurred(.success); searchText = suggestion})
                        {
                            Label{Text(suggestion).foregroundColor(.primary)} icon: {Image(systemName: "arrow.up.right")}
                            
                        }
                    }
                }
                Picker(selection: $deviceTypeFilter, label: Text("Filter By Device Type").font(.subheadline)) {
                    ForEach(deviceTypeFilters, id: \.self) { filter in
                        Label(filter, systemImage: (icons[filter] ?? "circle.hexagongrid"))
                    }
                }
                .pickerStyle(.inline)
            }
            ForEach(searchResults, id: \.self) { product in
                Section {
                    ProductCardView(product: product, fullSearchable: true).environmentObject(collectionModel).environmentObject(accentColor)
                }
            }
            
        }
        .edgesIgnoringSafeArea(.all)
        .environment(\.defaultMinListHeaderHeight, 20)
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
