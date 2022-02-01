//
//  FruitstandApp.swift
//  Fruitstand
//
//  Created by Armand Sarkani on 5/17/21.
//

import SwiftUI
import UIKit

@main
struct FruitstandApp: App {
    @StateObject var collectionModel: CollectionModel = CollectionModel()
    @StateObject var accentColor: AccentColor = AccentColor()
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    var body: some Scene {
        WindowGroup {
            ContentView().environmentObject(collectionModel).environmentObject(accentColor)
                .withHostingWindow { window in
                    #if targetEnvironment(macCatalyst)
                    if let titlebar = window?.windowScene?.titlebar {
                        titlebar.titleVisibility = .hidden
                        titlebar.toolbar = nil
                    }
                    #endif
                }
                .environment(\.font, Font.system(.body, design: .rounded))
                .accentColor(accentColor.color)
        }
        
    }
    
}

extension View {
    func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}

class AccentColor: ObservableObject {
    @Published var color: Color
    init()
    {
        if let testColor = UserDefaults.standard.colorForKey(key: "userColor")
        {
            self.color = Color(testColor)
        }
        else
        {
            self.color = Color.accentColor
        }
    }
    func saveColor()
    {
        UserDefaults.standard.setColor(color: UIColor(color), forKey: "userColor")
    }

}
extension Font {
    public static var subheadline: Font {
        return Font.system(size: 14, design: .rounded)
       }
}
extension UserDefaults {
  func colorForKey(key: String) -> UIColor? {
    var colorReturnded: UIColor?
    if let colorData = data(forKey: key) {
      do {
        if let color = try NSKeyedUnarchiver.unarchiveTopLevelObjectWithData(colorData) as? UIColor {
          colorReturnded = color
        }
      } catch {
        print("Error UserDefaults")
      }
    }
    return colorReturnded
  }
  
  func setColor(color: UIColor?, forKey key: String) {
    var colorData: NSData?
    if let color = color {
      do {
        let data = try NSKeyedArchiver.archivedData(withRootObject: color, requiringSecureCoding: false) as NSData?
        colorData = data
      } catch {
        print("Error UserDefaults")
      }
    }
    set(colorData, forKey: key)
  }
}


extension Collection {
    func choose(_ n: Int) -> ArraySlice<Element> { shuffled().prefix(n) }
}

extension View {
    fileprivate func withHostingWindow(_ callback: @escaping (UIWindow?) -> Void) -> some View {
        self.background(HostingWindowFinder(callback: callback))
    }
}

fileprivate struct HostingWindowFinder: UIViewRepresentable {
    var callback: (UIWindow?) -> ()

    func makeUIView(context: Context) -> UIView {
        let view = UIView()
        DispatchQueue.main.async { [weak view] in
            self.callback(view?.window)
        }
        return view
    }

    func updateUIView(_ uiView: UIView, context: Context) {
    }
}



