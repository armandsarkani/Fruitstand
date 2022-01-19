//
//  ProductView.swift
//  Fruitstand
//
//  Created by Armand Sarkani on 5/17/21.
//

// This module is responsible for the view for displaying a list of products for a given model.

import SwiftUI


// Global variables
let boolToTextScheme1: [Bool: String] = [true: "Yes", false: "No"]
let boolToTextScheme2: [Bool: String] = [true: "On", false: "Off"]
let boolToStatusScheme1: [Bool: String] = [true: "affirmative", false: "negative"]
let boolToStatusScheme2: [Bool: String] = [true: "negative", false: "affirmative"]
let commonColorMapping: [String: Color] = ["black": Color.black, "space black": Color.black, "black & slate": Color.black, "white": Color.white, "white & silver": Color.white, "space gray": Color.gray, "gray": Color.gray, "silver": Color("Silver"), "red": Color.red, "(product)red": Color.red, "green": Color.green, "blue": Color.blue, "gold": Color("Gold"), "rose gold": Color("Rose Gold"), "yellow": Color.yellow, "orange": Color.orange, "coral": Color("Coral"), "sierra blue": Color.blue, "pacific blue": Color.blue, "graphite": Color.gray, "purple": Color.purple, "midnight green": Color.green]
let generator = UINotificationFeedbackGenerator()


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
    @Binding var deviceTypeCounts: [DeviceType: Int]
    @State private var selectedProduct: ProductInfo? = nil
    @State var showInfoModalView: Bool = false
    @State var products: [ProductInfo]
    @State var productDeleted: Bool = false
    @State var confirmationShown: Bool = false
    init(model: String, deviceType: String, deviceTypeCounts: Binding<[DeviceType: Int]>)
    {
        self.model = model
        self.deviceType = deviceType
        self.products = loadMatchingProductsByModel(deviceType: deviceType, model: model)
        _deviceTypeCounts = deviceTypeCounts
    }
    var body: some View {
        List {
            ForEach($products, id: \.self) { $product in
                Section
                {
                    ProductCardView(product: $product, products: $products, confirmationShown: $confirmationShown, selectedProduct: $selectedProduct)
                }
            }
        }
        .textSelection(.enabled)
        .alert(isPresented: $confirmationShown) {
           Alert(
               title: Text("Erase Product?"),
               message: Text("This product will be removed from your collection."),
               primaryButton: .default(
                              Text("Cancel"),
                              action: {}
               ),
               secondaryButton: .destructive(
                              Text("Erase"),
                              action: {
                                  eraseProduct(uuid: selectedProduct!.uuid!);
                                  products = loadMatchingProductsByModel(deviceType: deviceType, model: model);
                                  deviceTypeCounts = loadDeviceTypeCounts()
                                  productDeleted.toggle()
                              })
           )
        }
        .overlay(Group {
            if products.isEmpty {
                VStack(spacing: 15)
                {
                    Image(systemName: getProductIcon(product: ProductInfo(type: DeviceType(rawValue: deviceType), model: model)))
                        .font(.system(size: 72))
                    Text(model)
                        .font(.title)
                        .fontWeight(.bold)
                    Text("Collection is empty.")
                        .font(.body)
                }
            }
        })
        .onAppear {
            products = loadMatchingProductsByModel(deviceType: deviceType, model: model)
            deviceTypeCounts = loadDeviceTypeCounts()
        }
        .navigationTitle(model)
        .navigationBarTitleDisplayMode(.large)
        .navigationBarItems(trailing:
                Button(action: {generator.notificationOccurred(.success); showInfoModalView.toggle()}) {
                Image(systemName: "plus")
                    .imageScale(.large)
                    .frame(height: 96, alignment: .trailing)
            })
        .sheet(isPresented: $showInfoModalView) {
            AddProductView(showInfoModalView: self.$showInfoModalView)
                .onDisappear {
                    deviceTypeCounts = loadDeviceTypeCounts()
                    products = loadMatchingProductsByModel(deviceType: deviceType, model: model)
                }

        }
    }
}


