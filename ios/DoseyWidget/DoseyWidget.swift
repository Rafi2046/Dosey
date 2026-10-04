import SwiftUI
import WidgetKit

// "Next medicine" home screen widget. The app writes the upcoming doses
// (already worded, in the app language) as JSON into the shared App Group —
// see lib/core/home_widget/home_widget_sync.dart — and reloads this widget
// whenever the schedule or a dose changes. The timeline below also moves on
// by itself as each dose becomes due and then passes.

private let appGroup = "group.com.example.dosey"  // AppConstants.appGroupId
private let dataKey = "dosey_next_dose"  // AppConstants.widgetDataKey
private let dueWindow: TimeInterval = 2 * 60 * 60  // HomeWidgetSync.dueWindow

struct WidgetData: Decodable {
  struct Labels: Decodable {
    let next, due, empty, today, tomorrow: String
  }
  struct Slot: Decodable {
    let at: Double  // ms since epoch
    let time, date, title: String
    let lines: [String]
    var date_: Date { Date(timeIntervalSince1970: at / 1000) }
  }
  let labels: Labels
  let slots: [Slot]

  static func load() -> WidgetData? {
    guard let json = UserDefaults(suiteName: appGroup)?.string(forKey: dataKey),
      let bytes = json.data(using: .utf8)
    else { return nil }
    return try? JSONDecoder().decode(WidgetData.self, from: bytes)
  }

  /// The first dose still due at [now].
  func current(at now: Date) -> Slot? {
    slots.first { $0.date_.addingTimeInterval(dueWindow) > now }
  }
}

struct DoseEntry: TimelineEntry {
  let date: Date
  let data: WidgetData?
}

struct DoseProvider: TimelineProvider {
  func placeholder(in context: Context) -> DoseEntry {
    DoseEntry(date: Date(), data: nil)
  }

  func getSnapshot(in context: Context, completion: @escaping (DoseEntry) -> Void) {
    completion(DoseEntry(date: Date(), data: WidgetData.load()))
  }

  /// One entry now, then one at every moment the shown dose changes: when
  /// a dose becomes due, and when it stops being due.
  func getTimeline(in context: Context, completion: @escaping (Timeline<DoseEntry>) -> Void) {
    let now = Date()
    let data = WidgetData.load()
    var moments = [now]
    for slot in data?.slots ?? [] {
      for moment in [slot.date_, slot.date_.addingTimeInterval(dueWindow)] where moment > now {
        moments.append(moment)
      }
    }
    let entries = Set(moments).sorted().prefix(40).map { DoseEntry(date: $0, data: data) }
    completion(Timeline(entries: Array(entries), policy: .atEnd))
  }
}

private extension Color {
  static let sageLight = Color(red: 0x73 / 255, green: 0x7D / 255, blue: 0x6D / 255)
  static let sageDark = Color(red: 0x4B / 255, green: 0x54 / 255, blue: 0x49 / 255)
  static let accent = Color(red: 0xFD / 255, green: 0x57 / 255, blue: 0x2F / 255)
  static let cream = Color(red: 0xE6 / 255, green: 0xE3 / 255, blue: 0xD3 / 255)
  static let textOnDark = Color(red: 0xEE / 255, green: 0xEB / 255, blue: 0xDD / 255)
  static let textMuted = Color(red: 0xC6 / 255, green: 0xC9 / 255, blue: 0xBC / 255)
}

private let cardGradient = LinearGradient(
  colors: [.sageLight, .sageDark], startPoint: .topLeading, endPoint: .bottomTrailing)

/// Cream circle with the orange medicine icon (as on Android).
private struct PillBadge: View {
  let size: CGFloat
  var body: some View {
    Image(systemName: "cross.case.fill")
      .font(.system(size: size * 0.46, weight: .semibold))
      .foregroundColor(.accent)
      .frame(width: size, height: size)
      .background(Circle().fill(Color.cream))
  }
}

struct DoseyWidgetView: View {
  let entry: DoseEntry
  @Environment(\.widgetFamily) private var family

  private func dayLabel(_ slot: WidgetData.Slot, _ labels: WidgetData.Labels) -> String {
    let calendar = Calendar.current
    if calendar.isDate(slot.date_, inSameDayAs: entry.date) { return labels.today }
    if let tomorrow = calendar.date(byAdding: .day, value: 1, to: entry.date),
      calendar.isDate(slot.date_, inSameDayAs: tomorrow)
    {
      return labels.tomorrow
    }
    return slot.date
  }

