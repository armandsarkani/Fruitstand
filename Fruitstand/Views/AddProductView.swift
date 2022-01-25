//
//  AddProductView.swift
//  Fruitstand
//
//  Created by Armand Sarkani on 1/13/22.
//

// This module is responsible for adding and editing products in the collection.

import Foundation
import SwiftUI

// Global variables
var numFormatter: NumberFormatter = {
    let f = NumberFormatter()
    f.numberStyle = .none
    return f
}()

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
                    Picker("Device", selection: $product.type) {
                        ForEach(DeviceType.allCases, id: \.id) { device in
                            Label(device.id, systemImage: icons[device.rawValue]!)
                            .tag(device as DeviceType?)
                            }
                    }
                    ModelPickerView(product: $product)
                    
                    Section("Basics")
                    {
                        BasicsView(numFormatter: numFormatter, product: $product)
                    }
                    Section("Device Specifics")
                    {
                        SpecificsView(numFormatter: numFormatter, product: $product)
                    }
                   
                    Section("Additional Comments")
                    {
                        TextField("Comments", text: $product.comments ?? "")
                            .autocapitalization(.none)
                    }

                }
                .navigationTitle(Text("Add Product"))
                .navigationBarTitleDisplayMode(.inline)
                .navigationBarItems(
                    leading: Button(action: {self.showInfoModalView.toggle()}, label: {Text("Cancel").fontWeight(.regular)}),
                    trailing: Button(action: {addItem()}, label: {Text("Add").bold()}).disabled((product.type == nil ||  product.color == nil || product.yearAcquired == nil || product.estimatedValue == nil || product.workingStatus == nil || product.condition == nil || product.acquiredAs == nil || product.warranty == nil || product.physicalDamage == nil || product.originalBox == nil) || (product.iPhoneModel == nil && product.iPadModel == nil && product.MacModel == nil && product.AppleWatchModel == nil && product.AirPodsModel == nil && product.AppleTVModel == nil && product.iPodModel == nil)))
           }
           .accentColor(accentColor.color)
    }
    func addItem()
    {
        generator.notificationOccurred(.success)
        product.model = getProductModel(product: product)
        collectionModel.saveOneProduct(product: &product)
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
                 
                 Section("Basics")
                 {
                     BasicsView(numFormatter: numFormatter, product: $product)
                 }
                 Section("Device Specifics")
                 {
                     SpecificsView(numFormatter: numFormatter, product: $product)
                 }
                
                 Section("Additional Comments")
                 {
                     TextField("Comments", text: $product.comments ?? "")
                         .autocapitalization(.none)
                 }

             }
             .navigationTitle(Text("Edit Product"))
             .navigationBarTitleDisplayMode(.inline)
             .navigationBarItems(
                 leading: Button(action: {showEditModalView.toggle()}, label: {Text("Cancel").fontWeight(.regular)}),
                 trailing: Button(action: {editItem()}, label: {Text("Done").bold()}).disabled((product.color == "" || product.yearAcquired == nil || product.estimatedValue == nil || product.workingStatus == nil || product.condition == nil || product.acquiredAs == nil || product.warranty == nil || product.physicalDamage == nil || product.originalBox == nil) || (product.iPhoneModel == nil && product.iPadModel == nil && product.MacModel == nil && product.AppleWatchModel == nil && product.AirPodsModel == nil && product.AppleTVModel == nil && product.iPodModel == nil)))
        }
        .accentColor(accentColor.color)
    }
    func editItem()
    {
        generator.notificationOccurred(.success)
        product.model = getProductModel(product: product)
        collectionModel.updateOneProduct(product: product)
        self.showEditModalView.toggle()
    }
}
    
