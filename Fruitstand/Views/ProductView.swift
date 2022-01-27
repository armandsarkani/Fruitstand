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
let commonColorMapping: [String: Color] = ["black": Color.black, "space black": Color.black, "black & slate": Color.black, "white": Color.white, "white & silver": Color.white, "space gray": Color.gray, "gray": Color.gray, "silver": Color("Silver"), "red": Color.red, "(product)red": Color.red, "product red": Color.red, "green": Color.green, "blue": Color.blue, "gold": Color("Gold"), "rose gold": Color("Rose Gold"), "yellow": Color.yellow, "orange": Color.orange, "coral": Color("Coral"), "sierra blue": Color.cyan, "pacific blue": Color.blue, "graphite": Color.gray, "purple": Color.purple, "midnight green": Color.green, "starlight": Color("Starlight"), "platinum": Color("Starlight"), "blueberry": Color.blue, "key lime": Color.green, "tangerine": Color.orange, "indigo": Color.indigo, "jet black": Color.black, "pink": Color.pink]
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
    @EnvironmentObject var collectionModel: CollectionModel
    @EnvironmentObject var accentColor: AccentColor
    var model: String
    var deviceType: DeviceType
    @State var showInfoModalView: Bool = false
    @State private var searchText = ""
    @State private var collectionFull: Bool = false
    init(model: String, deviceType: DeviceType)
    {
        self.model = model
        self.deviceType = deviceType
    }
    var searchResults: [ProductInfo] {
           if searchText.isEmpty {
               return collectionModel.loadMatchingProductsByModel(deviceType: deviceType, model: model)
           }
           else {
               return collectionModel.loadMatchingProductsByModel(deviceType: deviceType, model: model).filter { $0.contains(searchText: searchText)}
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
        List {
            if(!searchText.isEmpty)
            {
                Section(header: Text(resultsText).fontWeight(.medium).font(.title3).textCase(nil)) {}
                .listRowInsets(EdgeInsets(top: 20, leading: 7, bottom: -500, trailing: 0))
            }
            ForEach(searchResults, id: \.self) { product in
                Section
                {
                    ProductCardView(product: product, fullSearchable: false).environmentObject(collectionModel).environmentObject(accentColor)
                }
            }
        }
        .searchable(text: $searchText, placement: .navigationBarDrawer(displayMode: .automatic)).autocapitalization(.none)
        .overlay(Group {
            if collectionModel.loadMatchingProductsByModel(deviceType: deviceType, model: model).isEmpty {
                VStack(spacing: 15)
                {
                    Image(systemName: getProductIcon(product: ProductInfo(type: DeviceType(rawValue: deviceType.rawValue), model: model)))
                        .font(.system(size: 72))
                    Text(model)
                        .font(.title)
                        .fontWeight(.bold)
                    Text("Collection is empty.")
                        .font(.body)
                }
            }
        })
        .navigationTitle(model)
        .navigationBarTitleDisplayMode(.large)
        .if(UIDevice.current.model.hasPrefix("iPhone")) {
            $0.navigationBarItems(trailing:
                    HStack {
                NavigationLink(destination: SearchView().environmentObject(collectionModel).environmentObject(accentColor))
                        {
                            Image(systemName: "magnifyingglass")
                                .imageScale(.large)
                                .frame(height: 96, alignment: .trailing)
                        }
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
            })
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
        .sheet(isPresented: $showInfoModalView) {
            AddProductView(showInfoModalView: self.$showInfoModalView).environmentObject(collectionModel).environmentObject(accentColor)
        }
    }
}



struct ProductCardView: View {
    @EnvironmentObject var collectionModel: CollectionModel
    @EnvironmentObject var accentColor: AccentColor
    let workingStatusMap: [WorkingStatus: String] = [WorkingStatus.NotWorking: "negative", WorkingStatus.MostlyWorking: "neutral", WorkingStatus.Working: "affirmative"]
    var product: ProductInfo
    var fullSearchable: Bool
    @State var confirmationShown: Bool = false
    @State private var selectedProduct: ProductInfo? = nil
    @State var showEditModalView: Bool = false
    @Environment(\.colorScheme) var colorScheme
    var body: some View {
        VStack(alignment: .leading)
        {
            if(fullSearchable && product.model != "Other" && product.model != "Earlier Models")
            {
                Spacer()
                Text("\(product.model ?? "Unknown Model")")
                    .fontWeight(.bold)
                    .font(.title3)
            }
            SpecificsHeaderView(product: product)
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
                        .foregroundColor(accentColor.color)
                        .onTapGesture {
                            showEditModalView.toggle()
                            generator.notificationOccurred(.success)
                        }
                }.frame(maxWidth: .infinity, alignment: .trailing)
               
            }
            
            Spacer()
        }
        .sheet(isPresented: $showEditModalView) {
            EditProductView(product: product, showEditModalView: $showEditModalView).environmentObject(collectionModel).environmentObject(accentColor)

        }
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
                                  collectionModel.eraseProduct(product: selectedProduct!)}))
        }
        HorizontalMixedAttributeBooleanView(descriptionLeft: "Year Acquired", dataLeft: (product.yearAcquired != nil ? String(product.yearAcquired!): "Unknown"), descriptionRight: "Working status", dataRight: (product.workingStatus != nil ? product.workingStatus!.id: "Unknown"), rightStatus: workingStatusMap[product.workingStatus ?? WorkingStatus.Working] ?? "unknown")
        HorizontalTwoAttributeView(descriptionLeft: "Condition", dataLeft: (product.condition != nil ? product.condition!.id: "Unknown"), descriptionRight: "Acquired as", dataRight: (product.acquiredAs != nil ? product.acquiredAs!.id: "Unknown"))
        HorizontalTwoAttributeView(descriptionLeft: "Estimated value", dataLeft: (product.estimatedValue != nil ?  String(format: "$%d", locale: Locale.current, product.estimatedValue!): "Unknown"), descriptionRight: "Warranty", dataRight: (product.warranty != nil ? product.warranty!.id: "Unknown"))
        HorizontalTwoBooleanView(descriptionLeft: "Physical damage", dataLeft: boolToTextScheme1[product.physicalDamage ?? false]!, descriptionRight: "Original box", dataRight: boolToTextScheme1[product.originalBox ?? false]!, leftStatus: boolToStatusScheme2[product.physicalDamage ?? false]!, rightStatus: boolToStatusScheme1[product.originalBox ?? false]!)
        SpecificsCardView(product: product)
        if(product.comments != nil && product.comments != "") {
            HorizontalOneAttributeView(description: "Comments", data: product.comments!, alignment: .leading)
        }
    }
}

