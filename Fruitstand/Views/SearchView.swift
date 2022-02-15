//
//  SearchView.swift
//  Fruitstand
//
//  Created by Armand Sarkani on 1/21/22.
//

import Foundation
import SwiftUI
import AlertToast
import Combine
import Introspect

struct SearchView: View {
    @EnvironmentObject var collectionModel: CollectionModel
    @EnvironmentObject var accentColor: AccentColor
    @Environment(\.horizontalSizeClass) var horizontalSizeClass
    @State private var collectionFull: Bool = false
    @State private var showToast: Bool = false
    @State var showInfoModalView: Bool = false
    @State var previousModelDetailView: String?
    @State private var searchText = ""
    @State private var cardTapped = false
    @State var deviceTypeFilter: String = "All Devices"
    @State var sortStyle: SortStyle = SortStyle.None
    @State private var showEditToast: Bool = false

    let deviceTypeFilters = ["All Devices", "Mac", "iPhone", "iPad", "Apple Watch", "AirPods", "Apple TV", "iPod"]
    var suggestions: [String] {
        return getSearchSuggestions(deviceTypeFilter: deviceTypeFilter)
    }
    var searchResults: [ProductInfo] {
        if searchText.isEmpty {
            return []
        }
        var products: [ProductInfo] = []
        if(deviceTypeFilter != "All Devices")
        {
            if(searchText.lowercased() == "entire collection") {
                products = collectionModel.collectionArray.filter {$0.type == DeviceType(rawValue: deviceTypeFilter)}

            }
            else {
                products = collectionModel.collectionArray.filter { $0.contains(searchText: searchText) && $0.type == DeviceType(rawValue: deviceTypeFilter)}
            }
        }
        else {
            if(searchText.lowercased() == "entire collection") {
                products = collectionModel.collectionArray
            }
            else {
                products = collectionModel.collectionArray.filter {$0.contains(searchText: searchText)}
            }
        }
        switch(sortStyle) {
            case .YearAcquiredAscending:
                return products.sorted{$0.yearAcquired! < $1.yearAcquired!}
            case .YearAcquiredDescending:
                return products.sorted{$0.yearAcquired! > $1.yearAcquired!}
            case .EstimatedValueAscending:
                return products.sorted{$0.estimatedValue! < $1.estimatedValue!}
            case .EstimatedValueDescending:
                return products.sorted{$0.estimatedValue! > $1.estimatedValue!}
            default:
                return products
        }
    }

