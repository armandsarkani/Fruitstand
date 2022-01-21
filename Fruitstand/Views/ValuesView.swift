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
                    .font(.system(size: 72))
                Text("Values")
                    .font(.title)
                    .fontWeight(.bold)
                Text("Collection is empty.")
                    .font(.body)
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
               Section("Total Value By Device Type")
                {
                    ForEach(DeviceType.allCases, id: \.self) { key in
                        HStack
                        {
                            Label(key.id, systemImage: icons[key.id]!)
                                .fixedSize()
                            Spacer()
                            Text(String(format: "$%d", locale: Locale.current, getDeviceTypeValues(collection: collectionModel.collection)[key]!))
                                .foregroundColor(.gray)
                        }
                    }
                }
                Section("Average Value By Device Type")
                 {
                     ForEach(DeviceType.allCases, id: \.self) { key in
                         HStack
                         {
                             Label(key.id, systemImage: icons[key.id]!)
                                 .fixedSize()
                             Spacer()
                             Text(String(format: "$%.2f", locale: Locale.current,        getAverageValues(collection: collectionModel.collection, deviceTypeCounts: collectionModel.getDeviceTypeCounts())[key]!))
                                 .foregroundColor(.gray)
                         }
                     }
                 }
            }
            .navigationTitle("Values")
            .navigationBarTitleDisplayMode(.inline)

        }
    }
    
}
