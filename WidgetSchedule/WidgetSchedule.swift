//
//  WidgetSchedule.swift
//  WidgetSchedule
//
//  Created by Shibo Lyu on 2020/6/23.
//  Copyright © 2020 Inkwire Tech (Hangzhou) Co., Ltd. All rights reserved.
//

import WidgetKit
import SwiftUI
import Alamofire

struct LMWidgetScheduleData {
    private var token: String? {
        let sharedUd = UserDefaults.init(suiteName: "group.help.hdu.lemon.ios")
        return sharedUd?.string(forKey: "token")
    }
}

struct Provider: TimelineProvider {
    public typealias Entry = ScheduleEntry

    public func snapshot(with context: Context, completion: @escaping (ScheduleEntry) -> ()) {
        let entry = ScheduleEntry(date: Date())
        completion(entry)
    }

    public func timeline(with context: Context, completion: @escaping (Timeline<Entry>) -> ()) {
        var entries: [ScheduleEntry] = []

        // Generate a timeline consisting of five entries an hour apart, starting from the current date.
        let currentDate = Date()
        for hourOffset in 0 ..< 5 {
            let entryDate = Calendar.current.date(byAdding: .hour, value: hourOffset, to: currentDate)!
            let entry = ScheduleEntry(date: entryDate)
            entries.append(entry)
        }

        let timeline = Timeline(entries: entries, policy: .atEnd)
        completion(timeline)
    }
}

struct ScheduleEntry: TimelineEntry {
    public let date: Date
}

struct PlaceholderView : View {
    var body: some View {
        Text("Placeholder View")
    }
}

struct WidgetScheduleEntryView : View {
    var entry: Provider.Entry

    var body: some View {
        Text(entry.date, style: .time)
    }
}

@main
struct WidgetSchedule: Widget {
    private let kind: String = "WidgetSchedule"

    public var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: Provider(), placeholder: PlaceholderView()) { entry in
            WidgetScheduleEntryView(entry: entry)
        }
        .configurationDisplayName("My Widget")
        .description("This is an example widget.")
    }
}
