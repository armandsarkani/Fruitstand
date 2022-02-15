//
//  ProductView.swift
//  Fruitstand
//
//  Created by Armand Sarkani on 5/17/21.
//

// This module is responsible for the view for displaying a list of products for a given model.

import SwiftUI
import AlertToast
import LinkPresentation
import UniformTypeIdentifiers
import ActivityView


// Global variables
let boolToTextScheme1: [Bool: String] = [true: "Yes", false: "No"]
let boolToTextScheme2: [Bool: String] = [true: "On", false: "Off"]
let boolToStatusScheme1: [Bool: String] = [true: "affirmative", false: "negative"]
let boolToStatusScheme2: [Bool: String] = [true: "negative", false: "affirmative"]
let commonColorMapping: [String: Color] = ["black": Color.black, "space black": Color.black, "black & slate": Color.black, "white": Color.white, "white & silver": Color.white, "space gray": Color.gray, "gray": Color.gray, "silver": Color("Silver"), "red": Color.red, "(product)red": Color.red, "product red": Color.red, "green": Color.green, "blue": Color.blue, "gold": Color("Gold"), "rose gold": Color("Rose Gold"), "yellow": Color.yellow, "orange": Color.orange, "coral": Color("Coral"), "sierra blue": Color.cyan, "pacific blue": Color.blue, "graphite": Color.gray, "purple": Color.purple, "midnight green": Color.green, "starlight": Color("Starlight"), "platinum": Color("Starlight"), "blueberry": Color.blue, "key lime": Color.green, "tangerine": Color.orange, "indigo": Color.indigo, "jet black": Color.black, "pink": Color.pink]
let generator = UINotificationFeedbackGenerator()

enum SortStyle: String, CaseIterable, Identifiable, Codable {
    case None
    case YearAcquiredAscending = "Oldest to Newest Acquired"
    case YearAcquiredDescending = "Newest to Oldest Acquired"
    case EstimatedValueAscending = "Lowest to Highest Value"
    case EstimatedValueDescending = "Highest to Lowest Value"
    var id: String { self.rawValue }
    var images: [String] {
        if(self == SortStyle.YearAcquiredAscending) {
            return ["calendar", "arrow.up.circle.fill"]
        }
        else if(self == SortStyle.YearAcquiredDescending) {
            return ["calendar", "arrow.down.circle.fill"]
        }
        else if(self == SortStyle.EstimatedValueAscending) {
            return ["dollarsign.circle", "arrow.up.circle.fill"]
        }
        else if(self == SortStyle.EstimatedValueDescending) {
            return ["dollarsign.circle", "arrow.down.circle.fill"]
        }
        return ["list.bullet", "arrow.up.arrow.down.circle"]
    }
    static let allSortedCases: [SortStyle] = [.YearAcquiredAscending, .YearAcquiredDescending, .EstimatedValueAscending, .EstimatedValueDescending]
}

