import Foundation
import WidgetKit

enum SharedStore {
    static let suite = "group.com.kriscarter.vera"
    static let selectedCategoriesKey = "selectedCategories"
    static let favoritesKey = "favorites"
    static let themeKey = "widgetTheme"

    static var defaults: UserDefaults { UserDefaults(suiteName: suite) ?? .standard }

    static func selectedCategories() -> Set<String> {
        Set(defaults.stringArray(forKey: selectedCategoriesKey) ?? ["Библия", "Любовь", "Вера", "Надежда", "Поддержка"])
    }
    static func saveCategories(_ categories: Set<String>) {
        defaults.set(Array(categories), forKey: selectedCategoriesKey)
        WidgetCenter.shared.reloadAllTimelines()
    }
    static func favorites() -> Set<String> {
        Set(defaults.stringArray(forKey: favoritesKey) ?? [])
    }
    static func toggleFavorite(_ id: String) {
        var ids = favorites()
        if ids.contains(id) { ids.remove(id) } else { ids.insert(id) }
        defaults.set(Array(ids), forKey: favoritesKey)
    }
    static func theme() -> String { defaults.string(forKey: themeKey) ?? "Графит" }
    static func saveTheme(_ theme: String) {
        defaults.set(theme, forKey: themeKey)
        WidgetCenter.shared.reloadAllTimelines()
    }
}
