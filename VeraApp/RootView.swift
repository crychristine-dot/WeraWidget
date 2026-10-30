import SwiftUI

private enum VeraStyle {
    static let background = Color(red: 0.055, green: 0.050, blue: 0.065)
    static let gold = Color(red: 0.84, green: 0.66, blue: 0.43)
    static let muted = Color.white.opacity(0.58)
}

struct RootView: View {
    @State private var tab = 0
    @State private var openedQuote: Quote?

    var body: some View {
        ZStack {
            VeraStyle.background.ignoresSafeArea()
            Group {
                switch tab {
                case 0: HomeView(openedQuote: $openedQuote)
                case 1: LibraryView(openedQuote: $openedQuote)
                case 2: FavoritesView(openedQuote: $openedQuote)
                default: SettingsView()
                }
            }
        }
        .safeAreaInset(edge: .bottom, spacing: 0) {
            HStack(spacing: 0) {
                tabButton("sparkles", "Сегодня", 0)
                tabButton("books.vertical", "Библиотека", 1)
                tabButton("heart", "Избранное", 2)
                tabButton("slider.horizontal.3", "Настройки", 3)
            }
            .padding(.top, 12)
            .padding(.bottom, 8)
            .background(.ultraThinMaterial)
            .overlay(alignment: .top) { Rectangle().fill(.white.opacity(0.08)).frame(height: 1) }
        }
        .tint(VeraStyle.gold)
        .sheet(item: $openedQuote) { quote in QuoteDetailView(quote: quote) }
        .onOpenURL { url in
            guard url.scheme == "veratikhiy", let id = url.pathComponents.last,
                  let quote = QuoteLibrary.all.first(where: { $0.id == id }) else { return }
            openedQuote = quote
        }
    }

    private func tabButton(_ icon: String, _ title: String, _ index: Int) -> some View {
        Button { tab = index } label: {
            VStack(spacing: 5) {
                Image(systemName: icon).font(.system(size: 18, weight: .medium))
                Text(title).font(.system(size: 10, weight: .medium))
            }
            .foregroundStyle(tab == index ? VeraStyle.gold : VeraStyle.muted)
            .frame(maxWidth: .infinity)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }
}

struct QuoteCard: View {
    let quote: Quote
    var compact = false

