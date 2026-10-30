import SwiftUI

enum VeraTheme {
    static let background = Color(red: 0.035, green: 0.039, blue: 0.047)
    static let panel = Color(red: 0.085, green: 0.090, blue: 0.102)
    static let muted = Color(red: 0.59, green: 0.58, blue: 0.56)
    static let gold = Color(red: 0.82, green: 0.69, blue: 0.48)
    static func gradient(_ name: String) -> [Color] {
        switch name {
        case "Бордо": return [Color(red: 0.28, green: 0.09, blue: 0.15), Color(red: 0.08, green: 0.04, blue: 0.07)]
        case "Лес": return [Color(red: 0.07, green: 0.22, blue: 0.18), Color(red: 0.025, green: 0.07, blue: 0.065)]
        case "Полночь": return [Color(red: 0.12, green: 0.16, blue: 0.29), Color(red: 0.035, green: 0.045, blue: 0.09)]
        default: return [Color(red: 0.19, green: 0.18, blue: 0.17), Color(red: 0.055, green: 0.055, blue: 0.06)]
        }
    }
}