struct ProductView: View {
    @EnvironmentObject var collectionModel: CollectionModel
    @EnvironmentObject var accentColor: AccentColor
    var model: String
    var deviceType: DeviceType
    var fromSearch: Bool = false
    @Environment(\.horizontalSizeClass) var horizontalSizeClass
    @State var sortStyle: SortStyle = SortStyle.None
    @State var showInfoModalView: Bool = false
    @State private var showToast: Bool = false
    @State private var searchText = ""
    @State private var collectionFull: Bool = false
    @State private var showEditToast: Bool = false
    init(model: String, deviceType: DeviceType, fromSearch: Bool)
    {
        self.model = model
        self.deviceType = deviceType
    }
    var searchResults: [ProductInfo] {
        var products: [ProductInfo] = []
        if searchText.isEmpty {
           products =  collectionModel.loadMatchingProductsByModel(deviceType: deviceType, model: model)
        }
        else {
           products = collectionModel.loadMatchingProductsByModel(deviceType: deviceType, model: model).filter {$0.contains(searchText: searchText)}
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
        List {
            if(!searchText.isEmpty && !searchResults.isEmpty)
            {
                Section(header: Text(resultsText).fontWeight(.medium).font(.system(.title3, design: .rounded)).textCase(nil).foregroundColor(.secondary)) {}
                .listRowInsets(EdgeInsets(top: 20, leading: 7, bottom: -20, trailing: 0))
            }
            ForEach(searchResults, id: \.self) { product in
                Section
                {
                    ProductCardView(product: product, fullySearchable: false, showButtons: true, showEditToast: $showEditToast).environmentObject(collectionModel).environmentObject(accentColor)
                }
            }
        }
        .listStyle(InsetGroupedListStyle())
        .searchable(text: $searchText, placement: .navigationBarDrawer(displayMode: .automatic)).autocapitalization(.none)
        .overlay(Group {
            if(searchResults.isEmpty){
                if(searchText.isEmpty) {
                    VStack(spacing: 15)
                    {
                        Image(systemName: modelIcons[model] ?? "questionmark.folder.fill")
                            .font(.system(size: 72, design: .rounded))
                            .foregroundColor(accentColor.color)
                        Text(model)
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
        .introspectTableView { introspect in
            introspect.keyboardDismissMode = .onDrag
        }
        .navigationTitle(model)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing)
            {
                HStack
                {
                    #if targetEnvironment(macCatalyst)
                    SortMenuViewMac(sortStyle: $sortStyle).environmentObject(accentColor)
                    #else
                    SortMenuView(sortStyle: $sortStyle)
                    #endif
                    if(UIDevice.current.model.hasPrefix("iPhone") || horizontalSizeClass == .compact) {
                        NavigationLink(destination: SearchView(previousModelDetailView: model).environmentObject(collectionModel).environmentObject(accentColor))
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
        .toast(isPresenting: $showEditToast, duration: 1) {
            AlertToast(type: .complete(accentColor.color), title: "Product Edited", style: AlertToast.AlertStyle.style(titleFont: Font.system(.title3, design: .rounded).bold()))
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


struct ProductCardView: View {
    @EnvironmentObject var collectionModel: CollectionModel
    @EnvironmentObject var accentColor: AccentColor
    let workingStatusMap: [WorkingStatus: String] = [WorkingStatus.NotWorking: "negative", WorkingStatus.MostlyWorking: "neutral", WorkingStatus.Working: "affirmative"]
    var product: ProductInfo
    var fullySearchable: Bool
    var showButtons: Bool
    @Binding var showEditToast: Bool
    @State var confirmationShown: Bool = false
    @State private var selectedProduct: ProductInfo? = nil
    @State private var showToast: Bool = false
    @State var showEditModalView: Bool = false
    @State private var item: ActivityItem?
    @Environment(\.colorScheme) var colorScheme
    var body: some View {
        VStack(alignment: .leading)
        {
            if(fullySearchable && product.model != "Other" && product.model != "Earlier Models")
            {
                Spacer()
                Text("\(product.model ?? "Unknown Model")")
                    .fontWeight(.bold)
                .font(.system(.title3, design: .rounded))
                
            }
            SpecificsHeaderView(product: product)
                .contextMenu {
                    Button(role: .destructive, action: {generator.notificationOccurred(.error); selectedProduct = product; confirmationShown.toggle()})
                    {
                        Label("Erase Product", systemImage: "trash.fill").foregroundColor(.red)
                    }
                    Button(action: {generator.notificationOccurred(.success); showEditModalView.toggle()})
                    {
                        Label("Edit Product", systemImage: "pencil")
                    }
                    Button(action: {UIPasteboard.general.string = product.getCommonName(toDisplay: true)})
                    {
                        Label("Copy Model Name", systemImage: "doc.on.doc")
                    }
                    Button(action: {UIPasteboard.general.string = product.uuid})
                    {
                        Label("Copy Debug UUID", systemImage: "ant.fill")
                    }
                    Button(action: {
                        #if targetEnvironment(macCatalyst)
                        item = ActivityItem(items: ProductCardSnapshotView(product: product, fullySearchable: true).environmentObject(collectionModel).environmentObject(accentColor).snapshot())
                        #else
                        item = ActivityItem(items: ProductCardSnapshotView(product: product, fullySearchable: true).environmentObject(collectionModel).environmentObject(accentColor).snapshot(), MetadataActivityItem(title: product.model!, text: "Share a snapshot of this product"))

                        #endif

                    })
                    {
                        Label("Share", systemImage: "square.and.arrow.up")
                    }
                }
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
                if(showButtons) {
                    HStack {
                        Button(role: .destructive, action: {generator.notificationOccurred(.error); selectedProduct = product; confirmationShown.toggle()})
                        {
                            Label("Delete", systemImage: "trash.fill").foregroundColor(.red)
                                .hoverEffect(.lift)
                                .labelStyle(.iconOnly)
                                .imageScale(.medium)
                                .font(Font.system(.body).bold())
                        }
                        .buttonStyle(BorderlessButtonStyle())
                        Spacer().frame(width: 30)
                        Button(role: .destructive, action: {generator.notificationOccurred(.success); showEditModalView.toggle()})
                        {
                            Label("Edit", systemImage: "pencil").foregroundColor(accentColor.color)
                                .hoverEffect(.lift)
                                .labelStyle(.iconOnly)
                                .imageScale(.large)
                                .font(Font.system(.body).bold())
                        }
                        .buttonStyle(BorderlessButtonStyle())
                    }.frame(maxWidth: .infinity, alignment: .trailing)
                }
               
            }
            .activitySheet($item)

            Spacer()
        }
        .sheet(isPresented: $showEditModalView, onDismiss: {
            if(collectionModel.productJustEdited) {
                showEditToast.toggle()
                collectionModel.productJustEdited = false
            }
        })
        {
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
        HorizontalMixedAttributeBooleanView(descriptionLeft: "Year acquired", dataLeft: (product.yearAcquired != nil ? String(product.yearAcquired!): "Unknown"), descriptionRight: "Working status", dataRight: (product.workingStatus != nil ? product.workingStatus!.id: "Unknown"), rightStatus: workingStatusMap[product.workingStatus ?? WorkingStatus.Working] ?? "unknown")
        HorizontalTwoAttributeView(descriptionLeft: "Condition", dataLeft: (product.condition != nil ? product.condition!.id: "Unknown"), descriptionRight: "Acquired as", dataRight: (product.acquiredAs != nil ? product.acquiredAs!.id: "Unknown"))
        HorizontalTwoAttributeView(descriptionLeft: "Estimated value", dataLeft: (product.estimatedValue != nil ?  String(format: "$%d", locale: Locale.current, product.estimatedValue!): "Unknown"), descriptionRight: "Warranty", dataRight: (product.warranty != nil ? product.warranty!.id: "Unknown"))
        HorizontalTwoBooleanView(descriptionLeft: "Physical damage", dataLeft: boolToTextScheme1[product.physicalDamage ?? false]!, descriptionRight: "Original box", dataRight: boolToTextScheme1[product.originalBox ?? false]!, leftStatus: boolToStatusScheme2[product.physicalDamage ?? false]!, rightStatus: boolToStatusScheme1[product.originalBox ?? false]!)
        SpecificsCardView(product: product)
        if(product.comments != nil && product.comments != "") {
            HorizontalOneAttributeView(description: "Comments", data: product.comments!, alignment: .leading)
                .contextMenu {
                    Button(action: {UIPasteboard.general.string = product.comments})
                    {
                        Label("Copy Comments", systemImage: "doc.on.doc")
                    }
                }
            
        }
    }
}

struct ProductCardSnapshotView: View {
    @EnvironmentObject var collectionModel: CollectionModel
    @EnvironmentObject var accentColor: AccentColor
    @State var showEditToast: Bool = false
    var product: ProductInfo
    var fullySearchable: Bool
    var body: some View {
        List {
            ProductCardView(product: product, fullySearchable: fullySearchable, showButtons: false, showEditToast: $showEditToast).environmentObject(collectionModel).environmentObject(accentColor)
        }
    }
}

struct SpecificsHeaderView: View {
    var product: ProductInfo
    var body: some View {
        Spacer()
        Text(product.getCommonHeaderName(toDisplay: true))
                .fontWeight(.bold)
        .font(.system(.title3, design: .rounded))
        
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
            .contextMenu {
                Button(action: {UIPasteboard.general.string = product.originalBands ?? "Unknown"})
                {
                    Label("Copy", systemImage: "doc.on.doc")
                }
            }
            
        }
        if(product.type == DeviceType.AppleTV) {
            HorizontalOneBooleanView(description: "Has remote", data: boolToTextScheme1[product.hasRemote ?? false]!, status: boolToStatusScheme1[product.hasRemote ?? false]!, alignment: .leading)
            
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
                .font(.system(.subheadline, design: .rounded))
                .foregroundColor(.secondary)
                .fixedSize()
            Spacer(minLength: 5)
            Text(data)
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
                .font(.system(.subheadline, design: .rounded))
                .foregroundColor(.secondary)
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

struct SortMenuView: View {
    @Binding var sortStyle: SortStyle
    var body: some View {
        Menu {
            Picker("None", selection: $sortStyle) {
                ForEach([SortStyle.None]) { style in
                    Text(style.rawValue)
                        .tag(style)
                }
            }
            .pickerStyle(InlinePickerStyle())
            Picker("Sort Style", selection: $sortStyle) {
                ForEach(SortStyle.allSortedCases) { style in
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

struct SortMenuViewMac: View {
    @Binding var sortStyle: SortStyle
    @EnvironmentObject var accentColor: AccentColor
    var body: some View {
        Picker(selection: $sortStyle, label: Image(systemName: sortStyle.images[1]).imageScale(.large).foregroundColor(accentColor.color))
        {
            ForEach(SortStyle.allCases) { style in
                Text(style.rawValue)
                    .tag(style)
            }
        }
        .pickerStyle(MenuPickerStyle())
    }
}

struct CustomSortLabelStyle: LabelStyle {
    @Environment(\.horizontalSizeClass) var horizontalSizeClass
    func makeBody(configuration: Configuration) -> some View {
        if(UIDevice.current.model.hasPrefix("iPhone") || horizontalSizeClass == .compact)
        {
            configuration.icon
        }
        else {
            HStack {
                configuration.icon
                configuration.title
            }
        }
    }
}

class MetadataActivityItem: NSObject, UIActivityItemSource {
    var title: String
    var text: String
    
    init(title: String, text: String) {
        self.title = title
        self.text = text
        super.init()
    }
    
    func activityViewControllerPlaceholderItem(_ activityViewController: UIActivityViewController) -> Any {
        return text
    }
    
    func activityViewController(_ activityViewController: UIActivityViewController, itemForActivityType activityType: UIActivity.ActivityType?) -> Any? {
        return text
    }
    
    func activityViewController(_ activityViewController: UIActivityViewController, subjectForActivityType activityType: UIActivity.ActivityType?) -> String {
        return title
    }

    func activityViewControllerLinkMetadata(_ activityViewController: UIActivityViewController) -> LPLinkMetadata? {
        let metadata = LPLinkMetadata()
        metadata.title = title
        metadata.imageProvider = NSItemProvider(object: UIImage(named: "AppIcon")!)
        metadata.originalURL = URL(fileURLWithPath: text)
        return metadata
    }

}