    var body: some View {
        VStack(spacing: compact ? 12 : 20) {
            HStack {
                Text(quote.category.uppercased()).tracking(2)
                Spacer()
                Image(systemName: "sparkle").foregroundStyle(VeraStyle.gold)
            }
            .font(.system(size: 10, weight: .bold))
            .foregroundStyle(.white.opacity(0.48))
            Text("“\(quote.text)”")
                .font(.system(size: compact ? 18 : 27, weight: .medium, design: .serif))
                .multilineTextAlignment(.center)
                .lineSpacing(compact ? 4 : 7)
                .foregroundStyle(.white.opacity(0.96))
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            Text(quote.source.uppercased())
                .font(.system(size: 10, weight: .semibold))
                .tracking(1.2)
                .foregroundStyle(VeraStyle.gold)
        }
        .padding(compact ? 20 : 26)
        .frame(maxWidth: .infinity, minHeight: compact ? 150 : 300)
        .background {
            ZStack {
                LinearGradient(colors: [Color(red: 0.19, green: 0.16, blue: 0.20), Color(red: 0.075, green: 0.07, blue: 0.09)], startPoint: .topLeading, endPoint: .bottomTrailing)
                RadialGradient(colors: [VeraStyle.gold.opacity(0.13), .clear], center: .topTrailing, startRadius: 4, endRadius: 260)
            }
        }
        .clipShape(RoundedRectangle(cornerRadius: 26, style: .continuous))
        .overlay(RoundedRectangle(cornerRadius: 26, style: .continuous).stroke(.white.opacity(0.10), lineWidth: 1))
    }
}

struct HomeView: View {
    @Binding var openedQuote: Quote?
    @State private var current = QuoteLibrary.all[0]
    @State private var favorites = SharedStore.favorites()

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 22) {
                HStack(alignment: .center) {
                    VStack(alignment: .leading, spacing: 5) {
                        Text("ТИХИЙ СВЕТ").font(.system(size: 11, weight: .bold)).tracking(3).foregroundStyle(VeraStyle.gold)
                        Text("Место для тишины.").font(.system(size: 27, weight: .medium, design: .serif)).foregroundStyle(.white)
                    }
                    Spacer()
                    Image(systemName: "sun.max").font(.system(size: 22, weight: .light)).foregroundStyle(VeraStyle.gold)
                }
                HStack {
                    Text(Date.now.formatted(.dateTime.weekday(.wide).day().month(.wide)).uppercased())
                    Spacer()
                    Text("СЛОВО ДНЯ")
                }
                .font(.system(size: 9, weight: .bold)).tracking(1.5).foregroundStyle(VeraStyle.muted)
                Button { openedQuote = current } label: { QuoteCard(quote: current) }
                    .buttonStyle(.plain)
                HStack(spacing: 10) {
                    Button {
                        SharedStore.toggleFavorite(current.id)
                        favorites = SharedStore.favorites()
                    } label: {
                        Label(favorites.contains(current.id) ? "Сохранено" : "Сохранить", systemImage: favorites.contains(current.id) ? "heart.fill" : "heart")
                            .frame(maxWidth: .infinity).padding(.vertical, 15)
                            .background(.white.opacity(0.07), in: Capsule())
                    }
                    Button { current = nextQuote() } label: {
                        Label("Другая цитата", systemImage: "arrow.clockwise")
                            .frame(maxWidth: .infinity).padding(.vertical, 15)
                            .background(VeraStyle.gold.opacity(0.14), in: Capsule())
                    }
                }
                .font(.system(size: 13, weight: .semibold)).foregroundStyle(.white)
                .buttonStyle(.plain)
                Text("НЕБОЛЬШАЯ МЫСЛЬ НА СЕГОДНЯ")
                    .font(.system(size: 10, weight: .bold)).tracking(2).foregroundStyle(VeraStyle.muted)
                Text("Не обязательно найти все ответы сегодня. Иногда достаточно остановиться, выдохнуть и сделать следующий маленький шаг.")
                    .font(.system(size: 17, weight: .regular, design: .serif)).lineSpacing(5).foregroundStyle(.white.opacity(0.82))
            }
            .padding(.horizontal, 20).padding(.top, 24).padding(.bottom, 28)
        }
    }

    private func nextQuote() -> Quote {
        let categories = SharedStore.selectedCategories()
        let pool = QuoteLibrary.all.filter { categories.contains($0.category) || categories.contains($0.kind) }
        let choices = (pool.isEmpty ? QuoteLibrary.all : pool).filter { $0.id != current.id }
        return choices.randomElement() ?? QuoteLibrary.all[0]
    }
}

