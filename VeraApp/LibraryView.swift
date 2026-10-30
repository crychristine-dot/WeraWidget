import SwiftUI

struct LibraryView: View {
    let openQuote: (Quote) -> Void
    @State private var search = ""
    @State private var category = "Все"
    private let categories = ["Все", "Вера", "Надежда", "Поддержка", "Спокойствие", "Любовь", "Мудрость", "Благодарность"]
    private var filtered: [Quote] {
        QuoteLibrary.all.filter { quote in
            (category == "Все" || quote.category == category) &&
            (search.isEmpty || quote.text.localizedCaseInsensitiveContains(search) || quote.source.localizedCaseInsensitiveContains(search))
        }
    }
    var body: some View {
        NavigationStack {
            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 18) {
                    Text("Библиотека").font(.system(size: 34, weight: .regular, design: .serif)).foregroundStyle(.white)
                    HStack(spacing: 10) {
                        Image(systemName: "magnifyingglass").foregroundStyle(VeraTheme.muted)
                        TextField("Найти стих или источник", text: $search).foregroundStyle(.white).tint(VeraTheme.gold)
                    }.padding(14).background(VeraTheme.panel, in: RoundedRectangle(cornerRadius: 14))
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 8) {
                            ForEach(categories, id: \.self) { item in
                                Button { category = item } label: {
                                    Text(item).font(.system(size: 12, weight: .medium)).padding(.horizontal, 14).padding(.vertical, 9)
                                        .background(category == item ? VeraTheme.gold : VeraTheme.panel, in: Capsule())
                                        .foregroundStyle(category == item ? .black : .white.opacity(0.75))
                                }
                            }
                        }
                    }
                    Text("\(filtered.count) ЦИТАТ").font(.system(size: 10, weight: .bold)).tracking(2).foregroundStyle(VeraTheme.muted)
                    ForEach(filtered) { quote in QuoteRow(quote: quote, open: { openQuote(quote) }) }
                }.padding(.horizontal, 20).padding(.top, 18).padding(.bottom, 24)
            }.background(VeraTheme.background.ignoresSafeArea()).toolbar(.hidden, for: .navigationBar)
        }
    }
}

struct FavoritesView: View {
    @EnvironmentObject private var store: VeraStore
    let openQuote: (Quote) -> Void
    private var quotes: [Quote] { QuoteLibrary.all.filter { store.favorites.contains($0.id) } }
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 18) {
                    Text("Избранное").font(.system(size: 34, weight: .regular, design: .serif)).foregroundStyle(.white)
                    if quotes.isEmpty {
                        VStack(spacing: 12) {
                            Image(systemName: "bookmark").font(.system(size: 30, weight: .ultraLight)).foregroundStyle(VeraTheme.gold)
                            Text("Сохраняй важное").font(.system(size: 21, design: .serif)).foregroundStyle(.white)
                            Text("Понравившиеся строки появятся здесь.").font(.system(size: 13)).foregroundStyle(VeraTheme.muted)
                        }.frame(maxWidth: .infinity).padding(.vertical, 70)
                    } else {
                        ForEach(quotes) { quote in QuoteRow(quote: quote, open: { openQuote(quote) }) }
                    }
                }.padding(.horizontal, 20).padding(.top, 18)
            }.background(VeraTheme.background.ignoresSafeArea()).toolbar(.hidden, for: .navigationBar)
        }
    }
}

struct QuoteDetailView: View {
    @EnvironmentObject private var store: VeraStore
    @Environment(\.dismiss) private var dismiss
    let quote: Quote
    var body: some View {
        ZStack {
            LinearGradient(colors: VeraTheme.gradient(store.theme), startPoint: .topLeading, endPoint: .bottomTrailing).ignoresSafeArea()
            VStack(spacing: 24) {
                HStack {
                    Button { dismiss() } label: { Image(systemName: "xmark").font(.system(size: 14, weight: .semibold)).foregroundStyle(.white.opacity(0.8)).frame(width: 42, height: 42).background(.white.opacity(0.08), in: Circle()) }
                    Spacer()
                    Text(quote.category.uppercased()).font(.system(size: 10, weight: .bold)).tracking(2).foregroundStyle(VeraTheme.gold)
                    Spacer()
                    ShareLink(item: "\(quote.text)\n\n\(quote.source)") { Image(systemName: "square.and.arrow.up").foregroundStyle(.white.opacity(0.8)).frame(width: 42, height: 42).background(.white.opacity(0.08), in: Circle()) }
                }
                Spacer()
                Image(systemName: "quote.opening").font(.system(size: 28, weight: .light)).foregroundStyle(VeraTheme.gold)
                Text(quote.text).font(.system(size: 30, weight: .regular, design: .serif)).lineSpacing(7).multilineTextAlignment(.center).foregroundStyle(.white).padding(.horizontal, 8)
                Text(quote.source).font(.system(size: 13, weight: .semibold)).foregroundStyle(VeraTheme.gold)
                Spacer()
                Button { store.toggleFavorite(quote.id) } label: {
                    Label(store.isFavorite(quote.id) ? "Убрать из избранного" : "Сохранить", systemImage: store.isFavorite(quote.id) ? "bookmark.fill" : "bookmark")
                        .font(.system(size: 14, weight: .semibold)).foregroundStyle(.black).frame(maxWidth: .infinity).padding(17).background(VeraTheme.gold, in: Capsule())
                }
            }.padding(24)
        }.presentationDetents([.large])
    }
}