struct ProductCardView: View {
    @Binding var product: ProductInfo
    @Binding var products: [ProductInfo]
    @Binding var confirmationShown: Bool
    @Binding var selectedProduct: ProductInfo?
    @State var showEditModalView: Bool = false
    @Environment(\.colorScheme) var colorScheme
    var body: some View {
        VStack(alignment: .leading)
        {
            SpecificsHeaderView(product: $product)
            Spacer()
            HStack
            {
                if(commonColorMapping.keys.contains(product.color!.lowercased()))
                {
                    ZStack
                    {
                        Circle()
                            .fill(commonColorMapping[product.color!.lowercased()]!)
                            .frame(width: 20, height: 20)
                        Circle().stroke(colorScheme == .dark ? Color.white : Color.gray)
                            .frame(width: 20, height: 20)
                    }
                   
                }
                else
                {
                    ZStack
                    {
                        Circle()
                            .fill(AngularGradient(gradient: Gradient(colors: [.red, .yellow, .green, .blue, .purple, .red]), center: .center))
                            .frame(width: 20, height: 20)
                        Circle().stroke(colorScheme == .dark ? Color.white : Color.gray)
                            .frame(width: 20, height: 20)
                    }
                }
                Text(product.color!)
                HStack {
                    Label("Delete", systemImage: "trash.fill")
                        .hoverEffect(.lift)
                        .labelStyle(.iconOnly)
                        .font(Font.system(.body).bold())
                        .imageScale(.medium)
                        .foregroundColor(.red)
                        .onTapGesture {
                            generator.notificationOccurred(.error)
                            selectedProduct = product
                            confirmationShown.toggle()
                        }
                    Spacer().frame(width: 30)
                    Label("Edit", systemImage: "pencil")
                        .hoverEffect(.lift)
                        .labelStyle(.iconOnly)
                        .font(Font.system(.body).bold())
                        .imageScale(.large)
                        .foregroundColor(.blue)
                        .onTapGesture {
                            showEditModalView.toggle()
                            generator.notificationOccurred(.success)
                        }
                }.frame(maxWidth: .infinity, alignment: .trailing)
               
            }
            
            Spacer()
        }
        .sheet(isPresented: $showEditModalView) {
            EditProductView(product: product, showEditModalView: $showEditModalView)
                .onDisappear {
                    products = loadMatchingProductsByModel(deviceType: product.type!.id, model: product.model!)
                }

        }
        HorizontalTwoAttributeView(descriptionLeft: "Working status", dataLeft: (product.workingStatus != nil ? product.workingStatus!.id: "Unknown"), descriptionRight: "Year acquired", dataRight: (product.yearAcquired != nil ? String(product.yearAcquired!): "Unknown"))
        HorizontalTwoAttributeView(descriptionLeft: "Condition", dataLeft: (product.condition != nil ? product.condition!.id: "Unknown"), descriptionRight: "Acquired as", dataRight: (product.acquiredAs != nil ? product.acquiredAs!.id: "Unknown"))
        HorizontalTwoAttributeView(descriptionLeft: "Estimated value", dataLeft: (product.estimatedValue != nil ?  String(format: "$%d", locale: Locale.current, product.estimatedValue!): "Unknown"), descriptionRight: "Warranty", dataRight: (product.warranty != nil ? product.warranty!.id: "Unknown"))
        HorizontalTwoBooleanView(descriptionLeft: "Physical damage", dataLeft: boolToTextScheme1[product.physicalDamage ?? false]!, descriptionRight: "Original box", dataRight: boolToTextScheme1[product.originalBox ?? false]!, leftStatus: boolToStatusScheme2[product.physicalDamage ?? false]!, rightStatus: boolToStatusScheme1[product.originalBox ?? false]!)
        SpecificsCardView(product: $product)
        if(product.comments != nil && product.comments != "") {
            HorizontalOneAttributeView(description: "Comments", data: product.comments!, alignment: .leading)

        }
    }
}