struct LibraryView: View {
    @Binding var openedQuote: Quote?
    @State private var search = ""
    @State private var category = "Все"
    private var categories: [String] { ["Все"] + Array(Set(QuoteLibrary.all.map(\.category))).sorted() }
    private var filtered: [Quote] {
        QuoteLibrary.all.filter { quote in
            (category == "Все" || quote.category == category) &&
            (search.isEmpty || quote.text.localizedCaseInsensitiveContains(search) || quote.source.localizedCaseInsensitiveContains(search))
        }
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 18) {
                Text("Библиотека").font(.system(size: 30, weight: .medium, design: .serif)).foregroundStyle(.white)
                Text("Слова, к которым можно возвращаться.").font(.system(size: 14)).foregroundStyle(VeraStyle.muted)
                HStack(spacing: 10) {
                    Image(systemName: "magnifyingglass").foregroundStyle(VeraStyle.muted)
                    TextField("Найти стих или источник", text: $search).foregroundStyle(.white).autocorrectionDisabled()
                }
                .padding(14).background(.white.opacity(0.07), in: RoundedRectangle(cornerRadius: 14))
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 8) {
                        ForEach(categories, id: \.self) { item in
                            Button { category = item } label: {
                                Text(item).font(.system(size: 12, weight: .semibold)).padding(.horizontal, 14).padding(.vertical, 9)
                                    .background(category == item ? VeraStyle.gold.opacity(0.22) : .white.opacity(0.06), in: Capsule())
                                    .overlay(Capsule().stroke(category == item ? VeraStyle.gold.opacity(0.6) : .white.opacity(0.08), lineWidth: 1))
                                    .foregroundStyle(category == item ? VeraStyle.gold : .white.opacity(0.72))
                            }.buttonStyle(.plain)
                        }
                    }
                }
                ForEach(filtered) { quote in
                    Button { openedQuote = quote } label: {
                        VStack(alignment: .leading, spacing: 10) {
                            Text(quote.text).font(.system(size: 17, weight: .medium, design: .serif)).lineSpacing(3).multilineTextAlignment(.leading).foregroundStyle(.white)
                            HStack {
                                Text(quote.source).foregroundStyle(VeraStyle.gold)
                                Spacer()
                                Text(quote.category.uppercased()).foregroundStyle(VeraStyle.muted)
                            }.font(.system(size: 10, weight: .semibold)).tracking(0.8)
                        }
                        .padding(17).frame(maxWidth: .infinity, alignment: .leading)
                        .background(.white.opacity(0.055), in: RoundedRectangle(cornerRadius: 18))
                        .overlay(RoundedRectangle(cornerRadius: 18).stroke(.white.opacity(0.07), lineWidth: 1))
                    }.buttonStyle(.plain)
                }
                if filtered.isEmpty { Text("Ничего не найдено").foregroundStyle(VeraStyle.muted).padding(.top, 30) }
            }.padding(20).padding(.top, 10)
        }
    }
}

struct FavoritesView: View {
    @Binding var openedQuote: Quote?
    @State private var favorites = SharedStore.favorites()
    private var saved: [Quote] { QuoteLibrary.all.filter { favorites.contains($0.id) } }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                Text("Избранное").font(.system(size: 30, weight: .medium, design: .serif)).foregroundStyle(.white)
                Text("Сохранённое остаётся рядом.").font(.system(size: 14)).foregroundStyle(VeraStyle.muted)
                if saved.isEmpty {
                    ContentUnavailableView("Пока пусто", systemImage: "heart", description: Text("Сохраняйте стихи, которые хочется перечитать."))
                        .foregroundStyle(.white)
                } else {
                    ForEach(saved) { quote in
                        Button { openedQuote = quote } label: {
                            VStack(alignment: .leading, spacing: 9) {
                                Text(quote.text).font(.system(size: 17, weight: .medium, design: .serif)).multilineTextAlignment(.leading).foregroundStyle(.white)
                                Text(quote.source).font(.system(size: 11, weight: .semibold)).foregroundStyle(VeraStyle.gold)
                            }.padding(17).frame(maxWidth: .infinity, alignment: .leading).background(.white.opacity(0.06), in: RoundedRectangle(cornerRadius: 17))
                        }.buttonStyle(.plain)
                    }
                }
            }.padding(20).padding(.top, 10)
        }
        .onAppear { favorites = SharedStore.favorites() }
    }
}

struct QuoteDetailView: View {
    let quote: Quote
    @Environment(\.dismiss) private var dismiss
    @State private var isFavorite = false

    var body: some View {
        ZStack {
            VeraStyle.background.ignoresSafeArea()
            VStack(spacing: 24) {
                HStack {
                    Button("Закрыть") { dismiss() }.foregroundStyle(VeraStyle.gold)
                    Spacer()
                    Text("ТИХИЙ СВЕТ").font(.system(size: 10, weight: .bold)).tracking(2).foregroundStyle(VeraStyle.muted)
                }
                Spacer()
                QuoteCard(quote: quote)
                HStack(spacing: 12) {
                    Button {
                        SharedStore.toggleFavorite(quote.id)
                        isFavorite = SharedStore.favorites().contains(quote.id)
                    } label: {
                        Label(isFavorite ? "Сохранено" : "В избранное", systemImage: isFavorite ? "heart.fill" : "heart")
                            .frame(maxWidth: .infinity).padding(15).background(.white.opacity(0.08), in: Capsule())
                    }
                    ShareLink(item: "\(quote.text)\n\(quote.source)") {
                        Label("Поделиться", systemImage: "square.and.arrow.up").frame(maxWidth: .infinity).padding(15).background(VeraStyle.gold.opacity(0.16), in: Capsule())
                    }
                }.font(.system(size: 13, weight: .semibold)).foregroundStyle(.white).buttonStyle(.plain)
                Spacer()
            }.padding(22)
        }
        .onAppear { isFavorite = SharedStore.favorites().contains(quote.id) }
        .presentationDetents([.large])
        .preferredColorScheme(.dark)
    }
}