    var resultsText: String {
        if searchText.isEmpty {
            return ""
        }
        else {
            if(searchResults.count == 1)
            {
                return "\(searchResults.count) Result"
            }
            else {
                return "\(searchResults.count) Results"
            }
        }
    }
    var body: some View {
       Form {
           if(!searchText.isEmpty && !searchResults.isEmpty)
           {
               Section(header: Text(resultsText).fontWeight(.medium).font(.system(.title3, design: .rounded)).textCase(nil).foregroundColor(.secondary)) {}
               .listRowInsets(EdgeInsets(top: 20, leading: 7, bottom: -20, trailing: 0))
           }
           if(searchText.isEmpty)
           {
               Section(header: Text("Suggestions").customSectionHeader())
               {
                   ForEach(suggestions.choose(4), id: \.self) { suggestion in
                       Button(action: {generator.notificationOccurred(.success); searchText = suggestion})
                       {
                           Label{Text(suggestion).foregroundColor(.primary)} icon: {Image(systemName: "arrow.up.right")}
                       }
                   }
                   Button(action: {generator.notificationOccurred(.success); searchText = "Entire Collection"})
                   {
                       Label{Text("Entire Collection").foregroundColor(accentColor.color)} icon: {
                           Image(systemName: "rectangle.stack.fill")
                       }
                   }
               }
               Picker(selection: $deviceTypeFilter, label: Text("Filter By Device Type").customSectionHeader()) {
                   ForEach(deviceTypeFilters, id: \.self) { filter in
                       Label(filter, systemImage: (icons[filter] ?? "circle.hexagongrid"))
                   }
               }
               .pickerStyle(.inline)
           }
           ForEach(searchResults, id: \.self) { product in
               Section {
                   ProductCardView(product: product, fullySearchable: true, showButtons: true, showEditToast: $showEditToast).environmentObject(collectionModel)
                   if(collectionModel.getModelCount(model: product.model!) > 1)
                   {
                       NavigationLink(destination: ProductView(model: product.model!, deviceType: product.type!, fromSearch: true).environmentObject(collectionModel).environmentObject(accentColor))
                       {
                           Label("View All", systemImage: "rectangle.stack")
                               .foregroundColor(accentColor.color)
                       }
                   }
               }
           }
       }
       .accentColor(accentColor.color)
       .toast(isPresenting: $showEditToast, duration: 1) {
           AlertToast(type: .complete(accentColor.color), title: "Product Edited", style: AlertToast.AlertStyle.style(titleFont: Font.system(.title3, design: .rounded).bold()))
       }
       .toolbar {
           ToolbarItemGroup(placement: .bottomBar)
           {
                if(!searchText.isEmpty)
                {
                    #if targetEnvironment(macCatalyst)
                    SortMenuViewMac(sortStyle: $sortStyle).environmentObject(accentColor)
                    #else
                    SortMenuView(sortStyle: $sortStyle)
                    #endif
                    Picker(selection: $deviceTypeFilter, label: Label("Device Type", systemImage: "square.3.layers.3d.down.left"))
                    {
                        ForEach(deviceTypeFilters, id: \.self) { filter in
                            Image(systemName: icons[filter] ?? "circle.hexagongrid")
                        }
                    }
                    .pickerStyle(SegmentedPickerStyle())
                    .ignoresSafeArea(.keyboard, edges:.all)
                }
            }
           ToolbarItem(placement: .navigationBarTrailing)
           {
               if(UIDevice.current.model.hasPrefix("iPhone") || horizontalSizeClass == .compact) {
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
                       .keyboardShortcut("a", modifiers: .command)
               }
           }
       }
       .overlay(Group {
           if(searchResults.isEmpty && !searchText.isEmpty){
               VStack(spacing: 15)
               {
                   Image(systemName: "questionmark.folder.fill")
                       .font(.system(size: 72, design: .rounded))
                       .foregroundColor(accentColor.color)
                   Text("No Results Found")
                       .font(.system(.title, design: .rounded))
                       .fontWeight(.bold)
                   Text("Try your search again.")
               }
           }
       })
       .if(UIDevice.current.model.hasPrefix("iPhone") || horizontalSizeClass == .compact) {
           $0.alert(isPresented: $collectionFull) {
               Alert(
                   title: Text("1000 Product Limit Reached"),
                   message: Text("Remove at least one product from your collection before adding new ones."),
                   dismissButton: .default(Text("OK"))
               )
           }
       }
       .toast(isPresenting: $showToast, duration: 1) {
           AlertToast(type: .complete(accentColor.color), title: "Product Added", style: AlertToast.AlertStyle.style(titleFont: Font.system(.title3, design: .rounded).bold()))
       }
       .sheet(isPresented: $showInfoModalView, onDismiss: {
           if(collectionModel.productJustAdded) {
               showToast.toggle()
               collectionModel.productJustAdded = false
           }
       }) {
           AddProductView(showInfoModalView: self.$showInfoModalView).environmentObject(collectionModel).environmentObject(accentColor)
           
       }
       .environment(\.defaultMinListHeaderHeight, 20)
       .searchable(text: $searchText, placement: .navigationBarDrawer(displayMode: .always), prompt: "Search all products").autocapitalization(.none)
       .introspectTableView { introspect in
           introspect.keyboardDismissMode = .onDrag
       }
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
            return ["iPhone 13", "iPhone 13 mini", "iPhone 13 Pro", "iPhone 13 Pro Max", "iPhone SE", "Unable to power on", "First iPhone", "64GB", "128GB", "256GB", "512GB", "Activation Lock"]
        }
        else if(deviceTypeFilter == "iPad")
        {
            return ["iPad Pro", "iPad Air", "iPad mini", "Unable to power on", "First iPad", "64GB", "128GB", "256GB", "512GB", "Activation Lock"]
        }
        else if(deviceTypeFilter == "Mac")
        {
            return ["M1 Max", "M1", "2019", "2020", "2021", "2022", "Intel Core i5", "Intel Core i7", "Intel Core i9", "MacBook Air (retina)", "MacBook Pro (retina)", "MacBook Pro (unibody)", "iMac Pro", "Retina", "Unable to power on", "SSD", "First Mac", "Activation Lock"]
        }
        else if(deviceTypeFilter == "Apple Watch")
        {
            return ["Apple Watch SE", "Apple Watch Series 7", "Apple Watch Series 6", "Unable to power on", "First Apple Watch", "Titanium", "Stainless steel", "Aluminum", "Activation Lock"]

        }
        else if(deviceTypeFilter == "AirPods")
        {
            return ["AirPods Pro", "3rd gen", "AirPods Max", "First AirPods", "MagSafe"]

        }
        else if(deviceTypeFilter == "Apple TV")
        {
            return ["Apple TV 4K", "Apple TV HD", "64GB", "32GB", "First Apple TV"]
        }
        else
        {
            return ["32GB", "16GB", "8GB", "iPod classic", "iPod touch", "iPod nano", "iPod shuffle", "iPod + HP", "First iPod"]

        }
    }
}

struct PreventCollapseView: View {

    private var mostlyClear = Color(UIColor(white: 0.0, alpha: 0.0005))

    var body: some View {
        Rectangle()
            .fill(mostlyClear)
            .frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: 1)
    }
}
