//
//  WelcomeView.swift
//  Fruitstand
//
//  Created by Armand Sarkani on 2/1/22.
//

import Foundation
import SwiftUI

struct WelcomeView: View {
    init() {
        UserDefaults.standard.set(true, forKey: "launchedBefore")
    }
    var body: some View {
        ScrollView {
            VStack(alignment: .center) {

                Spacer()

                TitleView()

                InformationContainerView()

                Spacer(minLength: 80)

            }
        }
    }
}

struct TitleView: View {
    var body: some View {
        VStack {
            Image("AppIconTransparent")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(height: 200, alignment: .center)
                .accessibility(hidden: true)
            Text("Welcome to")
                .customTitleText()

            Text("Fruitstand")
                .customTitleText()
                .foregroundColor(.mainColor)
        }
    }
}

struct InformationContainerView: View {
    var body: some View {
        VStack(alignment: .leading) {
            InformationDetailView(title: "Add Products", subTitle: "Beautifully display your collection of Mac, iPhone, iPad, Apple Watch, AirPods, Apple TV, and iPod.", imageName: "laptopcomputer")

            InformationDetailView(title: "iCloud Sync", subTitle: "Sync your collection across all of your devices.", imageName: "icloud.fill")

            InformationDetailView(title: "Import Collection", subTitle: "Easily import your products using a CSV file.", imageName: "arrow.down.doc.fill")
        }
        .padding(.horizontal)
    }
}

struct InformationDetailView: View {
    var title: String = "title"
    var subTitle: String = "subTitle"
    var imageName: String = "iphone"

    var body: some View {
        HStack(alignment: .center) {
            Image(systemName: imageName)
                .font(.largeTitle)
                .frame(width: 50, height: 50, alignment: .center)
                .foregroundColor(.mainColor)
                .padding(.all, 10)
                .accessibility(hidden: true)
            VStack(alignment: .leading) {
                Text(title)
                    .font(.system(.headline, design: .rounded))
                    .foregroundColor(.primary)
                    .accessibility(addTraits: .isHeader)

                Text(subTitle)
                    .font(.system(.body, design: .rounded))
                    .foregroundColor(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
        .padding(.top)
    }
}

struct ButtonModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .foregroundColor(.white)
            .font(.system(.headline, design: .rounded))
            .padding()
            .frame(minWidth: 0, maxWidth: .infinity, alignment: .center)
            .background(RoundedRectangle(cornerRadius: 15, style: .continuous)
                .fill(Color.mainColor))
            .padding(.bottom)
    }
}

extension View {
    func customButton() -> ModifiedContent<Self, ButtonModifier> {
        return modifier(ButtonModifier())
    }
}

extension Text {
    func customTitleText() -> Text {
        self
            .fontWeight(.bold)
            .font(.system(size: 36, design: .rounded))
    }
}

extension Color {
    static var mainColor = Color.accentColor
}