struct SettingsView: View {
    @State private var theme = SharedStore.theme()
    @State private var selected = SharedStore.selectedCategories()
    private let themes = ["Графит", "Полночь", "Бордо", "Лес"]
    private let categories = ["Библия", "Любовь", "Бог", "Вера", "Надежда", "Поддержка", "Мир", "Прощение", "Милосердие", "Мудрость", "Молитвы", "Хвала", "Благодать"]

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 22) {
                Text("Настройки").font(.system(size: 30, weight: .medium, design: .serif)).foregroundStyle(.white)
                sectionTitle("ТЕМА ВИДЖЕТА")
                ForEach(themes, id: \.self) { item in
                    Button {
                        theme = item
                        SharedStore.saveTheme(item)
                    } label: {
                        HStack(spacing: 12) {
                            Circle().fill(themeColor(item)).frame(width: 25, height: 25)
                            Text(item).foregroundStyle(.white)
                            Spacer()
                            if theme == item { Image(systemName: "checkmark.circle.fill").foregroundStyle(VeraStyle.gold) }
                        }.padding(15).background(.white.opacity(0.06), in: RoundedRectangle(cornerRadius: 15))
                    }.buttonStyle(.plain)
                }
                sectionTitle("ТЕМЫ ДЛЯ ВИДЖЕТА")
                Text("Виджет будет выбирать цитаты из отмеченных тем.").font(.system(size: 13)).foregroundStyle(VeraStyle.muted)
                LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 9) {
                    ForEach(categories, id: \.self) { item in
                        Button {
                            if selected.contains(item) { selected.remove(item) } else { selected.insert(item) }
                            SharedStore.saveCategories(selected)
                        } label: {
                            HStack {
                                Text(item).font(.system(size: 12, weight: .semibold))
                                Spacer(minLength: 2)
                                Image(systemName: selected.contains(item) ? "checkmark.circle.fill" : "circle").font(.system(size: 13))
                            }.foregroundStyle(selected.contains(item) ? VeraStyle.gold : .white.opacity(0.65))
                                .padding(12).background(.white.opacity(0.055), in: RoundedRectangle(cornerRadius: 12))
                        }.buttonStyle(.plain)
                    }
                }
                sectionTitle("ДОБАВИТЬ ВИДЖЕТ")
                Text("Зажми пустое место на домашнем экране iPhone → нажми «Изменить» → «Добавить виджет» → найди «Тихий свет». Доступны размеры Small, Medium и Large.")
                    .font(.system(size: 13)).lineSpacing(4).foregroundStyle(VeraStyle.muted)
                Text("Все избранные и настройки хранятся на устройстве. Приложение работает офлайн.")
                    .font(.system(size: 12)).foregroundStyle(.white.opacity(0.35))
            }.padding(20).padding(.top, 10)
        }
    }

    private func sectionTitle(_ title: String) -> some View {
        Text(title).font(.system(size: 10, weight: .bold)).tracking(2).foregroundStyle(VeraStyle.muted).padding(.top, 5)
    }
    private func themeColor(_ name: String) -> Color {
        switch name {
        case "Полночь": return Color(red: 0.10, green: 0.13, blue: 0.24)
        case "Бордо": return Color(red: 0.29, green: 0.08, blue: 0.17)
        case "Лес": return Color(red: 0.06, green: 0.20, blue: 0.17)
        default: return Color(red: 0.20, green: 0.18, blue: 0.23)
        }
    }
}
