import WidgetKit
import SwiftUI

struct VeraEntry: TimelineEntry {
    let date: Date
    let quote: Quote
}

struct VeraProvider: TimelineProvider {
    func placeholder(in context: Context) -> VeraEntry {
        VeraEntry(date: .now, quote: QuoteLibrary.all[0])
    }

    func getSnapshot(in context: Context, completion: @escaping (VeraEntry) -> Void) {
        completion(VeraEntry(date: .now, quote: pickQuote()))
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<VeraEntry>) -> Void) {
        let now = Date()
        let entries = (0..<8).map { offset in
            VeraEntry(date: Calendar.current.date(byAdding: .hour, value: offset * 3, to: now) ?? now,
                      quote: pickQuote(seed: offset))
        }
        completion(Timeline(entries: entries, policy: .atEnd))
    }

    private func pickQuote(seed: Int = 0) -> Quote {
        let defaults = UserDefaults(suiteName: "group.com.kriscarter.vera")
        let categories = Set(defaults?.stringArray(forKey: "selectedCategories") ?? ["Библия", "Любовь", "Вера", "Надежда", "Поддержка"])
        let pool = QuoteLibrary.all.filter { categories.contains($0.category) || categories.contains($0.kind) }
        let source = pool.isEmpty ? QuoteLibrary.all : pool
        let day = Calendar.current.ordinality(of: .day, in: .era, for: .now) ?? 1
        return source[(day + seed) % source.count]
    }
}

struct VeraWidgetView: View {
    @Environment(\.widgetFamily) private var family
    let entry: VeraEntry

    private var palette: [Color] {
        let theme = UserDefaults(suiteName: "group.com.kriscarter.vera")?.string(forKey: "widgetTheme") ?? "Графит"
        switch theme {
        case "Полночь": return [Color(red: 0.10, green: 0.13, blue: 0.24), .black]
        case "Бордо": return [Color(red: 0.29, green: 0.08, blue: 0.17), .black]
        case "Лес": return [Color(red: 0.06, green: 0.20, blue: 0.17), .black]
        default: return [Color(red: 0.20, green: 0.18, blue: 0.23), .black]
        }
    }

    var body: some View {
        ZStack {
            LinearGradient(colors: palette, startPoint: .topLeading, endPoint: .bottomTrailing)
            VStack(alignment: .leading, spacing: family == .systemSmall ? 7 : 11) {
                HStack(spacing: 5) {
                    Image(systemName: "quote.opening")
                    Text(entry.quote.category.uppercased()).tracking(1.4)
                    Spacer(minLength: 0)
                    Image(systemName: "sparkle").foregroundStyle(Color(red: 0.84, green: 0.63, blue: 0.40))
                }
                .font(.system(size: family == .systemSmall ? 8 : 10, weight: .bold))
                .foregroundStyle(.white.opacity(0.55))

                Text(entry.quote.text)
                    .font(.system(size: family == .systemSmall ? 12 : family == .systemMedium ? 15 : 20, weight: .semibold, design: .serif))
                    .lineLimit(family == .systemSmall ? 5 : family == .systemMedium ? 4 : 7)
                    .minimumScaleFactor(0.72)
                    .foregroundStyle(.white)
                    .frame(maxHeight: .infinity, alignment: .center)

                Text(entry.quote.source)
                    .font(.system(size: family == .systemSmall ? 9 : 11, weight: .semibold))
                    .foregroundStyle(Color(red: 0.84, green: 0.63, blue: 0.40))
                    .lineLimit(1)
            }
            .padding(family == .systemSmall ? 12 : 16)
        }
        .containerBackground(.clear, for: .widget)
        .widgetURL(URL(string: "veratikhiy://quote/\(entry.quote.id)"))
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
        .description("Библейские стихи и слова поддержки на главном экране.")
        .supportedFamilies([.systemSmall, .systemMedium, .systemLarge])
    }
}
