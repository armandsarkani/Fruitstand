//
//  ProductView.swift
//  Fruitstand
//
//  Created by Armand Sarkani on 5/17/21.
//

import SwiftUI

struct ProductView: View {
    var title: String
    var body: some View {
        Text(title)
            .font(.title)
            
    }
    
}

enum DeviceType: String, CaseIterable, Identifiable {
    case Mac
    case iPhone
    case iPad
    case AppleWatch
    case AirPods
    case AppleTV
    case iPod
    
    var id: String { self.rawValue }
}


struct AddProductView: View {
    @Binding var showInfoModalView: Bool
    let generator = UINotificationFeedbackGenerator()
    @State var selectedDevice = DeviceType.Mac
    @State var formCompleted = false
    var body: some View {
           NavigationView {
                Form
                {
                    Picker("Device", selection: $selectedDevice) {
                        Text("Mac").tag(DeviceType.Mac)
                        Text("iPhone").tag(DeviceType.iPhone)
                        Text("iPad").tag(DeviceType.iPad)
                        Text("Apple Watch").tag(DeviceType.AppleWatch)
                        Text("AirPods").tag(DeviceType.AirPods)
                        Text("Apple TV").tag(DeviceType.AppleTV)
                        Text("iPod").tag(DeviceType.iPod)
                        .navigationBarTitle("Device")
                    }
                }
                .navigationBarTitle(Text("Add Product"), displayMode: .inline)
                .navigationBarItems(
                    leading: Button(action: {self.showInfoModalView.toggle()}, label: {Text("Cancel").fontWeight(.regular)}),
                    trailing: Button(action: {addItem()}, label: {Text("Add")}).disabled(formCompleted == false)
                )

           }
        
    }
    func addItem()
    {
        self.generator.notificationOccurred(.success)
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
