//
//  ValuesView.swift
//  Fruitstand
//
//  Created by Armand Sarkani on 1/21/22.
//

import Foundation
import SwiftUI

struct ValuesView: View {
    @EnvironmentObject var collectionModel: CollectionModel
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
                    Label("Total Collection Value", systemImage: "dollarsign.circle.fill")
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

        }
    }
    
}
