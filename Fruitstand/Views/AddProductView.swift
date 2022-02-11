//
//  AddProductView.swift
//  Fruitstand
//
//  Created by Armand Sarkani on 1/13/22.
//

// This module is responsible for adding and editing products in the collection.

import Foundation
import SwiftUI
import Combine


struct AddProductView: View {
    @State var product: ProductInfo = ProductInfo(type: DeviceType.Mac)
    @Binding var showInfoModalView: Bool
    @EnvironmentObject var collectionModel: CollectionModel
    @EnvironmentObject var accentColor: AccentColor

    @Environment(\.isPresented) var presentation
    var body: some View {
           NavigationView {
                Form
                {
                    CustomPickerContainerView("Device") {
                        Picker(selection: $product.type, label: CustomPickerLabelView("Device")) {
                        #if targetEnvironment(macCatalyst)
                            Text("Select").tag(nil as DeviceType?)
                        #endif
                            ForEach(DeviceType.allCases, id: \.id) { device in
                                Label(device.id, systemImage: icons[device.rawValue]!)
                                .tag(device as DeviceType?)
                                }
                            .accentColor(accentColor.color)
                        }
                        .onChange(of: product.type) { change in
                            product.model = nil
                            product.otherModel = nil
                        }
                    }
                    ModelPickerView(product: $product)
                        .accentColor(accentColor.color)
                    
                    Section(header: Text("Basics").customSectionHeader())
                    {
                        BasicsView(product: $product)
                    }
                    //.headerProminence(.increased)

                    Section(header: Text("Device Specifics").customSectionHeader())
                    {
                        SpecificsView(product: $product)
                    }
                    //.headerProminence(.increased)

                   
                    Section(header: Text("Additional Comments").customSectionHeader())
                    {
                        TextField("Comments", text: $product.comments ?? "")
                            .autocapitalization(.none)
                    }
                    //.headerProminence(.increased)


                }
                .gesture(
                    DragGesture()
                        .onChanged { _ in self.hideKeyboard() }
                    )
                .navigationTitle(Text("Add Product"))
                .navigationBarTitleDisplayMode(.large)
                .toolbar {
                    ToolbarItem(placement: .navigationBarLeading) {
                        Button(action: {self.showInfoModalView.toggle()}, label: {Text("Cancel").fontWeight(.regular)})
                    }
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button(action: {addItem()}, label: {Text("Add").bold()}).disabled((product.type == nil ||  product.color == nil || product.yearAcquired == nil || product.estimatedValue == nil || product.workingStatus == nil || product.condition == nil || product.acquiredAs == nil || product.warranty == nil || product.physicalDamage == nil || product.originalBox == nil) || product.model == nil)
                        
                    }
                }
           }
           .accentColor(accentColor.color)
    }
    func addItem()
    {
        if(product.otherModel != nil) {
            product.model = product.otherModel
        }
        generator.notificationOccurred(.success)
        collectionModel.saveOneProduct(product: &product)
        collectionModel.productJustAdded = true
        self.showInfoModalView.toggle()
    }
}

