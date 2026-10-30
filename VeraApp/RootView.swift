import SwiftUI

struct RootView: View {
    @State private var tab = 0
    var body: some View {
        ZStack {
            Color(red: 0.075, green: 0.067, blue: 0.09).ignoresSafeArea()
            Group {
                switch tab {
                case 0: HomeView()
                case 1: TopicsView()
                case 2: FavoritesView()
                default: SettingsView()
                }
            }
        }
        .safeAreaInset(edge: .bottom) {
            HStack(spacing: 0) {
                tabButton("quote.opening", "Главная", 0)
                tabButton("books.vertical.fill", "Темы", 1)
                tabButton("heart.fill", "Избранное", 2)
                tabButton("gearshape.fill", "Настройки", 3)
            }
            .padding(.vertical, 12)
            .background(.ultraThinMaterial, in: Capsule())
            .overlay(Capsule().stroke(.white.opacity(0.13), lineWidth: 1))
            .padding(.horizontal, 18)
            .padding(.bottom, 6)
        }
        .tint(Color(red: 0.82, green: 0.61, blue: 0.37))
    }

    private func tabButton(_ icon: String, _ title: String, _ index: Int) -> some View {
        Button { tab = index } label: {
            VStack(spacing: 5) {
                Image(systemName: icon).font(.system(size: 21, weight: .semibold))
                Text(title).font(.system(size: 11, weight: .medium))
            }
            .foregroundStyle(tab == index ? Color(red: 0.88, green: 0.67, blue: 0.43) : .white.opacity(0.8))
            .frame(maxWidth: .infinity)
        }
        .buttonStyle(.plain)
    }
}

struct QuoteCard: View {
    let quote: Quote
    var body: some View {
        VStack(spacing: 18) {
            Text(quote.text)
                .font(.system(size: 27, weight: .semibold, design: .serif))
                .multilineTextAlignment(.center)
                .lineSpacing(7)
                .foregroundStyle(.white)
            Text(quote.source)
                .font(.system(size: 15, weight: .semibold))
                .foregroundStyle(Color(red: 0.84, green: 0.63, blue: 0.40))
        }
        .padding(28)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background {
            ZStack {
                LinearGradient(colors: [Color(red: 0.20, green: 0.18, blue: 0.23), .black], startPoint: .topLeading, endPoint: .bottomTrailing)
                RadialGradient(colors: [Color.white.opacity(0.10), .clear], center: .topTrailing, startRadius: 5, endRadius: 280)
            }
        }
        .clipShape(RoundedRectangle(cornerRadius: 28))
        .overlay(RoundedRectangle(cornerRadius: 28).stroke(.white.opacity(0.12), lineWidth: 1))
    }
}

struct HomeView: View {
    @State private var current = QuoteLibrary.all[0]
    @State private var favorites = SharedStore.favorites()
    var body: some View {
        VStack(spacing: 18) {
            HStack {
                Text("ТИХИЙ СВЕТ").font(.system(size: 13, weight: .bold, design: .rounded)).tracking(3)
                Spacer()
                Text("СЛОВО ДНЯ").font(.system(size: 11, weight: .semibold)).foregroundStyle(.white.opacity(0.45))
            }
            .foregroundStyle(.white.opacity(0.8))
            .padding(.horizontal, 4)
            QuoteCard(quote: current)
                .padding(.vertical, 6)
            HStack(spacing: 18) {
                Button {
                    if favorites.contains(current.id) { favorites.remove(current.id) } else { favorites.insert(current.id) }
                    SharedStore.toggleFavorite(current.id)
                } label: {
                    Label(favorites.contains(current.id) ? "В избранном" : "В избранное", systemImage: favorites.contains(current.id) ? "heart.fill" : "heart")
                        .frame(maxWidth: .infinity).padding()
                        .background(.white.opacity(0.08), in: Capsule())
                }
                Button {
                    let pool = QuoteLibrary.all.filter { SharedStore.selectedCategories().contains($0.category) || SharedStore.selectedCategories().contains($0.kind) }
                    current = (pool.isEmpty ? QuoteLibrary.all : pool).filter { $0.id != current.id }.randomElement() ?? QuoteLibrary.all[0]
                } label: {
                    Label("Следующая", systemImage: "arrow.clockwise")
                        .frame(maxWidth: .infinity).padding()
                        .background(.white.opacity(0.08), in: Capsule())
                }
            }
            .font(.system(size: 14, weight: .semibold))
            .buttonStyle(.plain)
        }
        .padding(.horizontal, 20)
        .padding(.top, 22)
        .padding(.bottom, 12)
    }
}