struct SpecificsHeaderView: View {
    @Binding var product: ProductInfo
    var body: some View {
        if(product.type == DeviceType.Mac) {
            if(product.model == "Other" || product.model == "Earlier Models")
            {
                Spacer()
                Text("\(product.otherModel ?? "Unknown Model") (\(product.year ?? "Unknown Year")) \(product.screenSize != nil ? "\(String(product.screenSize!))-inch": "")")
                    .fontWeight(.bold)
                    .font(.title3)
                
            }
            else {
                Spacer()
                Text("\(product.year ?? "Unknown Year") \(product.screenSize != nil ? "\(String(product.screenSize!))-inch": "")")
                    .fontWeight(.bold)
                    .font(.title3)
            }
            
        }
        else
        {
            if(product.model == "Other")
            {
                Spacer()
                Text("\(product.otherModel ?? "Unknown Model")")
                    .fontWeight(.bold)
                    .font(.title3)
            }
        }
        if(product.type == DeviceType.iPhone)
        {
            Spacer()
            Text(product.storage ?? "Unknown Storage")
                .fontWeight(.bold)
                .font(.title3)
            
        }
        else if(product.type == DeviceType.iPad)
        {
            Spacer()
            Text("\(product.storage ?? "Unknown Storage") \(product.connectivity != nil ? product.connectivity!.id: "")")
                .fontWeight(.bold)
                .font(.title3)
            
        }
        else if(product.type == DeviceType.AppleWatch)
        {
            Spacer()
            Text("\(product.caseSize != nil ? "\(String(product.caseSize!))mm": "") \(product.caseType != nil ? product.caseType!.id: "") \(product.watchConnectivity != nil ? product.watchConnectivity!.id: "")")
                .fontWeight(.bold)
                .font(.title3)
            
        }
        else if(product.type == DeviceType.AirPods)
        {
            Spacer()
            Text((product.AirPodsCaseType != nil ? product.AirPodsCaseType!.id: "Unknown Case Type"))
                .fontWeight(.bold)
                .font(.title3)
        }
        else if(product.type == DeviceType.AppleTV)
        {
            Spacer()
            Text(product.storage ?? "Unknown Storage")
                .fontWeight(.bold)
                .font(.title3)
        }
        else if(product.type == DeviceType.iPod)
        {
            Spacer()
            Text(product.storage ?? "Unknown Storage")
                .fontWeight(.bold)
                .font(.title3)
        }
    }
}

struct SpecificsCardView: View {
    @Binding var product: ProductInfo
    let carrierLockStatusMap: [CarrierLockStatus: String] = [CarrierLockStatus.Locked: "negative", CarrierLockStatus.Unlocked: "affirmative", CarrierLockStatus.Unknown: "unknown"]
    let ESNStatusMap: [ESNStatus: String] = [ESNStatus.Bad: "negative", ESNStatus.Clean: "affirmative", ESNStatus.Unknown: "unknown"]
    var body: some View {
        if(product.type == DeviceType.iPhone) {
            HorizontalMixedAttributeBooleanView(descriptionLeft: "Carrier", dataLeft: product.carrier ?? "Unknown", descriptionRight: "Carrier lock status", dataRight: (product.carrierLockStatus != nil ? product.carrierLockStatus!.id: "Unknown"), rightStatus: carrierLockStatusMap[product.carrierLockStatus ?? CarrierLockStatus.Unknown] ?? "unknown")
            HorizontalTwoBooleanView(descriptionLeft: "IMEI/ESN status", dataLeft: (product.ESNStatus != nil ? product.ESNStatus!.id: "Unknown"), descriptionRight: "Activation Lock", dataRight: boolToTextScheme2[product.activationLock ?? false]!, leftStatus: ESNStatusMap[product.ESNStatus ?? ESNStatus.Unknown] ?? "unknown", rightStatus: boolToStatusScheme2[product.activationLock ?? false]!)
            
        }
        if(product.type == DeviceType.iPad) {
            HorizontalOneBooleanView(description: "Activation Lock", data: boolToTextScheme2[product.activationLock ?? false]!, status: boolToStatusScheme2[product.activationLock ?? false]!, alignment: .leading)
            
        }
        if(product.type == DeviceType.Mac) {
            HorizontalTwoAttributeView(descriptionLeft: "Processor", dataLeft: product.processor ?? "Unknown", descriptionRight: "Storage", dataRight: product.storage ?? "Unknown")
            HorizontalMixedAttributeBooleanView(descriptionLeft: "Memory", dataLeft: product.memory ?? "Unknown", descriptionRight: "Activation Lock", dataRight: boolToTextScheme2[product.activationLock ?? false]!, rightStatus: boolToStatusScheme2[product.activationLock ?? false]!)
            
        }
        if(product.type == DeviceType.AppleWatch) {
            HorizontalOneAttributeView(description: "Original bands included", data: product.originalBands ?? "Unknown", alignment: .leading)
            
        }
        if(product.type == DeviceType.AppleTV) {
            HorizontalOneBooleanView(description: "Has Remote", data: boolToTextScheme1[product.hasRemote ?? false]!, status: boolToStatusScheme1[product.hasRemote ?? false]!, alignment: .leading)
            
        }
        if(product.type == DeviceType.iPod) {
            HorizontalOneBooleanView(description: "Activation Lock", data: boolToTextScheme2[product.activationLock ?? false]!, status: boolToStatusScheme2[product.activationLock ?? false]!, alignment: .leading)
        }
        
    }
}
    
