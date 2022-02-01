//
//  Fruitstand_Widget.swift
//  Fruitstand Widget
//
//  Created by Armand Sarkani on 1/23/22.
//

import WidgetKit
import SwiftUI
import Intents

let icons: [String: String] = ["Mac": "laptopcomputer", "iPhone": "iphone", "iPad": "ipad", "Apple Watch": "applewatch", "AirPods": "airpodspro", "Apple TV": "appletv.fill", "iPod": "ipod"]

/**** Provider and Model ****/

struct Provider: IntentTimelineProvider {
    func placeholder(in context: Context) -> WidgetEntry {
        WidgetEntry(date: Date(), configuration: ConfigurationIntent(), widgetModel: WidgetModel(accentColor: .blue, deviceTypeCounts: getPlaceholderCounts(), collectionSize: 200, deviceTypeValues: getPlaceholderValues(), averageValues: getPlaceholderValues(), totalCollectionValue: 10000))
    }
    func getSnapshot(for configuration: ConfigurationIntent, in context: Context, completion: @escaping (WidgetEntry) -> ()) {
        let entry = WidgetEntry(date: Date(), configuration: configuration, widgetModel: WidgetModel(accentColor: .blue, deviceTypeCounts: getPlaceholderCounts(), collectionSize: 200, deviceTypeValues: getPlaceholderValues(), averageValues: getPlaceholderValues(), totalCollectionValue: 28225))
        completion(entry)
    }

    func getTimeline(for configuration: ConfigurationIntent, in context: Context, completion: @escaping (Timeline<Entry>) -> ()) {
        var entries: [WidgetEntry] = []

        
        let currentWidgetModel = UserDefaults(suiteName: "group.armandsarkani.fruitstand")!.getCodableObject(dataType: WidgetModel.self, key: "widgetModel")!
        let entry = WidgetEntry(date: Date(), configuration: configuration, widgetModel: currentWidgetModel)
        entries.append(entry)

        let timeline = Timeline(entries: entries, policy: .never)
        completion(timeline)
    }
    func getPlaceholderCounts() -> [DeviceTypeCount] {
        return [DeviceTypeCount(deviceType: DeviceType.Mac, count: 60),
            DeviceTypeCount(deviceType: DeviceType.iPhone, count: 50),
            DeviceTypeCount(deviceType: DeviceType.iPod, count: 35),
            DeviceTypeCount(deviceType: DeviceType.iPad, count: 20),
            DeviceTypeCount(deviceType: DeviceType.AppleTV, count: 15),
            DeviceTypeCount(deviceType: DeviceType.AppleWatch, count: 10),
            DeviceTypeCount(deviceType: DeviceType.AirPods, count: 10)]
    }
    func getPlaceholderValues() -> [DeviceTypeValue] {
        return [DeviceTypeValue(deviceType: DeviceType.Mac, totalValue: 12000, averageValue: 200),
                DeviceTypeValue(deviceType: DeviceType.iPhone, totalValue: 7500, averageValue: 150),
                DeviceTypeValue(deviceType: DeviceType.iPad, totalValue: 3500, averageValue: 175),
                DeviceTypeValue(deviceType: DeviceType.AppleWatch, totalValue: 1950, averageValue: 195),
                DeviceTypeValue(deviceType: DeviceType.iPod, totalValue: 1400, averageValue: 40),
                DeviceTypeValue(deviceType: DeviceType.AppleTV, totalValue: 1125, averageValue: 75),
                DeviceTypeValue(deviceType: DeviceType.AirPods, totalValue: 750, averageValue: 75)]
    }
}

struct WidgetEntry: TimelineEntry {
    let date: Date
    let configuration: ConfigurationIntent
    var widgetModel: WidgetModel
}

/**** Counts widget views ****/

