//
//  CircularWidget.swift
//  CircularWidget
//
//  Created by DevJonny on 2024/6/20.
//

import WidgetKit
import SwiftUI
import Intents

struct CircularWidget: Widget {
    let kind: String = "CircularWidget"
    let appLanguage = Bundle.main.preferredLocalizations.first
    
    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: Provider()) { entry in
            CircularWidgetEntryView(entry: entry)
        }
        .configurationDisplayName(appLanguage == "ko" ? "기록 추가하기" : "記録追加する")
        .description(appLanguage == "ko" ? "위젯을 눌러 빠르게 가계 기록을 추가할 수 있어요." : "ウイジェットを押してすぐ家計の記録を追加することができます。")
        .supportedFamilies([.accessoryCircular])
    }
}

struct RectangularWidget: Widget {
    let kind: String = "RectangularWidget"
    let appLanguage = Bundle.main.preferredLocalizations.first
    
    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: Provider()) { entry in
            RectangularWidgetEntryView(entry: entry)
        }
        .configurationDisplayName(appLanguage == "ko" ? "기록 추가하기" : "記録追加する")
        .description(appLanguage == "ko" ? "위젯을 눌러 빠르게 가계 기록을 추가할 수 있어요." : "ウイジェットを押してすぐ家計の記録を追加することができます。")
        .supportedFamilies([.accessoryRectangular])
    }
}

struct Provider: TimelineProvider {
    func placeholder(in context: Context) -> SimpleEntry {
        SimpleEntry(date: Date())
    }

    func getSnapshot(in context: Context, completion: @escaping (SimpleEntry) -> ()) {
        let entry = SimpleEntry(date: Date())
        completion(entry)
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<SimpleEntry>) -> ()) {
        var entries: [SimpleEntry] = []
        let currentDate = Date()
        for hourOffset in 0 ..< 5 {
            let entryDate = Calendar.current.date(byAdding: .hour, value: hourOffset, to: currentDate)!
            let entry = SimpleEntry(date: entryDate)
            entries.append(entry)
        }
        let timeline = Timeline(entries: entries, policy: .atEnd)
        completion(timeline)
    }
}

struct SimpleEntry: TimelineEntry {
    let date: Date
}

struct CircularWidgetEntryView: View {
    var entry: Provider.Entry

    var body: some View {
        ZStack {
            AccessoryWidgetBackground()
            Image(.iconWhite)
                .resizable()
                .frame(width: 58, height: 58)
                .widgetURL(URL(string: "NC2://openDetailSheet")!)
        }
        .containerBackground(Color.clear, for: .widget)
    }
}

struct RectangularWidgetEntryView: View {
    var entry: Provider.Entry
    let appLanguage = Bundle.main.preferredLocalizations.first
    
    var body: some View {
        ZStack {
            AccessoryWidgetBackground()
                .clipShape(RoundedRectangle(cornerRadius: 10))
            VStack (alignment: .leading, spacing: 0) {
                HStack (spacing: 0) {
                    Image(.iconWhite)
                        .resizable()
                        .scaledToFill()
                        .frame(width: 20, height: 20)
                        .clipped()
                    Text("MonEasy")
                        .fontWeight(.bold)
                        .font(.caption)
                        .widgetURL(URL(string: "NC2://openDetailSheet")!)
                }
                .offset(x: -4)
                .padding(.bottom, 4)
                HStack {
                    if appLanguage == "ko" {
                        Text("가계부 기록하기")
                            .font(.system(size: 14))
                    } else if appLanguage == "ja" {
                        Text("家計簿を記録する")
                    }
                    Spacer()
                }
            }
            .padding(.leading, 12)
            .padding(.bottom, 2)
        }
        .containerBackground(Color.clear, for: .widget)
    }
}

struct CircularWidget_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            CircularWidgetEntryView(entry: SimpleEntry(date: Date()))
                .previewContext(WidgetPreviewContext(family: .accessoryCircular))
            RectangularWidgetEntryView(entry: SimpleEntry(date: Date()))
                .previewContext(WidgetPreviewContext(family: .accessoryRectangular))
        }
    }
}

