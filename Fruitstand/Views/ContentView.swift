//
//  ContentView.swift
//  Fruitstand
//
//  Created by Armand Sarkani on 5/16/21.
//

// This module is responsible for the view layouts of the main screen and model list screen.


import SwiftUI
import AlertToast
import Introspect
import UIKit

// Global variables
var keyStore = NSUbiquitousKeyValueStore()
let icons: [String: String] = ["Mac": "laptopcomputer", "iPhone": "iphone", "iPad": "ipad", "Apple Watch": "applewatch", "AirPods": "airpodspro", "Apple TV": "appletv.fill", "iPod": "ipod"]
extension View {
    func `if`<Content: View>(_ conditional: Bool, content: (Self) -> Content) -> some View {
         if conditional {
             return AnyView(content(self))
         } else {
             return AnyView(self)
         }
     }
}
var displayMode: NavigationBarItem.TitleDisplayMode = .automatic


struct ContentView: View {
    @State var showInfoModalView: Bool = false
    @State private var collectionFull: Bool = false
    @State var showSettingsModalView: Bool = false
    @State private var searchQuickAction: Bool = false
    @State private var showToast: Bool = false
    @State var count = 1
    @EnvironmentObject var collectionModel: CollectionModel
    @EnvironmentObject var accentColor: AccentColor
    @EnvironmentObject var quickActions: QuickActionService
    @State var showiPadWelcomeScreen: Bool = false
    @Environment(\.colorScheme) var colorScheme
    @Environment(\.horizontalSizeClass) var horizontalSizeClass: UserInterfaceSizeClass?
    init() {
        let design = UIFontDescriptor.SystemDesign.rounded
        let largeTitleDescriptor = UIFontDescriptor.preferredFontDescriptor(withTextStyle: .largeTitle).withDesign(design)!.withSymbolicTraits(.traitBold)
        let largeTitleFont = UIFont.init(descriptor: largeTitleDescriptor!, size: largeTitleDescriptor!.pointSize)
        UINavigationBar.appearance().largeTitleTextAttributes = [.font : largeTitleFont]
        let inlineDescriptor = UIFontDescriptor.preferredFontDescriptor(withTextStyle: .body).withDesign(design)!.withSymbolicTraits(.traitBold)
        let inlineFont = UIFont.init(descriptor: inlineDescriptor!, size: inlineDescriptor!.pointSize)
        UINavigationBar.appearance().titleTextAttributes = [.font: inlineFont]
    }
    var body: some View {
        NavigationView {
            List {
                if(UIDevice.current.model.hasPrefix("iPad") && horizontalSizeClass != .compact)
                {
                    NavigationLink(destination: SearchView().environmentObject(collectionModel).environmentObject(accentColor), isActive: $searchQuickAction)
                    {
                        Label("Search", systemImage: "magnifyingglass")
                    }
                    .keyboardShortcut("f", modifiers: .command)
                }
                Section(header: Text("Devices").rootSectionHeader(horizontalSizeClass: horizontalSizeClass))
                {
                    ForEach(DeviceType.allCases, id: \.self) { label in
                        NavigationLink(destination: ProductListView(deviceType: label).environmentObject(collectionModel).environmentObject(accentColor)){
                            Label(label.id, systemImage: icons[label.id]!)
                                .fixedSize()
                            Spacer()

                            Text(String(collectionModel.collection[label]!.count))
                                .foregroundColor(.secondary)
                        }
                    }
                }
                Section(header: Text("Statistics").rootSectionHeader(horizontalSizeClass: horizontalSizeClass))
                {
                    HStack
                    {
                        Label("Collection Size", systemImage: "sum")
                            .fixedSize()
                        Spacer()
                        Text(String(collectionModel.collectionSize))
                            .foregroundColor(.secondary)
                    }
                    NavigationLink(destination: ValuesView().environmentObject(collectionModel).environmentObject(accentColor)){
                        HStack
                        {
                            Label("Values", systemImage: "dollarsign.circle.fill")
                                .fixedSize()
                            Spacer()
                            Text(String(format: "$%d", locale: Locale.current, getTotalCollectionValue(collection: collectionModel.collection)))
                                .foregroundColor(.secondary)
                        }
                    }
                
                }

            }
            .navigationBarTitleDisplayMode(.large)
            .if(UIDevice.current.model.hasPrefix("iPad") && horizontalSizeClass != .compact) {
                $0.listStyle(SidebarListStyle())
                .introspectTableView { introspect in
                    introspect.backgroundColor = .secondarySystemBackground
                }
            }
            #if targetEnvironment(macCatalyst)
            .environment(\.defaultMinListRowHeight, 30)
            #endif
            .navigationTitle(Text("My Collection"))
            .toolbar {
                #if !targetEnvironment(macCatalyst)
                ToolbarItem(placement: .navigationBarLeading)
                {
                    Button(action: { showSettingsModalView.toggle()}) {
                        Image(systemName: "gearshape")
                            .imageScale(.large)
                            .frame(height: 96, alignment: .trailing)
                    }

                }
                #endif
                ToolbarItem(placement: .navigationBarTrailing)
                {
                    HStack
                    {
                        #if targetEnvironment(macCatalyst)
                        Button(action: { showSettingsModalView.toggle()}) {
                            Image(systemName: "gearshape")
                                .imageScale(.large)
                                .frame(height: 96, alignment: .trailing)
                        }
                        #endif
                        if(UIDevice.current.model.hasPrefix("iPhone") || horizontalSizeClass == .compact) {
                            NavigationLink(destination: SearchView().environmentObject(collectionModel).environmentObject(accentColor), isActive: $searchQuickAction)
                            {
                                Image(systemName: "magnifyingglass")
                                    .imageScale(.large)
                                    .frame(height: 96, alignment: .trailing)
                            }
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
                            .keyboardShortcut("a", modifiers: .command)

                        
                    }
                }
            }
            .alert(isPresented: $collectionFull) {
                Alert(
                    title: Text("1000 Product Limit Reached"),
                    message: Text("Remove at least one product from your collection before adding new ones."),
                    dismissButton: .default(Text("OK"))
                )
            }
            .onAppear {
                collectionModel.loadCollection(count: count)
                count += 1
                #if targetEnvironment(macCatalyst)
                    showiPadWelcomeScreen = false
                #else
                    if(UIDevice.current.model.hasPrefix("iPad")) {
                        if UserDefaults.standard.object(forKey: "launchedBefore") != nil {
                            showiPadWelcomeScreen = false
                        }
                        else {
                            showiPadWelcomeScreen = true
                        }
                    }
                    else {
                        showiPadWelcomeScreen = false
                    }
                #endif

            }
            .onReceive(self.quickActions.$action, perform: { action in
                if(action == QuickAction.add)
                {
                    if(collectionModel.collectionSize >= 1000)
                    {
                        generator.notificationOccurred(.error)
                        collectionFull.toggle()
                    }
                    else {
                        showInfoModalView.toggle()
                    }
                }
                else if(action == QuickAction.search)
                {
                    searchQuickAction.toggle()
                }
            })

        }
        #if targetEnvironment(macCatalyst)
        .introspectSplitViewController { controller in
              controller.preferredPrimaryColumnWidth = 270
        }
        #endif
//        .if(UIDevice.current.model.hasPrefix("iPhone") || horizontalSizeClass == .compact) {
//            $0.navigationViewStyle(StackNavigationViewStyle())
//        }
        .toast(isPresenting: $showToast, duration: 1) {
            AlertToast(type: .complete(accentColor.color), title: "Product Added", style: AlertToast.AlertStyle.style(titleFont: Font.system(.title3, design: .rounded).bold()))
        }
        .sheet(isPresented: $showInfoModalView, onDismiss: {
            if(collectionModel.productJustAdded) {
                showToast.toggle()
                collectionModel.productJustAdded = false
            }
        }) {
            AddProductView(showInfoModalView: self.$showInfoModalView).environmentObject(collectionModel).environmentObject(accentColor)

        }
        .sheet(isPresented: $showSettingsModalView) {
            SettingsView(showSettingsModalView: self.$showSettingsModalView).environmentObject(collectionModel).environmentObject(accentColor)

        }
        .sheet(isPresented: $showiPadWelcomeScreen) {
            WelcomeView()
            Button(action: {
                showiPadWelcomeScreen.toggle()
            }) {
                Text("Continue")
                    .customButton()
            }
            .padding(.horizontal)
        }

    }

}

struct CustomSectionHeaderViewModifier: ViewModifier {
    let font = Font.system(.headline, design: .rounded).weight(.medium)
    func body(content: Content) -> some View {
        content
            .font(font)
            .textCase(nil)
            .foregroundColor(.secondary)
        #if targetEnvironment(macCatalyst)
            .padding(.bottom, 10)
            .padding(.top, 10)
        #else
            .padding(.bottom, 2)
        #endif
    }
}

struct RootSectionHeaderViewModifier: ViewModifier {
    var horizontalSizeClass: UserInterfaceSizeClass?
    let compactFont = Font.system(.headline, design: .rounded).weight(.medium)
    let largeFont = Font.system(.title3, design: .rounded).weight(.semibold)
    func body(content: Content) -> some View {
        #if !targetEnvironment(macCatalyst)
        if(UIDevice.current.model.hasPrefix("iPhone") || (UIDevice.current.model.hasPrefix("iPad") && horizontalSizeClass == .compact))
        {
            content
                .font(compactFont)
                .textCase(nil)
                .foregroundColor(.secondary)
                .padding(.bottom, 2)
        }
        else {
            content
                .font(largeFont)
        }
        #else
        content
            .font(largeFont)
            .padding(.top, 5)
            .padding(.bottom, 5)
        #endif
    }
}

extension View {
    func customSectionHeader() -> some View {
        modifier(CustomSectionHeaderViewModifier())
    }
    func rootSectionHeader(horizontalSizeClass: UserInterfaceSizeClass?) -> some View {
        modifier(RootSectionHeaderViewModifier(horizontalSizeClass: horizontalSizeClass))
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