struct SpecificsHeaderView: View {
    var product: ProductInfo
    var body: some View {
            Spacer()
        Text(getCommonHeaderName(product: product, toDisplay: true))
                .fontWeight(.bold)
                .font(.title3)
    }
}

struct SpecificsCardView: View {
    var product: ProductInfo
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
            HorizontalOneBooleanView(description: "Activation Lock", data: boolToTextScheme2[product.activationLock ?? false]!, status: boolToStatusScheme2[product.activationLock ?? false]!, alignment: .leading)
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
                .textSelection(.enabled)
                .fixedSize()
            Spacer(minLength: 5)
            Text(data)
                .fixedSize(horizontal: false, vertical: true)
                .textSelection(.enabled)
            Spacer(minLength: 5)
        }
    }
}

struct HorizontalOneBooleanView: View {
    var description: String
    var data: String
    var status: String
    var alignment: HorizontalAlignment
    let statusToImage: [String: String] = ["affirmative": "checkmark.circle.fill", "negative": "exclamationmark.circle.fill", "unknown": "questionmark.circle.fill", "neutral": "minus.circle.fill"]
    let statusToColor: [String: Color] = ["affirmative": Color.green, "negative": Color.red, "unknown": Color.gray, "neutral": Color.yellow]
    var body: some View {
        VStack(alignment: alignment)
        {
            Text(description)
                .font(.subheadline)
                .foregroundColor(.gray)
                .textSelection(.enabled)
                .fixedSize()
            Spacer(minLength: 5)
            Label(data, systemImage: statusToImage[status]!).foregroundColor(statusToColor[status])
                .fixedSize(horizontal: false, vertical: true)
                .textSelection(.enabled)
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