struct HorizontalOneAttributeView: View {
    var description: String
    var data: String
    var alignment: HorizontalAlignment
    var body: some View {
        VStack(alignment: alignment)
        {
            Text(description)
                .font(.subheadline)
                .foregroundColor(.gray)
                .fixedSize()
            Spacer(minLength: 5)
            Text(data)
                .fixedSize(horizontal: false, vertical: true)
            Spacer(minLength: 5)
        }
    }
}

struct HorizontalOneBooleanView: View {
    var description: String
    var data: String
    var status: String
    var alignment: HorizontalAlignment
    let statusToImage: [String: String] = ["affirmative": "checkmark.circle.fill", "negative": "exclamationmark.circle.fill", "unknown": "questionmark.circle.fill" ]
    let statusToColor: [String: Color] = ["affirmative": Color.green, "negative": Color.red, "unknown": Color.yellow]
    var body: some View {
        VStack(alignment: alignment)
        {
            Text(description)
                .font(.subheadline)
                .foregroundColor(.gray)
                .fixedSize()
            Spacer(minLength: 5)
            Label(data, systemImage: statusToImage[status]!).foregroundColor(statusToColor[status])
                .fixedSize(horizontal: false, vertical: true)
            Spacer(minLength: 5)

        }
    }
}

struct HorizontalTwoAttributeView: View {
    var descriptionLeft: String
    var dataLeft: String
    var descriptionRight: String
    var dataRight: String
    var body: some View {
        HStack
        {
            HorizontalOneAttributeView(description: descriptionLeft, data: dataLeft, alignment: .leading)
                .frame(maxWidth: .infinity, alignment: .leading)
            Divider()
            HorizontalOneAttributeView(description: descriptionRight, data: dataRight, alignment: .trailing)
                .frame(maxWidth: .infinity, alignment: .trailing)
            
        }

    }
}

struct HorizontalTwoBooleanView: View {
    var descriptionLeft: String
    var dataLeft: String
    var descriptionRight: String
    var dataRight: String
    var leftStatus: String
    var rightStatus: String
    let statusToImage: [String: String] = ["affirmative": "checkmark.circle.fill", "negative": "exclamationmark.circle.fill", "unknown": "questionmark.circle.fill" ]
    let statusToColor: [String: Color] = ["affirmative": Color.green, "negative": Color.red, "unknown": Color.yellow]
    var body: some View {
        HStack
        {
            HorizontalOneBooleanView(description: descriptionLeft, data: dataLeft, status: leftStatus, alignment: .leading)
                .frame(maxWidth: .infinity, alignment: .leading)
            Divider()
            HorizontalOneBooleanView(description: descriptionRight, data: dataRight, status: rightStatus, alignment: .trailing)
                .frame(maxWidth: .infinity, alignment: .trailing)
        }

    }
}

struct HorizontalMixedAttributeBooleanView: View {
    var descriptionLeft: String
    var dataLeft: String
    var descriptionRight: String
    var dataRight: String
    var rightStatus: String
    let statusToImage: [String: String] = ["affirmative": "checkmark.circle.fill", "negative": "exclamationmark.circle.fill", "unknown": "questionmark.circle.fill" ]
    let statusToColor: [String: Color] = ["affirmative": Color.green, "negative": Color.red, "unknown": Color.yellow]
    var body: some View {
        HStack
        {
            HorizontalOneAttributeView(description: descriptionLeft, data: dataLeft, alignment: .leading)
                .frame(maxWidth: .infinity, alignment: .leading)
            Divider()
            HorizontalOneBooleanView(description: descriptionRight, data: dataRight, status: rightStatus, alignment: .trailing)
                .frame(maxWidth: .infinity, alignment: .trailing)
            
        }

    }
}