struct EditProductView: View {
    @State var product: ProductInfo
    @Binding var showEditModalView: Bool
    @EnvironmentObject var collectionModel: CollectionModel
    @EnvironmentObject var accentColor: AccentColor
    let generator = UINotificationFeedbackGenerator()
    @Environment(\.isPresented) var presentation
    init(product: ProductInfo, showEditModalView: Binding<Bool>)
    {
        self.product = product
        _showEditModalView = showEditModalView
    }
    var body: some View {
        NavigationView {
             Form
             {
                 ModelPickerView(product: $product)
                     .accentColor(accentColor.color)
                 Section(header: Text("Basics").customSectionHeader())
                 {
                     BasicsView(product: $product)

                 }
                 //.headerProminence(.increased)

                 Section(header: Text("Device Specifics").customSectionHeader())
                 {
                     SpecificsView(product: $product)
                 }
                 //.headerProminence(.increased)
                
                 Section(header: Text("Additional Comments").customSectionHeader())
                 {
                     TextField("Comments", text: $product.comments ?? "")
                         .autocapitalization(.none)
                 }
                 //.headerProminence(.increased)

             }
             .gesture(
                 DragGesture()
                     .onChanged { _ in self.hideKeyboard() }
                 )
             .navigationTitle(Text("Edit Product"))
             .navigationBarTitleDisplayMode(.large)
             .toolbar {
                 ToolbarItem(placement: .navigationBarLeading) {
                     Button(action: {showEditModalView.toggle()}, label: {Text("Cancel").fontWeight(.regular)})
                 }
                 ToolbarItem(placement: .navigationBarTrailing) {
                     Button(action: {editItem()}, label: {Text("Done").bold()}).disabled((product.color == "" || product.yearAcquired == nil || product.estimatedValue == nil || product.workingStatus == nil || product.condition == nil || product.acquiredAs == nil || product.warranty == nil || product.physicalDamage == nil || product.originalBox == nil) || product.model == nil)
                 }
             }
        }
        .accentColor(accentColor.color)
        .onAppear {
            if(self.product.otherModel != nil) {
                (self.product.type == DeviceType.Mac) ? (self.product.model = "Other/Earlier Models") : (self.product.model = "Other")
            }
        }
    }
    func editItem()
    {
        if(product.otherModel != nil) {
            product.model = product.otherModel
        }
        generator.notificationOccurred(.success)
        collectionModel.updateOneProduct(product: product)
        collectionModel.productJustEdited = true
        self.showEditModalView.toggle()
    }
}

    
struct BasicsView: View
{
    @Binding var product: ProductInfo
    var body: some View {
        Group
        {
            TextField("Color", text: $product.color ?? "")
                .autocapitalization(.none)
            TextField("Year Acquired", value: $product.yearAcquired, format: IntegerFormatStyle().grouping(.never))
                .keyboardType(.numberPad)
                .autocapitalization(.none)
            HStack
            {
                Text("$")
                TextField("Estimated Value", value: $product.estimatedValue, format: .number)
                    .keyboardType(.numberPad)
                    .autocapitalization(.none)
            }
        }
        
        Group
        {
            CustomPickerContainerView("Working Status") {
                Picker(selection: $product.workingStatus, label: CustomPickerLabelView("Working Status")) {
                #if targetEnvironment(macCatalyst)
                    Text("Select").tag(nil as WorkingStatus?)
                #endif
                    ForEach(WorkingStatus.allCases, id: \.id) { status in
                        Text(status.id)
                        .tag(status as WorkingStatus?)
                        }
                }
            }
            
            CustomPickerContainerView("Condition") {
                Picker(selection: $product.condition, label: CustomPickerLabelView("Condition")) {
                #if targetEnvironment(macCatalyst)
                    Text("Select").tag(nil as Condition?)
                #endif
                    ForEach(Condition.allCases, id: \.id) { status in
                        Text(status.id)
                        .tag(status as Condition?)
                        }
                }
            }
            
            CustomPickerContainerView("Acquired As") {
                Picker(selection: $product.acquiredAs, label: CustomPickerLabelView("Acquired As")) {
                #if targetEnvironment(macCatalyst)
                    Text("Select").tag(nil as AcquiredAs?)
                #endif
                    ForEach(AcquiredAs.allCases, id: \.id) { status in
                        Text(status.id)
                        .tag(status as AcquiredAs?)
                        }
                }
            }
            
            CustomPickerContainerView("Warranty") {
                Picker(selection: $product.warranty, label: CustomPickerLabelView("Warranty")) {
                #if targetEnvironment(macCatalyst)
                    Text("Select").tag(nil as Warranty?)
                #endif
                    ForEach(Warranty.allCases, id: \.id) { status in
                        Text(status.id)
                        .tag(status as Warranty?)
                        }
                }
            }
            
        }
        Group
        {
            Toggle(isOn: $product.physicalDamage ?? false)
            {
                Text("Physical Damage")
            }
            Toggle(isOn: $product.originalBox ?? false)
            {
                Text("Original Box")
            }
        }
    }
    
}

