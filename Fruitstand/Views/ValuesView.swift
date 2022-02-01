//
//  ValuesView.swift
//  Fruitstand
//
//  Created by Armand Sarkani on 1/21/22.
//

import Foundation
import SwiftUI
import AlertToast

struct ValuesView: View {
    @EnvironmentObject var collectionModel: CollectionModel
    @State private var collectionFull: Bool = false
    @State var showInfoModalView: Bool = false
    @State private var showToast: Bool = false
    @EnvironmentObject var accentColor: AccentColor
    var body: some View {
        if(collectionModel.isEmpty()) {
            VStack(spacing: 15)
            {
                Image(systemName: "dollarsign.circle.fill")
                    .font(.system(size: 72, design: .rounded))
                Text("Values")
                    .font(.system(.title, design: .rounded))
                    .fontWeight(.bold)
                Text("Collection is empty.")
            }
        }
       else
        {
            List {
                HStack
                {
                    Label("Collection Value", systemImage: "dollarsign.circle.fill")
                        .fixedSize()
                    Spacer()
                    Text(String(format: "$%d", locale: Locale.current, getTotalCollectionValue(collection: collectionModel.collection)))
                        .foregroundColor(.gray)
                }
                Section(header: Text("Total Value By Device Type").font(.subheadline))
                {
                    ForEach(getDeviceTypeValuesSorted(collection: collectionModel.collection), id: \.self) { element in
                        HStack
                        {
                            Label(element.deviceType.id, systemImage: icons[element.deviceType.id]!)
                                .fixedSize()
                            Spacer()
                            Text(String(format: "$%d", locale: Locale.current, element.totalValue ?? 0))
                                .foregroundColor(.gray)
                        }
                    }
                }
                Section(header: Text("Average Value By Device Type").font(.subheadline))
                 {
                     ForEach(getAverageValuesSorted(collection: collectionModel.collection, deviceTypeCounts: collectionModel.getDeviceTypeCounts()), id: \.self) { element in
                         HStack
                         {
                             Label(element.deviceType.id, systemImage: icons[element.deviceType.id]!)
                                 .fixedSize()
                             Spacer()
                             Text(String(format: "$%.2f", locale: Locale.current, element.averageValue ?? 0.0))
                                 .foregroundColor(.gray)
                         }
                     }
                 }
            }
            .navigationTitle("Values")
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
    
}

