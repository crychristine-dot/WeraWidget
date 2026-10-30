import WidgetKit
import SwiftUI

struct VeraEntry: TimelineEntry {
    let date: Date
    let quote: Quote
    let theme: String
}

struct VeraProvider: TimelineProvider {
    func placeholder(in context: Context) -> VeraEntry {
        VeraEntry(date: .now, quote: QuoteLibrary.all[0], theme: "Обсидиан")
    }
    func getSnapshot(in context: Context, completion: @escaping (VeraEntry) -> Void) {
        completion(makeEntry(offset: 0))
    }
    func getTimeline(in context: Context, completion: @escaping (Timeline<VeraEntry>) -> Void) {
        let entries = (0..<8).compactMap { offset -> VeraEntry? in
            let date = Calendar.current.date(byAdding: .hour, value: offset * 3, to: .now) ?? .now
            return makeEntry(offset: offset, date: date)
        }
        completion(Timeline(entries: entries, policy: .atEnd))
    }
    private func makeEntry(offset: Int, date: Date = .now) -> VeraEntry {
        let defaults = UserDefaults(suiteName: "group.com.kriscarter.vera")
        let categories = Set(defaults?.stringArray(forKey: "categories") ?? ["Вера", "Надежда", "Поддержка", "Спокойствие"])
        let filtered = QuoteLibrary.all.filter { categories.contains($0.category) }
        let pool = filtered.isEmpty ? QuoteLibrary.all : filtered
        let day = Calendar.current.ordinality(of: .day, in: .era, for: date) ?? 1
        let quote = pool[(day + offset) % pool.count]
        return VeraEntry(date: date, quote: quote, theme: defaults?.string(forKey: "theme") ?? "Обсидиан")
    }
}

struct VeraWidgetView: View {
    @Environment(\.widgetFamily) private var family
    let entry: VeraEntry
    var body: some View {
        ZStack {
            LinearGradient(colors: VeraTheme.gradient(entry.theme), startPoint: .topLeading, endPoint: .bottomTrailing)
            VStack(alignment: .leading, spacing: family == .systemSmall ? 8 : 12) {
                HStack(spacing: 5) {
                    Image(systemName: "sparkle")
                    Text("ТИХИЙ СВЕТ").tracking(1.7)
                    Spacer(minLength: 0)
                    Image(systemName: "sun.max")
                }.font(.system(size: family == .systemSmall ? 8 : 9, weight: .bold)).foregroundStyle(VeraTheme.gold)
                Spacer(minLength: 2)
                Text(entry.quote.text)
                    .font(.system(size: family == .systemSmall ? 13 : family == .systemMedium ? 16 : 20, weight: .regular, design: .serif))
                    .lineSpacing(3).lineLimit(family == .systemSmall ? 5 : family == .systemMedium ? 4 : 7)
                    .minimumScaleFactor(0.75).foregroundStyle(.white)
                Spacer(minLength: 2)
                HStack {
                    Text(entry.quote.source).font(.system(size: family == .systemSmall ? 9 : 10, weight: .semibold)).foregroundStyle(VeraTheme.gold).lineLimit(1)
                    Spacer(minLength: 0)
                    Image(systemName: "arrow.up.right").font(.system(size: 9, weight: .bold)).foregroundStyle(.white.opacity(0.65))
                }
            }.padding(family == .systemSmall ? 13 : 16)
        }
        .containerBackground(.clear, for: .widget)
        .widgetURL(URL(string: "vera://quote/\(entry.quote.id)"))
    }
}

@main
struct VeraWidget: Widget {
    let kind = "VeraWidget"
    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: VeraProvider()) { entry in
            VeraWidgetView(entry: entry)
        }
        .configurationDisplayName("Тихий свет")
        .description("Слова веры и поддержки на главном экране.")
        .supportedFamilies([.systemSmall, .systemMedium, .systemLarge])
    }
}
