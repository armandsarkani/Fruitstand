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

//struct ProductView: View {
//    var body: some View
//    {
//
//    }
//}

struct ProductListView: View {
    var title: String
    @State var products: [ProductInfo]
    init(title: String)
    {
        self.title = title
        self.products = loadProducts(deviceType: title)

    }
    var body: some View {
        List
        {
            ForEach(products, id: \.self) { product in
               HStack
                {
                    Label(title, systemImage: icons[title]!)
                }
            }
            
        }.navigationBarTitle(Text(title), displayMode: .inline)
            
    }
    
}

struct AddProductView: View {
    @Binding var showInfoModalView: Bool
    let generator = UINotificationFeedbackGenerator()
    @State var product = ProductInfo(type: DeviceType.Mac)
    @Environment(\.presentationMode) var presentation
    var numFormatter: NumberFormatter = {
        let f = NumberFormatter()
        f.numberStyle = .none
        return f
    }()
    var body: some View {
           NavigationView {
                Form
                {
                    Picker("Device", selection: $product.type) {
                        ForEach(DeviceType.allCases, id: \.id) { device in
                            Text(device.id)
                            .tag(device as DeviceType?)
                            }
                        .navigationBarTitle("Device")
                    }
                    
                    Section("Basics")
                    {
                        Group
                        {
                            TextField("Model", text: $product.model ?? "")
                                .autocapitalization(.none)
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
                                .navigationBarTitle("Working Status")
                            }
                            Picker("Condition", selection: $product.condition) {
                                ForEach(Condition.allCases, id: \.id) { status in
                                    Text(status.id)
                                    .tag(status as Condition?)
                                    }
                                .navigationBarTitle("Condition")
                            }
                            Picker("Acquired As", selection: $product.acquiredAs) {
                                ForEach(AcquiredAs.allCases, id: \.id) { status in
                                    Text(status.id)
                                    .tag(status as AcquiredAs?)
                                    }
                                .navigationBarTitle("Acquired As")
                            }
                            Picker("Warranty", selection: $product.warranty) {
                                ForEach(Warranty.allCases, id: \.id) { status in
                                    Text(status.id)
                                    .tag(status as Warranty?)
                                    }
                                .navigationBarTitle("Warranty")
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
                    Section("Device Specifics")
                    {
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
                                .navigationBarTitle("IMEI/ESN Status")
                            }
                            Picker("Carrier Lock Status", selection: $product.carrierLockStatus) {
                                ForEach(CarrierLockStatus.allCases, id: \.id) { status in
                                    Text(status.id)
                                    .tag(status as CarrierLockStatus?)
                                    }
                                .navigationBarTitle("Carrier Lock Status")
                            }

                        }
                        if(product.type == DeviceType.iPad)
                        {
                            Picker("Connectivity", selection: $product.connectivity) {
                                ForEach(iPadConnectivity.allCases, id: \.id) { status in
                                    Text(status.id)
                                    .tag(status as iPadConnectivity?)
                                    }
                                .navigationBarTitle("Connectivity")
                            }
                        }
                        if(product.type == DeviceType.Mac)
                        {
                            Picker("Form Factor", selection: $product.formFactor) {
                                ForEach(FormFactor.allCases, id: \.id) { status in
                                    Text(status.id)
                                    .tag(status as FormFactor?)
                                    }
                                .navigationBarTitle("Form Factor")
                            }
                            if(product.formFactor == FormFactor.Notebook)
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
                            
                            Picker("Storage Type", selection: $product.storageType) {
                                ForEach(StorageType.allCases, id: \.id) { status in
                                    Text(status.id)
                                    .tag(status as StorageType?)
                                    }
                                .navigationBarTitle("Storage Type")
                            }
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
                                .navigationBarTitle("Case Material")
                            }
                            Picker("Connectivity", selection: $product.watchConnectivity) {
                                ForEach(WatchConnectivity.allCases, id: \.id) { status in
                                    Text(status.id)
                                    .tag(status as WatchConnectivity?)
                                    }
                                .navigationBarTitle("Connectivity")
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
                            Picker("Case Type", selection: $product.AirPodsCaseType) {
                                ForEach(AirPodsCaseType.allCases, id: \.id) { status in
                                    Text(status.id)
                                    .tag(status as AirPodsCaseType?)
                                    }
                                .navigationBarTitle("Case Type")
                            }
                        }
                        if(product.type == DeviceType.iPhone || product.type == DeviceType.iPad || product.type == DeviceType.Mac || product.type == DeviceType.AppleWatch || product.type == DeviceType.iPod)
                        {
                            Toggle(isOn: $product.activationLock ?? false)
                            {
                                Text("Activation Lock/Find My On")
                            }
                        }

                        
                    }
                   
                    Section("Additional Comments")
                    {
                        TextField("Comments", text: $product.comments ?? "")
                            .autocapitalization(.none)
                    }

                }
                .navigationBarTitle(Text("Add Product"), displayMode: .inline)
                .navigationBarItems(
                    leading: Button(action: {self.showInfoModalView.toggle()}, label: {Text("Cancel").fontWeight(.regular)}),
                    trailing: Button(action: {addItem()}, label: {Text("Add").bold()}).disabled(product.type == nil || product.model == nil || product.color == nil || product.yearAcquired == nil || product.estimatedValue == nil || product.workingStatus == nil || product.condition == nil || product.acquiredAs == nil || product.warranty == nil || product.physicalDamage == nil || product.originalBox == nil)
                )

           }
        
    }
    func addItem()
    {
        self.generator.notificationOccurred(.success)
        var uuidPrefix = product.type!.id
        if(product.type!.id == "Apple TV")
        {
            uuidPrefix = "AppleTV"
        }
        else if(product.type!.id == "Apple Watch")
        {
            uuidPrefix = "AppleWatch"
        }
        let uuid = uuidPrefix + "_" + UUID().uuidString
        let userDefaults = UserDefaults.standard
        var UUIDArray: [String] = userDefaults.object(forKey: "uuidArray") as? [String] ?? []
        UUIDArray.append(uuid)
        userDefaults.set(UUIDArray, forKey: "uuidArray")
        let manager = ProductInfoManager(uuid:uuid)
        manager.product = product

        self.showInfoModalView.toggle()
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


struct ProductListView_Previews: PreviewProvider{
    static var previews: some View {
        Group {
            ProductListView(title: "iPhone")
                .preferredColorScheme(.dark)
        }
    }
}