struct SmallCountsWidgetView: View {
    var entry: Provider.Entry
    var body: some View {
        VStack(alignment: .leading, spacing: 2) {
            HStack {
                ForEach(0..<4) { i in
                    Image(systemName: icons[entry.widgetModel.deviceTypeCounts[i].deviceType.id]!)
                        .foregroundColor(entry.widgetModel.accentColor)
                        .imageScale(.large)
                }
               
            }
            Text(String(entry.widgetModel.collectionSize))
                .font(.system(size: 48, design: .rounded))
                .fontWeight(.semibold)
            Text("Apple Products")
                .foregroundColor(.gray)
                .fontWeight(.medium)
                .font(.system(.headline, design: .rounded))
        }
    }
}

struct MediumCountsWidgetView: View {
    var entry: Provider.Entry
    var body: some View {
        GeometryReader { geo in
            VStack (alignment: .leading, spacing: 0.05*geo.size.height) {
                Text("Collection Size by Product")
                    .foregroundColor(.gray)
                    .fontWeight(.medium)
                    .font(.system(.headline, design: .rounded))
                HStack(alignment: .center) {
                    VStack(alignment: .leading, spacing: 0.06*geo.size.height) {
                        ForEach([0, 2], id: \.self) { element in
                            MediumCountsWidgetDetailView(entry: entry, element: element, geo: geo)
                        }
                    }
                    if(entry.widgetModel.deviceTypeCounts[0].deviceType == DeviceType.AppleWatch || entry.widgetModel.deviceTypeCounts[0].deviceType == DeviceType.AppleTV || entry.widgetModel.deviceTypeCounts[2].deviceType == DeviceType.AppleWatch || entry.widgetModel.deviceTypeCounts[2].deviceType == DeviceType.AppleTV) // longer strings
                    {
                        Spacer()
                            .frame(width: 0.11*geo.size.width)
                    }
                    else if(entry.widgetModel.deviceTypeCounts[0].deviceType == DeviceType.AirPods ||  entry.widgetModel.deviceTypeCounts[2].deviceType == DeviceType.AirPods) // longer strings
                    {
                        Spacer()
                            .frame(width: 0.13*geo.size.width)
                    }
                    else
                    {
                        Spacer()
                            .frame(width: 0.25*geo.size.width)
                    }
                    VStack(alignment: .leading, spacing:  0.06*geo.size.height) {
                        ForEach([1, 3], id: \.self) { element in
                            MediumCountsWidgetDetailView(entry: entry, element: element, geo: geo)
                        }
                    }
                }
            }
            .frame(width: geo.size.width*0.9, alignment: .leading)
            .padding(.top, 0.08*geo.size.height)
            .padding(.leading, 0.08*geo.size.width)
        }
        
    }
}

struct MediumCountsWidgetDetailView: View {
    var entry: Provider.Entry
    var element: Int
    var geo: GeometryProxy
    var body: some View {
        HStack(alignment: .center) {
            Image(systemName: icons[entry.widgetModel.deviceTypeCounts[element].deviceType.id]!)
                .frame(width: 0.05*geo.size.width)
                .foregroundColor(entry.widgetModel.accentColor)
                .scaleEffect(1.5)
            Spacer()
                .frame(width: 0.08*geo.size.width)
            VStack(alignment: .leading) {
                Text(String(entry.widgetModel.deviceTypeCounts[element].count))
                    .font(.system(size: 0.06*geo.size.width, design: .rounded))
                    .fontWeight(.semibold)
                    .fixedSize()
                Text(entry.widgetModel.deviceTypeCounts[element].deviceType.id)
                    .foregroundColor(.gray)
                    .fontWeight(.medium)
                    .font(.system(.subheadline, design: .rounded))
                    .fixedSize()
            }
        }
    }
}

/**** Values widget views ****/