struct BasicsView: View
{
    var numFormatter: NumberFormatter
    @Binding var product: ProductInfo
    var body: some View {
        Group
        {
            TextField("Color", text: $product.color ?? "")
                .autocapitalization(.none)
            TextField("Year Acquired", value: $product.yearAcquired, formatter: numFormatter)
                .keyboardType(.numberPad)
                .autocapitalization(.none)
            HStack
            {
                Text("$")
                TextField("Estimated Value", value: $product.estimatedValue, formatter: numFormatter)
                    .keyboardType(.numberPad)
                    .autocapitalization(.none)
            }
        }
        
        Group
        {
            Picker("Working Status", selection: $product.workingStatus) {
                ForEach(WorkingStatus.allCases, id: \.id) { status in
                    Text(status.id)
                    .tag(status as WorkingStatus?)
                    }
            }
            Picker("Condition", selection: $product.condition) {
                ForEach(Condition.allCases, id: \.id) { status in
                    Text(status.id)
                    .tag(status as Condition?)
                    }
            }
            Picker("Acquired As", selection: $product.acquiredAs) {
                ForEach(AcquiredAs.allCases, id: \.id) { status in
                    Text(status.id)
                    .tag(status as AcquiredAs?)
                    }
            }
            Picker("Warranty", selection: $product.warranty) {
                ForEach(Warranty.allCases, id: \.id) { status in
                    Text(status.id)
                    .tag(status as Warranty?)
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
    var numFormatter: NumberFormatter
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
            Picker("IMEI/ESN Status", selection: $product.ESNStatus) {
                ForEach(ESNStatus.allCases, id: \.id) { status in
                    Text(status.id)
                    .tag(status as ESNStatus?)
                    }
            }
            Picker("Carrier Lock Status", selection: $product.carrierLockStatus) {
                ForEach(CarrierLockStatus.allCases, id: \.id) { status in
                    Text(status.id)
                    .tag(status as CarrierLockStatus?)
                    }
            }

        }
        if(product.type == DeviceType.iPad)
        {
            Picker("Connectivity", selection: $product.connectivity) {
                ForEach(iPadConnectivity.allCases, id: \.id) { status in
                    Text(status.id)
                    .tag(status as iPadConnectivity?)
                    }
            }
        }
        if(product.type == DeviceType.Mac)
        {
            Picker("Form Factor", selection: $product.formFactor) {
                ForEach(FormFactor.allCases, id: \.id) { status in
                    Text(status.id)
                    .tag(status as FormFactor?)
                    }
            }
            if(product.formFactor == FormFactor.Notebook || product.formFactor == FormFactor.AllinOne)
            {
                HStack
                {
                    TextField("Screen Size", value: $product.screenSize, formatter: numFormatter)
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
                TextField("Case Size", value: $product.caseSize, formatter: numFormatter)
                    .keyboardType(.numberPad)
                    .autocapitalization(.none)
                Text("mm")
            }
            TextField("Original Band(s) Included", text: $product.originalBands ?? "")
                .autocapitalization(.none)

            Picker("Case Material", selection: $product.caseType) {
                ForEach(WatchCaseType.allCases, id: \.id) { status in
                    Text(status.id)
                    .tag(status as WatchCaseType?)
                    }
            }
            Picker("Connectivity", selection: $product.watchConnectivity) {
                ForEach(WatchConnectivity.allCases, id: \.id) { status in
                    Text(status.id)
                    .tag(status as WatchConnectivity?)
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
            Picker("Case Type", selection: $product.APCaseType) {
                ForEach(AirPodsCaseType.allCases, id: \.id) { status in
                    Text(status.id)
                    .tag(status as AirPodsCaseType?)
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
            Picker("Model", selection: $product.iPhoneModel) {
                ForEach(iPhoneModel.allCases, id: \.id) { status in
                    Text(status.id)
                    .tag(status as iPhoneModel?)
                    }
            }
            if(product.iPhoneModel == iPhoneModel.Other){
                TextField("Other iPhone Model", text: $product.otherModel ?? "")
                    .autocapitalization(.none)
            }
        }
        if(product.type == DeviceType.iPad){
            Picker("Model", selection: $product.iPadModel) {
                ForEach(iPadModel.allCases, id: \.id) { status in
                    Text(status.id)
                    .tag(status as iPadModel?)
                    }
            }
            if(product.iPadModel == iPadModel.Other){
                TextField("Other iPad Model", text: $product.otherModel ?? "")
                    .autocapitalization(.none)
            }
        }
        if(product.type == DeviceType.Mac){
            Picker("Model", selection: $product.MacModel) {
                ForEach(MacModel.allCases, id: \.id) { status in
                    Text(status.id)
                    .tag(status as MacModel?)
                }
            }
            if(product.MacModel == MacModel.Other || product.MacModel == MacModel.Earlier){
                TextField("Other/Earlier Mac Model", text: $product.otherModel ?? "")
                    .autocapitalization(.none)
            }
        }
        if(product.type == DeviceType.AppleWatch){
            Picker("Model", selection: $product.AppleWatchModel) {
                ForEach(AppleWatchModel.allCases, id: \.id) { status in
                    Text(status.id)
                    .tag(status as AppleWatchModel?)
                    }
            }
            if(product.AppleWatchModel == AppleWatchModel.Other){
                TextField("Other Watch Model", text: $product.otherModel ?? "")
                    .autocapitalization(.none)
            }
        }
        if(product.type == DeviceType.AirPods){
            Picker("Model", selection: $product.AirPodsModel) {
                ForEach(AirPodsModel.allCases, id: \.id) { status in
                    Text(status.id)
                    .tag(status as AirPodsModel?)
                    }
            }
            if(product.AirPodsModel == AirPodsModel.Other){
                TextField("Other AirPods Model", text: $product.otherModel ?? "")
                    .autocapitalization(.none)
            }
        }
        if(product.type == DeviceType.AppleTV){
            Picker("Model", selection: $product.AppleTVModel) {
                ForEach(AppleTVModel.allCases, id: \.id) { status in
                    Text(status.id)
                    .tag(status as AppleTVModel?)
                    }
            }
            if(product.AppleTVModel == AppleTVModel.Other){
                TextField("Other Apple TV Model", text: $product.otherModel ?? "")
                    .autocapitalization(.none)
            }
        }
        if(product.type == DeviceType.iPod){
            Picker("Model", selection: $product.iPodModel) {
                ForEach(iPodModel.allCases, id: \.id) { status in
                    Text(status.id)
                    .tag(status as iPodModel?)
                    }
            }
            if(product.iPodModel == iPodModel.Other){
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