struct SpecificsView: View
{
    @Binding var product: ProductInfo
    var body: some View {
        if(product.type == DeviceType.iPhone || product.type == DeviceType.iPad || product.type == DeviceType.AppleTV || product.type == DeviceType.iPod)
        {
            TextField("Storage", text: $product.storage ?? "")
                .autocapitalization(.none)
        }
        if(product.type == DeviceType.iPhone)
        {
            TextField("Carrier", text: $product.carrier ?? "")
                .autocapitalization(.none)
            
            
            CustomPickerContainerView("IMEI/ESN Status") {
                Picker(selection: $product.ESNStatus, label: CustomPickerLabelView("IMEI/ESN Status")) {
                #if targetEnvironment(macCatalyst)
                    Text("Select").tag(nil as ESNStatus?)
                #endif
                    ForEach(ESNStatus.allCases, id: \.id) { status in
                        Text(status.id)
                        .tag(status as ESNStatus?)
                        }
                }
            }
            
            CustomPickerContainerView("Carrier Lock Status") {
                Picker(selection: $product.carrierLockStatus, label: CustomPickerLabelView("Carrier Lock Status")) {
                #if targetEnvironment(macCatalyst)
                    Text("Select").tag(nil as CarrierLockStatus?)
                #endif
                    ForEach(CarrierLockStatus.allCases, id: \.id) { status in
                        Text(status.id)
                        .tag(status as CarrierLockStatus?)
                        }
                }
            }

        }
        if(product.type == DeviceType.iPad)
        {
            CustomPickerContainerView("Connectivity") {
                Picker(selection: $product.connectivity, label: CustomPickerLabelView("Connectivity")) {
                #if targetEnvironment(macCatalyst)
                    Text("Select").tag(nil as iPadConnectivity?)
                #endif
                    ForEach(iPadConnectivity.allCases, id: \.id) { status in
                        Text(status.id)
                        .tag(status as iPadConnectivity?)
                        }
                }
            }
        }
        if(product.type == DeviceType.Mac)
        {
            CustomPickerContainerView("Form Factor") {
                Picker(selection: $product.formFactor, label: CustomPickerLabelView("Form Factor")) {
                #if targetEnvironment(macCatalyst)
                    Text("Select").tag(nil as FormFactor?)
                #endif
                    ForEach(FormFactor.allCases, id: \.id) { status in
                        Text(status.id)
                        .tag(status as FormFactor?)
                        }
                }
            }
            
            if(product.formFactor == FormFactor.Notebook || product.formFactor == FormFactor.AllinOne)
            {
                HStack
                {
                    TextField("Screen Size", value: $product.screenSize, format: .number)
                        .keyboardType(.numberPad)
                        .autocapitalization(.none)
                    Text("in")
                }
                
                
            }
            TextField("Year", text: $product.year ?? "")
                .autocapitalization(.none)
            TextField("Processor", text: $product.processor ?? "")
                .autocapitalization(.none)
            TextField("Storage", text: $product.storage ?? "")
                .autocapitalization(.none)
            TextField("Memory", text: $product.memory ?? "")
                .autocapitalization(.none)
        }
        if(product.type == DeviceType.AppleWatch)
        {
            HStack
            {
                TextField("Case Size", value: $product.caseSize, format: .number)
                    .keyboardType(.numberPad)
                    .autocapitalization(.none)
                Text("mm")
            }
            TextField("Original Band(s) Included", text: $product.originalBands ?? "")
                .autocapitalization(.none)
            
            CustomPickerContainerView("Case Type") {
                Picker(selection: $product.caseType, label: CustomPickerLabelView("Case Type")) {
                #if targetEnvironment(macCatalyst)
                    Text("Select").tag(nil as WatchCaseType?)
                #endif
                    ForEach(WatchCaseType.allCases, id: \.id) { status in
                        Text(status.id)
                        .tag(status as WatchCaseType?)
                        }
                }
            }
            
            CustomPickerContainerView("Connectivity") {
                Picker(selection: $product.watchConnectivity, label: CustomPickerLabelView("Connectivity")) {
                #if targetEnvironment(macCatalyst)
                    Text("Select").tag(nil as WatchConnectivity?)
                #endif
                    ForEach(WatchConnectivity.allCases, id: \.id) { status in
                        Text(status.id)
                        .tag(status as WatchConnectivity?)
                        }
                }
            }
            
            
        }
        if(product.type == DeviceType.AppleTV)
        {
            Toggle(isOn: $product.hasRemote ?? false)
            {
                Text("Has Remote")
            }
        }
        if(product.type == DeviceType.AirPods)
        {
            
            CustomPickerContainerView("Case Type") {
                Picker(selection: $product.APCaseType, label: CustomPickerLabelView("Case Type")) {
                #if targetEnvironment(macCatalyst)
                    Text("Select").tag(nil as AirPodsCaseType?)
                #endif
                    ForEach(AirPodsCaseType.allCases, id: \.id) { status in
                        Text(status.id)
                        .tag(status as AirPodsCaseType?)
                        }
                }
            }
        }
        if(product.type == DeviceType.iPhone || product.type == DeviceType.iPad || product.type == DeviceType.Mac || product.type == DeviceType.AppleWatch || product.type == DeviceType.iPod)
        {
            Toggle(isOn: $product.activationLock ?? false)
            {
                Text("Activation Lock")
            }
        }

    }
}