struct SmallValuesWidgetView: View {
    var entry: Provider.Entry
    var body: some View {
        VStack(alignment: .leading, spacing: 2) {
            HStack {
                Image(systemName: "dollarsign.circle.fill")
                    .foregroundColor(entry.widgetModel.accentColor)
                    .imageScale(.large)
                HStack {
                    ForEach(0..<3) { i in
                        Image(systemName: icons[entry.widgetModel.deviceTypeValues[i].deviceType.id]!)
                            .foregroundColor(entry.widgetModel.accentColor)
                            .imageScale(.large)
                    }
                   
                }
               
            }
            Text(String(format: "$%d", locale: Locale.current, entry.widgetModel.totalCollectionValue))
                .font(.system(.title, design: .rounded))
                .fontWeight(.semibold)
            Text("Collection Value")
                .foregroundColor(.gray)
                .fontWeight(.medium)
                .font(.system(.headline, design: .rounded))
                .minimumScaleFactor(0.0001)
                .lineLimit(2)
        }
    }
}

struct MediumValuesWidgetView: View {
    var entry: Provider.Entry
    var body: some View {
        GeometryReader { geo in
            VStack (alignment: .leading, spacing: 0.08*geo.size.height) {
                Text("Estimated Value by Product")
                    .foregroundColor(.gray)
                    .fontWeight(.medium)
                    .font(.system(.headline, design: .rounded))
                HStack(alignment: .center) {
                    VStack(alignment: .leading, spacing: 0.06*geo.size.height) {
                        ForEach([0, 2], id: \.self) { element in
                            MediumValuesWidgetDetailView(entry: entry, element: element, geo: geo)
                        }
                    }
                    Spacer().frame(width: 0.13*geo.size.width)
                    VStack(alignment: .leading, spacing:  0.06*geo.size.height) {
                        ForEach([1, 3], id: \.self) { element in
                            MediumValuesWidgetDetailView(entry: entry, element: element, geo: geo)
                        }
                    }
                }
            }
            .frame(width: geo.size.width*0.9, alignment: .leading)
            .padding(.top, 0.08*geo.size.height)
            .padding(.leading, 0.08*geo.size.width)
        }
    }
}

struct MediumValuesWidgetDetailView: View {
    var entry: Provider.Entry
    var element: Int
    var geo: GeometryProxy
    
    var body: some View {
        HStack(alignment: .center) {
            Image(systemName: icons[entry.widgetModel.deviceTypeValues[element].deviceType.id]!)
                .frame(width: 0.05*geo.size.width)
                .foregroundColor(entry.widgetModel.accentColor)
                .scaleEffect(1.5)
            Spacer()
                .frame(width: 0.08*geo.size.width)
            VStack(alignment: .leading) {
                Text(String(format: "$%d", locale: Locale.current, entry.widgetModel.deviceTypeValues[element].totalValue!))
                    .font(.system(size: 0.05*geo.size.width, design: .rounded))
                    .fontWeight(.semibold)
                    .fixedSize()
                Text(entry.widgetModel.deviceTypeValues[element].deviceType.id)
                    .foregroundColor(.gray)
                    .fontWeight(.medium)
                    .font(.system(.subheadline, design: .rounded))
                    .fixedSize()
            }
            .frame(width: 0.22*geo.size.width, alignment: .leading)
        }
    }
}

struct LargeValuesWidgetView: View {
    var entry: Provider.Entry
    var body: some View {
        GeometryReader { geo in
            VStack(alignment: .leading, spacing: -0.18*geo.size.height) {
                MediumValuesWidgetView(entry: entry)
                GeometryReader { geo in
                    VStack (alignment: .leading, spacing: 0.08*geo.size.height) {
                        Text("Average Value by Product")
                            .foregroundColor(.gray)
                            .fontWeight(.medium)
                            .font(.system(.headline, design: .rounded))
                        HStack {
                            VStack(alignment: .leading, spacing: 0.06*geo.size.height) {
                                ForEach([0, 2], id: \.self) { element in
                                    AverageValuesDetailView(entry: entry, element: element, geo: geo)
                                }
                                Text("Collection Value")
                                    .foregroundColor(.gray)
                                    .fontWeight(.medium)
                                    .font(.system(.headline, design: .rounded))
                                    .fixedSize()
                            }
                            Spacer().frame(width: 0.13*geo.size.width)
                            VStack(alignment: .leading, spacing:  0.06*geo.size.height) {
                                ForEach([1, 3], id: \.self) { element in
                                    AverageValuesDetailView(entry: entry, element: element, geo: geo)
                                }
                                Text(String(format: "$%d", locale: Locale.current, entry.widgetModel.totalCollectionValue))
                                    .font(.system(size: 0.05*geo.size.width, design: .rounded))
                                    .fontWeight(.semibold)
                                    .fixedSize()
                                    .padding(5)
                                    .background(RoundedRectangle(cornerRadius: 10).fill(entry.widgetModel.accentColor))
                            }
                        }
                        
                    }
                    .frame(width: geo.size.width*0.9, alignment: .leading)
                    .padding(.top, 0.08*geo.size.height)
                    .padding(.leading, 0.08*geo.size.width)
                }
            }
        }
       
       
    }
}

