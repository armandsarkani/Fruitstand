//
//  ProductListView.swift
//  Fruitstand
//
//  Created by Armand Sarkani on 1/21/22.
//

import Foundation
import SwiftUI
import AlertToast


struct ProductListView: View {
    var deviceType: DeviceType
    @State private var collectionFull: Bool = false
    @State private var showToast: Bool = false
    @EnvironmentObject var collectionModel: CollectionModel
    @EnvironmentObject var accentColor: AccentColor
    @State var showInfoModalView: Bool = false
    @State private var searchText = ""
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
    init(deviceType: DeviceType)
    {
        self.deviceType = deviceType
    }
    var searchResults: [ModelAndCount] {
           if searchText.isEmpty {
               return collectionModel.modelList[deviceType]!
           }
           else {
               return collectionModel.modelList[deviceType]!.filter { $0.model.lowercased().contains(searchText.lowercased())}
           }
    }
    
    var body: some View {
        GeometryReader { geo in
            List
            {
                if(!searchText.isEmpty)
                {
                    Section(header: Text(resultsText).fontWeight(.medium).font(.system(.title3, design: .rounded)).textCase(nil)) {}
                    .listRowInsets(EdgeInsets(top: 20, leading: 7, bottom: -500, trailing: 0))
                }
                ForEach(searchResults, id: \.self) { model in
                    NavigationLink(destination: ProductView(model: model.model, deviceType: deviceType, fromSearch: false)              .environmentObject(collectionModel).environmentObject(accentColor))
                        {
                            Label(model.model, systemImage: getProductIcon(product: ProductInfo(type: DeviceType(rawValue: deviceType.rawValue), model: model.model)))
                                .frame(width: 0.625*geo.size.width, alignment: .leading)
                                .if(model.model.count < 30) {
                                    $0.fixedSize()
                                }
                            Spacer()
                            Text(String(model.count!))
                                    .fixedSize()
                                .foregroundColor(.gray)
                        
                    }
                }
            }
        }
        .searchable(text: $searchText, placement: .navigationBarDrawer(displayMode: .automatic)).autocapitalization(.none)
        .overlay(Group {
            if(collectionModel.modelList[deviceType]!.isEmpty){
                VStack(spacing: 15)
                {
                    Image(systemName: icons[deviceType.rawValue]!)
                        .font(.system(size: 72, design: .rounded))
                    Text(deviceType.rawValue)
                        .font(.system(.title, design: .rounded))
                        .fontWeight(.bold)
                    Text("Collection is empty.")
                }
            }
        })
        .navigationTitle(Text(deviceType.rawValue))
        .navigationBarTitleDisplayMode(.large)
        .if(UIDevice.current.model.hasPrefix("iPhone")) {
            $0.toolbar {
                ToolbarItem(placement: .navigationBarTrailing)
                {
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
                    }
                }
            }
        }
        .if(UIDevice.current.model.hasPrefix("iPhone")) {
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
    }
}
