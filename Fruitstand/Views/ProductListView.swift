//
//  ProductListView.swift
//  Fruitstand
//
//  Created by Armand Sarkani on 1/21/22.
//

import Foundation
import SwiftUI
import AlertToast

enum ModelSortStyle: String, CaseIterable, Identifiable, Codable {
    case None
    case CountAscending = "Lowest to Highest Count"
    case CountDescending = "Highest to Lowest Count"
    var id: String { self.rawValue }
    var images: [String] {
        if(self == ModelSortStyle.CountAscending) {
            return ["arrow.up", "arrow.up.circle.fill"]
        }
        else if(self == ModelSortStyle.CountDescending) {
            return ["arrow.down", "arrow.down.circle.fill"]
        }
        return ["list.bullet", "arrow.up.arrow.down.circle"]
    }
    static let allSortedCases: [ModelSortStyle] = [.CountAscending, .CountDescending]
}

struct ProductListView: View {
    var deviceType: DeviceType
    @State private var collectionFull: Bool = false
    @State private var showToast: Bool = false
    @EnvironmentObject var collectionModel: CollectionModel
    @EnvironmentObject var accentColor: AccentColor
    @State var showInfoModalView: Bool = false
    @Environment(\.horizontalSizeClass) var horizontalSizeClass
    @State var sortStyle: ModelSortStyle = ModelSortStyle.None
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
        var results: [ModelAndCount] = []
        if searchText.isEmpty {
            results = collectionModel.modelList[deviceType]!
        }
        else {
            results = collectionModel.modelList[deviceType]!.filter { $0.model.lowercased().contains(searchText.lowercased())}
        }
        switch(sortStyle) {
            case .CountAscending:
                return results.sorted{$0.count! < $1.count!}
            case .CountDescending:
                return results.sorted{$0.count! > $1.count!}
            default:
                return results
        }
    }
    
    var body: some View {

        GeometryReader { geo in
            List
            {
                if(!searchText.isEmpty && !searchResults.isEmpty)
                {
                    Section(header: Text(resultsText).fontWeight(.medium).font(.system(.title3, design: .rounded)).textCase(nil).foregroundColor(.secondary)) {}
                    .listRowInsets(EdgeInsets(top: 20, leading: 7, bottom: -20, trailing: 0))
                }
                ForEach(searchResults, id: \.self) { model in
                    NavigationLink(destination: ProductView(model: model.model, deviceType: deviceType, fromSearch: false).environmentObject(collectionModel).environmentObject(accentColor))
                        {
                            Label(model.model, systemImage: collectionModel.findReferenceProductForModel(model: model.model, deviceType: deviceType).getProductIcon())
                                .frame(width: 0.625*geo.size.width, alignment: .leading)
                                .if(model.model.count < 30) {
                                    $0.fixedSize()
                                }
                            Spacer()
                            Text(String(model.count!))
                                    .fixedSize()
                                .foregroundColor(.secondary)
                        
                    }                    
                }
            }
            .listStyle(InsetGroupedListStyle())
        }
        .introspectTableView { introspect in
            introspect.keyboardDismissMode = .onDrag
        }
        .searchable(text: $searchText, placement: .navigationBarDrawer(displayMode: .automatic)).autocapitalization(.none)
        .overlay(Group {
            if(searchResults.isEmpty){
                if(searchText.isEmpty) {
                    VStack(spacing: 15)
                    {
                        Image(systemName: icons[deviceType.rawValue] ?? "questionmark.folder.fill")
                            .font(.system(size: 72, design: .rounded))
                            .foregroundColor(accentColor.color)
                        Text(deviceType.rawValue)
                            .font(.system(.title, design: .rounded))
                            .fontWeight(.bold)
                        Text("Collection is empty.")
                    }
                }
                else {
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
            }
        })

        .navigationTitle(Text(deviceType.rawValue))
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing)
            {
                HStack
                {
                    #if targetEnvironment(macCatalyst)
                    ModelSortMenuViewMac(sortStyle: $sortStyle).environmentObject(accentColor)
                    #else
                    ModelSortMenuView(sortStyle: $sortStyle)
                    #endif
                    if(UIDevice.current.model.hasPrefix("iPhone") || horizontalSizeClass == .compact) {
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
                            .keyboardShortcut("a", modifiers: .command)
                    }
                }
            }
        }
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
        
    }
}

struct ModelSortMenuView: View {
    @Binding var sortStyle: ModelSortStyle
    var body: some View {
        Menu {
            Picker("None", selection: $sortStyle) {
                ForEach([ModelSortStyle.None]) { style in
                    Text(style.rawValue)
                        .tag(style)
                }
            }
            .pickerStyle(InlinePickerStyle())
            Picker("Sort Style", selection: $sortStyle) {
                ForEach(ModelSortStyle.allSortedCases) { style in
                    Label(style.rawValue, systemImage: style.images[0])
                        .tag(style)
                }
            }
            .pickerStyle(InlinePickerStyle())
        } label: {
            Label {
                Text("Sort")
                    .font(.system(size: 18, design: .rounded))
            } icon: {Image(systemName: sortStyle.images[1]).imageScale(.large)}.labelStyle(CustomSortLabelStyle())
        }
    }
}

struct ModelSortMenuViewMac: View {
    @Binding var sortStyle: ModelSortStyle
    @EnvironmentObject var accentColor: AccentColor
    var body: some View {
        Picker(selection: $sortStyle, label: Image(systemName: sortStyle.images[1]).imageScale(.large).foregroundColor(accentColor.color))
        {
            ForEach(ModelSortStyle.allCases) { style in
                Text(style.rawValue)
                    .tag(style)
            }
        }
        .pickerStyle(MenuPickerStyle())
    }
}