struct TopicsView: View {
    @State private var selected = SharedStore.selectedCategories()
    private let topics = ["Библия", "Любовь", "Бог", "Вера", "Надежда", "Поддержка", "Мир", "Прощение", "Молитвы", "Благодать", "Мудрость", "Хвала"]
    private let columns = [GridItem(.flexible()), GridItem(.flexible())]
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 22) {
                Text("Что у вас на душе?").font(.system(size: 30, weight: .bold))
                Text("Выбирайте темы — виджет будет подбирать тексты из выбранных категорий.")
                    .font(.system(size: 15)).foregroundStyle(.white.opacity(0.55))
                LazyVGrid(columns: columns, spacing: 12) {
                    ForEach(topics, id: \.self) { topic in
                        Button {
                            if selected.contains(topic) { selected.remove(topic) } else { selected.insert(topic) }
                            SharedStore.saveCategories(selected)
                        } label: {
                            HStack {
                                Text(topic).font(.system(size: 16, weight: .semibold))
                                Spacer()
                                Image(systemName: selected.contains(topic) ? "checkmark.circle.fill" : "circle")
                            }
                            .foregroundStyle(selected.contains(topic) ? Color(red: 0.88, green: 0.67, blue: 0.43) : .white.opacity(0.75))
                            .padding(16)
                            .background(.white.opacity(0.055), in: RoundedRectangle(cornerRadius: 18))
                            .overlay(RoundedRectangle(cornerRadius: 18).stroke(selected.contains(topic) ? Color(red: 0.82, green: 0.61, blue: 0.37) : .white.opacity(0.12), lineWidth: 1.5))
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
            .padding(22)
        }
    }
}

struct FavoritesView: View {
    private var favorites: [Quote] { QuoteLibrary.all.filter { SharedStore.favorites().contains($0.id) } }
    var body: some View {
        NavigationStack {
            List(favorites) { quote in
                VStack(alignment: .leading, spacing: 8) {
                    Text(quote.text).font(.system(.body, design: .serif))
                    Text(quote.source).font(.caption).foregroundStyle(.orange)
                }
                .listRowBackground(Color.white.opacity(0.05))
            }
            .scrollContentBackground(.hidden)
            .background(Color.clear)
            .navigationTitle("Избранное")
        }
        .preferredColorScheme(.dark)
    }
}


struct SettingsView: View {
    @State private var theme = SharedStore.theme()
    private let themes = ["Графит", "Полночь", "Бордо", "Лес"]
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 22) {
                Text("Настройки").font(.system(size: 30, weight: .bold))
                Text("ОФОРМЛЕНИЕ ВИДЖЕТА")
                    .font(.system(size: 12, weight: .bold)).tracking(2)
                    .foregroundStyle(.white.opacity(0.48))
                ForEach(themes, id: \.self) { item in
                    Button {
                        theme = item
                        SharedStore.saveTheme(item)
                    } label: {
                        HStack {
                            Circle().fill(themeColor(item)).frame(width: 28, height: 28)
                            Text(item).font(.system(size: 16, weight: .semibold))
                            Spacer()
                            if theme == item { Image(systemName: "checkmark.circle.fill") }
                        }
                        .foregroundStyle(.white)
                        .padding(17)
                        .background(.white.opacity(0.06), in: RoundedRectangle(cornerRadius: 16))
                        .overlay(RoundedRectangle(cornerRadius: 16).stroke(theme == item ? Color(red: 0.84, green: 0.63, blue: 0.40) : .white.opacity(0.12), lineWidth: 1.5))
                    }.buttonStyle(.plain)
                }
                Divider().overlay(.white.opacity(0.12))
                Text("РАЗМЕРЫ").font(.system(size: 12, weight: .bold)).tracking(2).foregroundStyle(.white.opacity(0.48))
                Text("Поддерживаются малый, средний и большой виджеты. Чтобы добавить: зажми экран Домой → «Изменить» → «Добавить виджет» → «Тихий свет».")
                    .foregroundStyle(.white.opacity(0.68))
                Text("ОБНОВЛЕНИЕ").font(.system(size: 12, weight: .bold)).tracking(2).foregroundStyle(.white.opacity(0.48))
                Text("Система iOS сама выбирает время обновления. При изменении темы или категорий приложение просит iOS обновить виджеты.")
                    .foregroundStyle(.white.opacity(0.68))
                Text("ТИХИЙ СВЕТ • BETA").font(.caption).foregroundStyle(.white.opacity(0.3))
            }
            .padding(24)
        }
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
