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
    let appLaunchedBefore = UserDefaults.standard.object(forKey: "launchedBefore")
    @State var continuePressed: Bool = false
    var isiPad: Bool {
        #if targetEnvironment(macCatalyst)
        return false
        #else
        if(UIDevice.current.model.hasPrefix("iPad")) {
            return true
        }
        else {
            return false
        }
        #endif
    }
    var body: some Scene {
        WindowGroup {
            if(appLaunchedBefore == nil && !continuePressed && !isiPad)
            {
                WelcomeView()
                Button(action: {
                    continuePressed.toggle()
                }) {
                    Text("Continue")
                        .customButton()
                }
                #if targetEnvironment(macCatalyst)
                .padding(.top, -50)
                #else
                .padding(.horizontal)
                #endif
            }
            if((appLaunchedBefore != nil || continuePressed) || isiPad)
            {
                ContentView().environmentObject(collectionModel).environmentObject(accentColor)
                    #if targetEnvironment(macCatalyst)
                    .environment(\.defaultMinListRowHeight, 40)
                    .listRowSeparator(.visible)
                    #endif
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
    
    
}

extension UIView {
    func scale(by scale: CGFloat) {
          self.contentScaleFactor = scale
          for subview in self.subviews {
              subview.scale(by: scale)
          }
    }
     
}

extension View {
    func snapshot() -> UIImage {
        let controller = UIHostingController(rootView: self)
        let view = controller.view
        let targetSize = CGSize(width: 500, height: 750)
        view?.bounds = CGRect(origin: .zero, size: targetSize)
        
        let newScale = UIScreen.main.scale
        view?.scale(by: newScale)
        let format = UIGraphicsImageRendererFormat()
        format.scale = newScale

        let renderer = UIGraphicsImageRenderer(size: targetSize)

        return renderer.image { _ in
            view?.drawHierarchy(in: controller.view.bounds, afterScreenUpdates: true)
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


