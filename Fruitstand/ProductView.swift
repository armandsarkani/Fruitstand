//
//  ProductView.swift
//  Fruitstand
//
//  Created by Armand Sarkani on 5/17/21.
//

import SwiftUI

func OptionalBinding<T>(_ binding: Binding<T?>, _ defaultValue: T) -> Binding<T> {
    return Binding<T>(get: {
        return binding.wrappedValue ?? defaultValue
    }, set: {
        binding.wrappedValue = $0
    })
}

func ??<T> (left: Binding<T?>, right: T) -> Binding<T> {
    return OptionalBinding(left, right)
}

struct ProductView: View {
    var model: String
    var deviceType: String
    @State var products: [ProductInfo]
    init(model: String, deviceType: String)
    {
        self.model = model
        self.deviceType = deviceType
        self.products = loadMatchingProductsByModel(deviceType: deviceType, model: model)
    }
    var body: some View {
        List {
            ForEach($products, id: \.self) { $product in
                Section
                {
                    ProductCardView(product: $product)
                }
            }
        }
        .navigationTitle(model)
    }
}

struct ProductCardView: View {
    @Binding var product: ProductInfo
    var body: some View {
        VStack(alignment: .leading)
        {
            Text(product.model!)
                .font(.title2)
                .fontWeight(.bold)
        }
        HStack
        {
            VStack(alignment: .leading)
            {
                Text("Working status")
                    .font(.subheadline)
                    .foregroundColor(.gray)
                    .fixedSize()
                Text(product.workingStatus!.id)
                    .fixedSize()
            }
            Divider().frame(maxWidth: 500)
            VStack(alignment: .trailing)
            {
                Text("Acquired in")
                    .fixedSize()
                    .font(.subheadline)
                    .foregroundColor(.gray)
                Text(String(product.yearAcquired!))
                    .fixedSize()
            }
            
        }
    
    }
}
