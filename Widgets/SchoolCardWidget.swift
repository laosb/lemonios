//
//  SchoolCardWidget.swift
//  杭电助手
//
//  Created by Shibo Lyu on 2020/12/7.
//  Copyright © 2020 Inkwire Tech (Hangzhou) Co., Ltd. All rights reserved.
//

import SwiftUI
import WidgetKit

struct SchoolCardProvider: TimelineProvider {
  let placeholderEntry = Entry(
    date: Date(),
    data: .init(
      remaining: nil,
      flow: Array(
        repeating: SMWidgetSchoolCardData.Record(
          createTime: nil,
          deviceName: "----",
          deviceNum: "-",
          feeName: "--",
          remaining: nil,
          totalFee: nil
        ),
        count: 10
      )
    ),
    errored: false
  )
  
  func placeholder(in context: Context) -> SchoolCardEntry { placeholderEntry }
  
  func getSnapshot(in context: Context, completion: @escaping (SchoolCardEntry) -> Void) {
    completion(placeholderEntry)
  }
  
  func getTimeline(in context: Context, completion: @escaping (Timeline<SchoolCardEntry>) -> Void) {
    SMWidgetSchoolCardData.fetchData { data in
      guard data != nil else {
        completion(
          Timeline(
            entries: [Entry(date: Date(), data: nil, errored: true)],
            policy: .atEnd
          )
        )
        return
      }
      completion(Timeline(entries: [Entry(date: Date(), data: data, errored: false)], policy: .atEnd))
    }
  }
  
  typealias Entry = SchoolCardEntry
}

struct SchoolCardEntry: TimelineEntry {
  let date: Date
  let data: SMWidgetSchoolCardData?
  let errored: Bool
}

struct WidgetSchoolCardEntryView: View {
  @Environment(\.widgetFamily) var family: WidgetFamily

  var entry: SchoolCardEntry

  let common = SMWidgetCommon()

  func currencyFormat (_ f: Float?, transaction: Bool = false) -> String {
    let value = f != nil
      ? String(format: "%.2f", f!)
      : "-.--"
    return transaction && (f ?? 0 >= 0) ? "+\(value)" : value
  }
  
  func title () -> some View {
    HStack {
      Text("一卡通").bold().foregroundColor(.accentColor)
      Spacer()
    }
  }

  func balance () -> some View {
    let balanceStr = currencyFormat(entry.data?.remaining)

    return VStack {
      Group {
        Text("CN¥ ").bold().font(.system(.body, design: .rounded))
          + Text("\(balanceStr)").bold().font(.system(.largeTitle, design: .rounded))
      }
        .foregroundColor(.accentColor)
      Text("余额").font(.caption)
    }
  }

  func transactionList (max: Int, font: Font = .body) -> some View {
    let items = entry.data!.flow.prefix(max)

    return VStack {
      ForEach(0..<items.count) { idx in
        let rec = items[idx]

        if idx > 0 { Divider() }
        HStack {
          Text("\(rec.deviceName) \(rec.feeName)".trimmingCharacters(in: [" "]))
            .lineLimit(1)
            .font(font)
          Spacer()
          Text("\(currencyFormat(rec.totalFee, transaction: true))")
            .bold()
            .font(.system(.body, design: .rounded))
        }
      }
    }
  }
  
  var body: some View {
    VStack {
      title()
      Spacer()
      if entry.errored {
        common.errorView()
      } else {
        if family == .systemMedium {
          HStack {
            balance()
            Divider()
            transactionList(max: 3, font: .caption)
          }
        } else {
          balance()
          Divider()
          transactionList(
            max: family == .systemLarge ? 6 : 1,
            font: family == .systemLarge ? .body : .caption
          )
        }
      }
    }.padding()
  }
}

struct SchoolCardWidget: Widget {
  private let kind: String = "help.hdu.lemonios.WidgetSchoolCard"

  public var body: some WidgetConfiguration {
    StaticConfiguration(kind: kind, provider: SchoolCardProvider()) { entry in
      WidgetSchoolCardEntryView(entry: entry)
    }
    .configurationDisplayName("一卡通")
    .description("查看一卡通余额及最近消费。")
    .supportedFamilies([.systemSmall, .systemMedium, .systemLarge])
  }
}

struct SchoolCardWidget_Previews: PreviewProvider {
  static let provider = SchoolCardProvider()

  static var previews: some View {
    Group {
      WidgetSchoolCardEntryView(entry: provider.placeholderEntry)
        .previewContext(WidgetPreviewContext(family: .systemSmall))
      WidgetSchoolCardEntryView(entry: provider.placeholderEntry)
        .previewContext(WidgetPreviewContext(family: .systemMedium))
      WidgetSchoolCardEntryView(entry: provider.placeholderEntry)
        .previewContext(WidgetPreviewContext(family: .systemLarge))
    }
  }
}