struct ModelPickerView : View
{
    @Binding var product: ProductInfo
    var body: some View {
        if(product.type == DeviceType.iPhone){
            CustomPickerContainerView("Model") {
                Picker(selection: $product.model, label: CustomPickerLabelView("Model")) {
                #if targetEnvironment(macCatalyst)
                    Text("Select").tag(nil as String?)
                #endif
                    ForEach(iPhoneModel.allCases, id: \.id) { status in
                        Label(status.id, systemImage: status.getIcon())
                            .tag(status.id as String?)
                        }
                }
                .onChange(of: product.model) { change in
                    if(product.model != "Other") {
                        product.otherModel = nil
                    }
                }
            }
            if(product.model == "Other"){
                TextField("Other iPhone Model", text: $product.otherModel ?? "")
                    .autocapitalization(.none)
            }
        }
        if(product.type == DeviceType.iPad){
            CustomPickerContainerView("Model") {
                Picker(selection: $product.model, label: CustomPickerLabelView("Model")) {
                #if targetEnvironment(macCatalyst)
                    Text("Select").tag(nil as String?)
                #endif
                    ForEach(iPadModel.allCases, id: \.id) { status in
                        Label(status.id, systemImage: status.getIcon())
                            .tag(status.id as String?)
                        }
                }
                .onChange(of: product.model) { change in
                    if(product.model != "Other") {
                        product.otherModel = nil
                    }
                }
            }
            if(product.model == "Other"){
                TextField("Other iPad Model", text: $product.otherModel ?? "")
                    .autocapitalization(.none)
            }
        }
        if(product.type == DeviceType.Mac){
            CustomPickerContainerView("Model") {
                Picker(selection: $product.model, label: CustomPickerLabelView("Model")) {
                #if targetEnvironment(macCatalyst)
                    Text("Select").tag(nil as String?)
                #endif
                    ForEach(MacModel.allCases, id: \.id) { status in
                        Label(status.id, systemImage: status.getIcon())
                            .tag(status.id as String?)
                        }
                }
                .onChange(of: product.model) { change in
                    if(product.model != "Other/Earlier Models") {
                        product.otherModel = nil
                    }
                }
            }
            if(product.model == "Other/Earlier Models"){
                TextField("Other/Earlier Mac Model", text: $product.otherModel ?? "")
                    .autocapitalization(.none)
            }
        }
        if(product.type == DeviceType.AppleWatch){
            CustomPickerContainerView("Model") {
                Picker(selection: $product.model, label: CustomPickerLabelView("Model")) {
                #if targetEnvironment(macCatalyst)
                    Text("Select").tag(nil as String?)
                #endif
                    ForEach(AppleWatchModel.allCases, id: \.id) { status in
                        Label(status.id, systemImage: status.getIcon())
                            .tag(status.id as String?)
                        }
                }
                .onChange(of: product.model) { change in
                    if(product.model != "Other") {
                        product.otherModel = nil
                    }
                }
            }
            if(product.model == "Other"){
                TextField("Other Apple Watch Model", text: $product.otherModel ?? "")
                    .autocapitalization(.none)
            }
        }
        if(product.type == DeviceType.AirPods){
            CustomPickerContainerView("Model") {
                Picker(selection: $product.model, label: CustomPickerLabelView("Model")) {
                #if targetEnvironment(macCatalyst)
                    Text("Select").tag(nil as String?)
                #endif
                    ForEach(AirPodsModel.allCases, id: \.id) { status in
                        Label(status.id, systemImage: status.getIcon())
                            .tag(status.id as String?)
                        }
                }
                .onChange(of: product.model) { change in
                    if(product.model != "Other") {
                        product.otherModel = nil
                    }
                }
            }
            if(product.model == "Other"){
                TextField("Other AirPods Model", text: $product.otherModel ?? "")
                    .autocapitalization(.none)
            }
        }
        if(product.type == DeviceType.AppleTV){
            CustomPickerContainerView("Model") {
                Picker(selection: $product.model, label: CustomPickerLabelView("Model")) {
                #if targetEnvironment(macCatalyst)
                    Text("Select").tag(nil as String?)
                #endif
                    ForEach(AppleTVModel.allCases, id: \.id) { status in
                        Label(status.id, systemImage: status.getIcon())
                            .tag(status.id as String?)
                        }
                }
                .onChange(of: product.model) { change in
                    if(product.model != "Other") {
                        product.otherModel = nil
                    }
                }
            }
            if(product.model == "Other"){
                TextField("Other Apple TV Model", text: $product.otherModel ?? "")
                    .autocapitalization(.none)
            }
        }
        if(product.type == DeviceType.iPod){
            CustomPickerContainerView("Model") {
                Picker(selection: $product.model, label: CustomPickerLabelView("Model")) {
                #if targetEnvironment(macCatalyst)
                    Text("Select").tag(nil as String?)
                #endif
                    ForEach(iPodModel.allCases, id: \.id) { status in
                        Label(status.id, systemImage: status.getIcon())
                            .tag(status.id as String?)
                        }
                }
                .onChange(of: product.model) { change in
                    if(product.model != "Other") {
                        product.otherModel = nil
                    }
                }
            }
            if(product.model == "Other"){
                TextField("Other iPod Model", text: $product.otherModel ?? "")
                    .autocapitalization(.none)
            }
        }
    }
}

struct AddProductView_Previews: PreviewProvider{
    static var previews: some View {
        Group {
            AddProductView(showInfoModalView: .constant(false))
                .preferredColorScheme(.dark)
        }
    }
}

struct CustomPickerContainerView<Content: View>: View {
    let content: Content
    var text: String
    init(_ text: String, @ViewBuilder content: () -> Content) {
        self.content = content()
        self.text = text
    }

    var body: some View {
        VStack(alignment: .leading) {
            #if targetEnvironment(macCatalyst)
            Text(text)
            content
                .padding(.leading, -10)
            #else
            content
            #endif

        }
    }
}

struct CustomPickerLabelView: View{
    var text: String
    init(_ text: String) {
        self.text = text
    }
    var body: some View {
        #if targetEnvironment(macCatalyst)
        Group {}
        #else
        Text(text)
        #endif
    }
}
