import Foundation
import SwiftData

// модель для SwiftData — тут храним города
@Model
class CityEntity {
    var id: UUID
    var name: String
    var addedAt: Date

    init(id: UUID = UUID(), name: String, addedAt: Date = Date()) {
        self.id = id
        self.name = name
        self.addedAt = addedAt
    }
}
