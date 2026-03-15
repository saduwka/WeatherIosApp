import Foundation

// модель города для экранов (id нужен для списка и навигации)
struct City: Identifiable, Hashable {
    let id: UUID
    let name: String

    init(id: UUID = UUID(), name: String) {
        self.id = id
        self.name = name
    }
}
