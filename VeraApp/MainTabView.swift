import SwiftUI

struct MainTabView: View {
    @EnvironmentObject private var store: VeraStore
    @State private var tab = 0
    @State private var openedQuote: Quote?

    var body: some View {
        TabView(selection: $tab) {
            HomeView(openQuote: { openedQuote = $0 })
                .tabItem { Label("Сегодня", systemImage: "sun.max") }.tag(0)
            LibraryView(openQuote: { openedQuote = $0 })
                .tabItem { Label("Библиотека", systemImage: "books.vertical") }.tag(1)
            FavoritesView(openQuote: { openedQuote = $0 })
                .tabItem { Label("Избранное", systemImage: "bookmark") }.tag(2)
            SettingsView()
                .tabItem { Label("Настройки", systemImage: "slider.horizontal.3") }.tag(3)
        }
        .tint(VeraTheme.gold)
        .sheet(item: $openedQuote) { quote in QuoteDetailView(quote: quote) }
        .onReceive(NotificationCenter.default.publisher(for: .openVeraQuote)) { note in
            guard let id = note.object as? String, let quote = QuoteLibrary.find(id) else { return }
            openedQuote = quote
        }
    }
}

struct HomeView: View {
    @EnvironmentObject private var store: VeraStore
    let openQuote: (Quote) -> Void
    private var daily: Quote {
        let day = Calendar.current.ordinality(of: .day, in: .era, for: .now) ?? 1
        return QuoteLibrary.all[day % QuoteLibrary.all.count]
    }
    private var picks: [Quote] { QuoteLibrary.all.filter { store.categories.contains($0.category) }.prefix(5).map { $0 } }

    var body: some View {
        NavigationStack {
            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 26) {
                    HStack {
                        VStack(alignment: .leading, spacing: 5) {
                            Text(Date.now.formatted(.dateTime.weekday(.wide).day().month(.wide)).uppercased())
                                .font(.system(size: 10, weight: .semibold, design: .rounded)).tracking(2.2).foregroundStyle(VeraTheme.muted)
                            Text("Тихий свет")
                                .font(.system(size: 34, weight: .regular, design: .serif)).foregroundStyle(.white)
                        }
                        Spacer()
                        Image(systemName: "sparkle")
                            .font(.system(size: 19, weight: .light)).foregroundStyle(VeraTheme.gold)
                            .frame(width: 46, height: 46).background(VeraTheme.panel, in: Circle())
                    }
                    VStack(alignment: .leading, spacing: 18) {
                        HStack {
                            Text("СЛОВО ДНЯ").font(.system(size: 10, weight: .bold)).tracking(2.3)
                            Spacer()
                            Image(systemName: "sun.max.fill").foregroundStyle(VeraTheme.gold)
                        }.foregroundStyle(VeraTheme.gold)
                        Text(daily.text)
                            .font(.system(size: 26, weight: .regular, design: .serif))
                            .lineSpacing(5).foregroundStyle(.white)
                        HStack {
                            Text(daily.source).font(.system(size: 12, weight: .medium)).foregroundStyle(VeraTheme.gold)
                            Spacer()
                            Button { openQuote(daily) } label: {
                                Image(systemName: "arrow.up.right").font(.system(size: 13, weight: .semibold))
                                    .foregroundStyle(.black).frame(width: 34, height: 34).background(VeraTheme.gold, in: Circle())
                            }
                        }
                    }
                    .padding(22)
                    .background(LinearGradient(colors: VeraTheme.gradient(store.theme), startPoint: .topLeading, endPoint: .bottomTrailing), in: RoundedRectangle(cornerRadius: 26))
                    .overlay(RoundedRectangle(cornerRadius: 26).stroke(.white.opacity(0.08), lineWidth: 1))
                    HStack {
                        Text("Для твоего дня").font(.system(size: 22, weight: .regular, design: .serif)).foregroundStyle(.white)
                        Spacer()
                        Text("\(picks.count) мыслей").font(.system(size: 11)).foregroundStyle(VeraTheme.muted)
                    }
                    ForEach(picks) { quote in QuoteRow(quote: quote, open: { openQuote(quote) }) }
                }
                .padding(.horizontal, 20).padding(.top, 18).padding(.bottom, 28)
            }
            .background(VeraTheme.background.ignoresSafeArea())
            .toolbar(.hidden, for: .navigationBar)
        }
    }
}

struct QuoteRow: View {
    @EnvironmentObject private var store: VeraStore
    let quote: Quote
    let open: () -> Void
    var body: some View {
        Button(action: open) {
            HStack(alignment: .top, spacing: 14) {
                RoundedRectangle(cornerRadius: 2).fill(VeraTheme.gold.opacity(0.8)).frame(width: 2, height: 48)
                VStack(alignment: .leading, spacing: 8) {
                    Text(quote.text).font(.system(size: 16, weight: .regular, design: .serif)).lineSpacing(3).foregroundStyle(.white).multilineTextAlignment(.leading).lineLimit(3)
                    Text("\(quote.source)  ·  \(quote.category)").font(.system(size: 10, weight: .medium)).foregroundStyle(VeraTheme.muted)
                }
                Spacer(minLength: 0)
                Image(systemName: store.isFavorite(quote.id) ? "bookmark.fill" : "bookmark")
                    .font(.system(size: 13)).foregroundStyle(store.isFavorite(quote.id) ? VeraTheme.gold : VeraTheme.muted)
                    .onTapGesture { store.toggleFavorite(quote.id) }
            }
            .padding(16).background(VeraTheme.panel, in: RoundedRectangle(cornerRadius: 18))
        }.buttonStyle(.plain)
    }
}
