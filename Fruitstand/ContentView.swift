//
//  ContentView.swift
//  Fruitstand
//
//  Created by Armand Sarkani on 5/16/21.
//

import SwiftUI


struct ContentView: View {
    let labels: [String] = ["Mac", "iPhone", "iPad", "Apple Watch", "AirPods", "Apple TV", "iPod"]
    let icons: [String: String] = ["Mac": "desktopcomputer", "iPhone": "iphone", "iPad": "ipad", "Apple Watch": "applewatch", "AirPods": "airpodspro", "Apple TV": "appletv.fill", "iPod": "ipod"]
    @State var showInfoModalView: Bool = false
    @State var searchText: String = ""
    var body: some View {
        NavigationView {
            List {
                Section(header: Text("Devices"))
                {
                    ForEach(labels, id: \.self) { label in
                        NavigationLink(destination: ProductView(title: label)){
                            Label(label, systemImage: icons[label]!)
                        }
                    }
                }
                Section(header: Text("Statistics"))
                {
                    NavigationLink(destination: CountsView()){
                        Label("Counts", systemImage: "sum")
                    }
                    NavigationLink(destination: ValuesView()){
                        Label("Values", systemImage: "dollarsign.circle.fill")
                    }
                }
               
            }
            .listStyle(InsetGroupedListStyle())
            .environment(\.horizontalSizeClass, .regular)
            .navigationBarTitle(Text("My Collection"))
            .navigationBarItems(trailing:
                Button(action: {
                    showInfoModalView.toggle()
                    }) {
                        Image(systemName: "plus")
                            .imageScale(.large)
                    }
                )
            
        }
        .sheet(isPresented: $showInfoModalView) {
            AddProductView(showInfoModalView: self.$showInfoModalView)
        }
    }

}
struct SearchBar: View {
    @Binding var text: String
    @State private var isEditing = false
 
    var body: some View {
        HStack {
            TextField("Search ...", text: $text)
                .padding(7)
                .padding(.horizontal, 25)
                .background(Color(.systemGray6))
                .cornerRadius(8)
                .overlay(
                    HStack {
                        Image(systemName: "magnifyingglass")
                            .foregroundColor(.gray)
                            .frame(minWidth: 0, maxWidth: .infinity, alignment: .leading)
                            .padding(.leading, 8)
                 
                        if isEditing {
                            Button(action: {
                                self.text = ""
                            }) {
                                Image(systemName: "multiply.circle.fill")
                                    .foregroundColor(.gray)
                                    .padding(.trailing, 8)
                            }
                        }
                    }
                )
                .padding(.horizontal, 10)
                .onTapGesture {
                    self.isEditing = true
                }
 
            if isEditing {
                Button(action: {
                    self.isEditing = false
                    self.text = ""
 
                }) {
                    Text("Cancel")
                }
                .padding(.trailing, 10)
                .transition(.move(edge: .trailing))
                .animation(.default)
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider{
    static var previews: some View {
        Group {
            ContentView()
                .preferredColorScheme(.dark)
        }
    }
}

struct CountsView: View {
    var body: some View {
        Image(systemName: "sum")
            .resizable()
            .frame(width: 32, height: 48)
        Spacer()
            .frame(width: 30.0, height: 30.0)
        Text("Product Count Statistics")
            .font(.title)
        Text("This feature is coming soon!")
            .font(.body)
            
    }
    
}
struct ValuesView: View {
    var body: some View {
        Image(systemName: "dollarsign.circle.fill")
            .resizable()
            .frame(width: 48, height: 48)
        Spacer()
            .frame(width: 30.0, height: 30.0)
        Text("Product Value Statistics")
            .font(.title)
        Text("This feature is coming soon!")
            .font(.body)
            
            
    }
    
}
