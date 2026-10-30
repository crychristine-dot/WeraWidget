import SwiftUI

struct SettingsView: View {
    @EnvironmentObject private var store: VeraStore
    private let categories = ["Вера", "Надежда", "Поддержка", "Спокойствие", "Любовь", "Мудрость", "Благодарность"]
    private let themes = ["Обсидиан", "Полночь", "Бордо", "Лес"]
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    Text("Настройки").font(.system(size: 34, weight: .regular, design: .serif)).foregroundStyle(.white)
                    VStack(alignment: .leading, spacing: 14) {
                        Text("ТЕМА ВИДЖЕТА").font(.system(size: 10, weight: .bold)).tracking(2).foregroundStyle(VeraTheme.muted)
                        ForEach(themes, id: \.self) { theme in
                            Button { store.setTheme(theme) } label: {
                                HStack {
                                    Circle().fill(LinearGradient(colors: VeraTheme.gradient(theme), startPoint: .topLeading, endPoint: .bottomTrailing)).frame(width: 34, height: 34)
                                    Text(theme).foregroundStyle(.white).font(.system(size: 14))
                                    Spacer()
                                    if store.theme == theme { Image(systemName: "checkmark").foregroundStyle(VeraTheme.gold) }
                                }.padding(13).background(VeraTheme.panel, in: RoundedRectangle(cornerRadius: 14))
                            }
                        }
                    }
                    VStack(alignment: .leading, spacing: 14) {
                        Text("КАТЕГОРИИ ДЛЯ ВИДЖЕТА").font(.system(size: 10, weight: .bold)).tracking(2).foregroundStyle(VeraTheme.muted)
                        Text("Выбери темы, которые хочешь чаще видеть на главном экране.").font(.system(size: 12)).foregroundStyle(VeraTheme.muted)
                        ForEach(categories, id: \.self) { item in
                            Button {
                                var updated = store.categories
                                if updated.contains(item) { updated.remove(item) } else { updated.insert(item) }
                                store.setCategories(updated)
                            } label: {
                                HStack {
                                    Text(item).foregroundStyle(.white).font(.system(size: 14))
                                    Spacer()
                                    Image(systemName: store.categories.contains(item) ? "checkmark.circle.fill" : "circle")
                                        .foregroundStyle(store.categories.contains(item) ? VeraTheme.gold : VeraTheme.muted)
                                }.padding(.vertical, 9)
                            }
                        }
                    }.padding(18).background(VeraTheme.panel, in: RoundedRectangle(cornerRadius: 18))
                    VStack(alignment: .leading, spacing: 7) {
                        Text("Тихий свет").font(.system(size: 18, design: .serif)).foregroundStyle(.white)
                        Text("Версия 1.0 · Работает офлайн").font(.system(size: 11)).foregroundStyle(VeraTheme.muted)
                    }.padding(.top, 4)
                }.padding(.horizontal, 20).padding(.top, 18).padding(.bottom, 30)
            }.background(VeraTheme.background.ignoresSafeArea()).toolbar(.hidden, for: .navigationBar)
        }
    }
}
