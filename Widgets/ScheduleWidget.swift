//
//  WidgetSchedule.swift
//  WidgetSchedule
//
//  Created by Shibo Lyu on 2020/6/23.
//  Copyright © 2020 Inkwire Tech (Hangzhou) Co., Ltd. All rights reserved.
//

import WidgetKit
import SwiftUI

struct CapsuleLinkModifier: ViewModifier {
  var color: Color
  var bg: Color

  func body(content: Content) -> some View {
    content
      .padding(.horizontal, 10)
      .padding(.vertical, 5)
      .foregroundColor(color)
      .background(bg)
      .clipShape(Capsule())
  }
}
extension View {
  func capsuleLink(color: Color = .white, bg: Color = .blue) -> some View {
    self.modifier(CapsuleLinkModifier(color: color, bg: bg))
  }
}

struct ScheduleProvider: TimelineProvider {
  public typealias Entry = ScheduleEntry

  private static let placeholderItem = LMWidgetScheduleItem(
    course: "----",
    classroom: "-教---",
    startTime: Date(),
    endTime: Date(),
    startTimeStr: "--:--",
    endTimeStr: "--:--",
    teacher: "--",
    isTomorrow: false
  )

  public static let placeholderEntry = ScheduleEntry(
    date: Date(),
    items: Array(repeating: placeholderItem, count: 2),
    errored: false
  )

  func placeholder(in context: Context) -> ScheduleEntry { Self.placeholderEntry }

  public func getSnapshot(in context: Context, completion: @escaping (ScheduleEntry) -> ()) {
    completion(ScheduleProvider.placeholderEntry)
  }

  public func getPlaceholder(in context: Context) -> ScheduleEntry { Self.placeholderEntry }

  public func getTimeline(in context: Context, completion: @escaping (Timeline<Entry>) -> ()) {
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
          // Sometimes there could be a schedule change. So refetch after 30 min.
          Calendar.current.date(byAdding: .minute, value: 30, to: Date())!
        ))
        completion(timeline)
        return
      }
      while !remainingItems.isEmpty {
        let firstItem = remainingItems.first!
        entries.append(
          ScheduleEntry(date: startingDate, items: remainingItems, errored: false)
        )
        startingDate = firstItem.endTime
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

  var checkInUrlString: String? {
    let sharedUd = UserDefaults.init(suiteName: "group.help.hdu.lemon.ios")
    return sharedUd!.string(forKey: "sklUrl")
  }
  let scheduleAppUrl = URL(string: "hduhelplemon://#/app/schedule")!
  let sklSetupUrl = URL(string: "hduhelplemon:///_skl_setup")!

  func itemView (_ item: LMWidgetScheduleItem) -> some View {
    VStack(alignment: .leading) {
      Text(item.course).font(.title2)
      Text(item.shortClassRoom).bold() + Text(item.teacher).font(.footnote)

      Text(item.isTomorrow ?? false ? "明日" : "").font(.footnote) + Text("\(item.startTimeStr)-\(item.endTimeStr)")
    }.frame(minWidth: 0, maxWidth: .infinity)
  }
  func emptyView () -> some View {
    HStack {
      Spacer()
      Text("今明两日无课").opacity(0.8)
      Spacer()
    }.frame(minHeight: 0, maxHeight: .infinity)
  }
  func titleView () -> some View {
    HStack(alignment: .center) {
      Text(family == .systemSmall ? "下节课" : "之后的课").bold().foregroundColor(.accentColor)
      Spacer()
      switch family {
      case .systemSmall:
        Text(
          checkInUrlString != nil ? "点击签到" : "设置签到"
        ).font(.footnote).foregroundColor(.gray)
      default:
        HStack(spacing: 5) {
          if checkInUrlString != nil {
            Link(destination: sklSetupUrl) {
              Image(systemName: "gear")
                .imageScale(.medium)
                .font(.body)
            }
              .capsuleLink(color: .white, bg: .gray)
            Link("签到", destination: URL(string: checkInUrlString!)!).capsuleLink()
          } else {
            Link("设置签到", destination: sklSetupUrl).capsuleLink()
          }
        }
      }
    }
  }

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
            titleView()
            Spacer()
            if entry.items.count > 0 {
              itemView(entry.items[0]).frame(minWidth: 0, maxWidth: .infinity)
            } else {
              emptyView()
            }
          }.widgetURL(
            checkInUrlString != nil
            ? URL(string: checkInUrlString!)!
            : sklSetupUrl
          )
        case .systemMedium:
          VStack(alignment: .leading) {
            titleView()
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
          }.widgetURL(scheduleAppUrl)
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
