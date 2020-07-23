//
//  WidgetSchedule.swift
//  WidgetSchedule
//
//  Created by Shibo Lyu on 2020/6/23.
//  Copyright © 2020 Inkwire Tech (Hangzhou) Co., Ltd. All rights reserved.
//

import WidgetKit
import SwiftUI

struct ScheduleProvider: TimelineProvider {
    public typealias Entry = ScheduleEntry
    
    public static let placeholderEntry = ScheduleEntry(date: Date(), items: [
        LMWidgetScheduleItem(course: "大学英语", classRoom: "7教123", startTime: "8:05", endTime: "11:35", teacher: "竺寿", isTomorrow: false),
        LMWidgetScheduleItem(course: "办公自动化软件", classRoom: "3教317", startTime: "13:30", endTime: "16:10", teacher: "竺寿", isTomorrow: false)
    ], errored: false)

    public func snapshot(with context: Context, completion: @escaping (ScheduleEntry) -> ()) {
        completion(ScheduleProvider.placeholderEntry)
    }

    public func timeline(with context: Context, completion: @escaping (Timeline<Entry>) -> ()) {
        var entries: [ScheduleEntry] = []

        LMWidgetScheduleItem.fetchData { items in
            guard items != nil else {
                // Error happened.
                let timeline = Timeline(entries: [ScheduleEntry(date: Date(), items: [], errored: true)], policy: .atEnd)
                completion(timeline)
                return
            }
            var remainingItems = items!
            var startingDate = Date()
            if remainingItems.isEmpty {
                entries.append(
                    ScheduleEntry(date: startingDate, items: [], errored: false)
                )
                let timeline = Timeline(entries: entries, policy: .after(
                    // Sometimes there could be a schedule change. So refetch after an hour.
                    Calendar.current.date(byAdding: .hour, value: 1, to: Date())!
                ))
                completion(timeline)
                return
            }
            while !remainingItems.isEmpty {
                let firstItem = remainingItems.first!
                entries.append(
                    ScheduleEntry(date: startingDate, items: remainingItems, errored: false)
                )
                startingDate = firstItem.endTimeInDate
                remainingItems.removeFirst()
            }
            
            let timeline = Timeline(entries: entries, policy: .atEnd)
            completion(timeline)
        }
    }
}

struct ScheduleEntry: TimelineEntry {
    let date: Date
    let items: [LMWidgetScheduleItem]
    let errored: Bool
}

struct WidgetScheduleEntryView : View {
    @Environment(\.widgetFamily) var family: WidgetFamily
    var entry: ScheduleProvider.Entry
    
    func itemView (_ item: LMWidgetScheduleItem) -> some View {
        VStack(alignment: .leading) {
            Text(item.course).font(.title)
            Text(item.shortClassRoom).bold() + Text(" · " + item.teacher)
            Text("\(item.isTomorrow ? "明天" : "")\(item.startTime)-\(item.endTime)")
        }.frame(minWidth: 0, maxWidth: .infinity)
    }
    func emptyView () -> some View {
        HStack {
            Spacer()
            Text("今明两日无课").opacity(0.8)
            Spacer()
        }.frame(minHeight: 0, maxHeight: .infinity)
    }

    @ViewBuilder
    var body: some View {
        VStack {
            if entry.errored {
                Spacer()
                Text("发生错误").opacity(0.8)
                Spacer()
            } else {
                switch family {
                case .systemSmall:
                    VStack(alignment: .leading) {
                        Text("下节课").font(.footnote).bold().foregroundColor(.accentColor)
                        Spacer()
                        if entry.items.count > 0 {
                            itemView(entry.items[0])
                        } else {
                            emptyView()
                        }
                    }
                case .systemMedium:
                    VStack(alignment: .leading) {
                        Text("之后的课").font(.footnote).bold().foregroundColor(.accentColor)
                        Spacer()
                        if entry.items.count > 0 {
                            HStack(alignment: .bottom) {
                                ForEach(entry.items) { item in
                                    itemView(item)
                                }
                            }.frame(minWidth: 0, maxWidth: .infinity)
                        } else {
                            emptyView()
                        }
                    }
                default: Text("尚不支持此尺寸")
                }
            }
        }.padding()
    }
}

struct ScheduleWidget: Widget {
    private let kind: String = "help.hdu.lemonios.WidgetSchedule"

    public var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: ScheduleProvider()) { entry in
            WidgetScheduleEntryView(entry: entry)
        }
        .configurationDisplayName("下节课")
        .description("显示接下来的几节课。")
        .supportedFamilies([.systemSmall, .systemMedium])
    }
}

struct ScheduleWidget_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            WidgetScheduleEntryView(entry: ScheduleProvider.placeholderEntry)
                .previewContext(WidgetPreviewContext(family: .systemSmall))
            WidgetScheduleEntryView(entry: ScheduleProvider.placeholderEntry)
                .previewContext(WidgetPreviewContext(family: .systemMedium))
        }
    }
}
