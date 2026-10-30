import Foundation
import Combine
import WidgetKit

@MainActor
final class VeraStore: ObservableObject {
    static let shared = VeraStore()
    static let appGroup = "group.com.kriscarter.vera"
    private let defaults = UserDefaults(suiteName: appGroup) ?? .standard

    @Published private(set) var favorites: Set<String>
    @Published private(set) var categories: Set<String>
    @Published private(set) var theme: String

    private init() {
        favorites = Set(defaults.stringArray(forKey: "favorites") ?? [])
        categories = Set(defaults.stringArray(forKey: "categories") ?? ["Вера", "Надежда", "Поддержка", "Спокойствие"])
        theme = defaults.string(forKey: "theme") ?? "Обсидиан"
    }

    func isFavorite(_ id: String) -> Bool { favorites.contains(id) }
    func toggleFavorite(_ id: String) {
        if favorites.contains(id) { favorites.remove(id) } else { favorites.insert(id) }
        defaults.set(Array(favorites), forKey: "favorites")
        WidgetCenter.shared.reloadAllTimelines()
    }
    func setCategories(_ value: Set<String>) {
        categories = value
        defaults.set(Array(value), forKey: "categories")
        WidgetCenter.shared.reloadAllTimelines()
    }
    func setTheme(_ value: String) {
        theme = value
        defaults.set(value, forKey: "theme")
        WidgetCenter.shared.reloadAllTimelines()
    }
}