struct AverageValuesDetailView: View {
    var entry: Provider.Entry
    var element: Int
    var geo: GeometryProxy
    
    var body: some View {
        HStack {
            Image(systemName: icons[entry.widgetModel.averageValues[element].deviceType.id]!)
                .frame(width: 0.05*geo.size.width)
                .foregroundColor(entry.widgetModel.accentColor)
                .scaleEffect(1.5)
            Spacer()
                .frame(width: 0.08*geo.size.width)
            VStack(alignment: .leading) {
                Text(String(format: "$%.2f", locale: Locale.current, entry.widgetModel.averageValues[element].averageValue ?? 0.0))
                    .font(.system(size: 0.05*geo.size.width, design: .rounded))
                    .fontWeight(.semibold)
                    .fixedSize()
                Text(entry.widgetModel.averageValues[element].deviceType.id)
                    .foregroundColor(.gray)
                    .fontWeight(.medium)
                    .font(.system(.subheadline, design: .rounded))
                    .fixedSize()
            }
            .frame(width: 0.22*geo.size.width, alignment: .leading)
        }
    }
}

/**** Entry views ****/

struct Fruitstand_CountsWidgetEntryView : View {
    var entry: Provider.Entry
    @Environment(\.widgetFamily) var family: WidgetFamily
    var body: some View {
        switch family {
            case .systemSmall: SmallCountsWidgetView(entry: entry)
        case .systemMedium: MediumCountsWidgetView(entry: entry)
            default: EmptyView()
        }
    }
}

struct Fruitstand_ValuesWidgetEntryView : View {
    var entry: Provider.Entry
    @Environment(\.widgetFamily) var family: WidgetFamily
    var body: some View {
        switch family {
            case .systemSmall: SmallValuesWidgetView(entry: entry)
            case .systemMedium: MediumValuesWidgetView(entry: entry)
            case .systemLarge: LargeValuesWidgetView(entry: entry)
            default: EmptyView()
        }
    }
}


/**** Widgets ****/

@main
struct FruitstandWidgets: WidgetBundle {
    @WidgetBundleBuilder
    var body: some Widget {
        Fruitstand_CountsWidget()
        Fruitstand_ValuesWidget()
    }
}


struct Fruitstand_CountsWidget: Widget {
    let kind: String = "Fruitstand_CountsWidget"

    var body: some WidgetConfiguration {
        IntentConfiguration(kind: kind, intent: ConfigurationIntent.self, provider: Provider()) { entry in
            Fruitstand_CountsWidgetEntryView(entry: entry)
        }
        .configurationDisplayName("Device Type Counts")
        .description("View device count information about your collection.")
        .supportedFamilies([.systemSmall, .systemMedium])
    }
}

struct Fruitstand_ValuesWidget: Widget {
    let kind: String = "Fruitstand_ValuesWidget"

    var body: some WidgetConfiguration {
        IntentConfiguration(kind: kind, intent: ConfigurationIntent.self, provider: Provider()) { entry in
            Fruitstand_ValuesWidgetEntryView(entry: entry)
        }
        .configurationDisplayName("Collection Value")
        .description("View value information about your collection.")
        .supportedFamilies([.systemSmall, .systemMedium, .systemLarge])
    }
}