  private func header(_ slot: WidgetData.Slot, _ data: WidgetData) -> String {
    slot.date_ <= entry.date ? data.labels.due : data.labels.next
  }

  var body: some View {
    Group {
      if let data = entry.data, let slot = data.current(at: entry.date) {
        if family == .systemSmall { small(slot, data) } else { medium(slot, data) }
      } else {
        empty
      }
    }
    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
    .widgetBackground(cardGradient)
  }

  /// 2×2: icon + day, then the time big, then what to take.
  private func small(_ slot: WidgetData.Slot, _ data: WidgetData) -> some View {
    VStack(alignment: .leading, spacing: 2) {
      HStack {
        PillBadge(size: 28)
        Spacer(minLength: 4)
        Text(dayLabel(slot, data.labels))
          .font(.caption2).foregroundColor(.textMuted).lineLimit(1)
      }
      Spacer(minLength: 0)
      Text(header(slot, data))
        .font(.caption2).foregroundColor(.textMuted).lineLimit(1)
      Text(slot.time)
        .font(.system(size: 24, weight: .semibold, design: .rounded))
        .foregroundColor(.white).lineLimit(1).minimumScaleFactor(0.7)
      Text(slot.title)
        .font(.system(.subheadline, design: .serif).weight(.bold))
        .foregroundColor(.textOnDark).lineLimit(1)
      Text(slot.lines.first ?? "")
        .font(.caption).foregroundColor(.textMuted).lineLimit(1)
    }
  }

  /// Wide: icon | what to take | time chip + day.
  private func medium(_ slot: WidgetData.Slot, _ data: WidgetData) -> some View {
    HStack(alignment: .center, spacing: 12) {
      PillBadge(size: 44)
      VStack(alignment: .leading, spacing: 2) {
        Text(header(slot, data))
          .font(.caption2).foregroundColor(.textMuted).lineLimit(1)
        Text(slot.title)
          .font(.system(.headline, design: .serif).weight(.bold))
          .foregroundColor(.textOnDark).lineLimit(1)
        Text(slot.lines.joined(separator: "\n"))
          .font(.caption).foregroundColor(.textMuted).lineLimit(3)
      }
      Spacer(minLength: 4)
      VStack(alignment: .trailing, spacing: 4) {
        Text(slot.time)
          .font(.system(.subheadline, design: .rounded).weight(.semibold))
          .foregroundColor(.white)
          .padding(.horizontal, 10).padding(.vertical, 4)
          .background(Capsule().fill(Color.accent))
          .lineLimit(1)
        Text(dayLabel(slot, data.labels))
          .font(.caption2).foregroundColor(.textMuted).lineLimit(1)
      }
    }
    .frame(maxHeight: .infinity)
  }

  private var empty: some View {
    VStack(alignment: .leading, spacing: 6) {
      PillBadge(size: 28)
      Spacer(minLength: 0)
      Text(entry.data?.labels.next ?? "Next medicine")
        .font(.caption2).foregroundColor(.textMuted)
      Text(entry.data?.labels.empty ?? "Open Dosey to load your medicines")
        .font(.subheadline.weight(.semibold)).foregroundColor(.textOnDark)
    }
  }
}

private extension View {
  /// iOS 17 wants the background declared for StandBy / tinted modes.
  @ViewBuilder func widgetBackground<S: ShapeStyle>(_ style: S) -> some View {
    if #available(iOS 17.0, *) {
      containerBackground(style, for: .widget)
    } else {
      padding().background(Rectangle().fill(style))
    }
  }
}

@main
struct DoseyWidget: Widget {
  let kind = "DoseyWidget"  // AppConstants.widgetIosKind

  var body: some WidgetConfiguration {
    StaticConfiguration(kind: kind, provider: DoseProvider()) { entry in
      DoseyWidgetView(entry: entry)
    }
    .configurationDisplayName("Dosey")
    .description(NSLocalizedString("widget_description", value: "Your next dose: medicine, time and amount.", comment: ""))
    .supportedFamilies([.systemSmall, .systemMedium])
  }
}
