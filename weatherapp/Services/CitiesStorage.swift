import Foundation
import SwiftData

protocol CitiesStorageProtocol {
    func fetchCities() throws -> [City]
    func saveCity(_ city: City) throws
    func deleteCity(id: UUID) throws
}

class SwiftDataCitiesStorage: CitiesStorageProtocol {
    private let modelContainer: ModelContainer
    private let modelContext: ModelContext

    init(modelContainer: ModelContainer) throws {
        self.modelContainer = modelContainer
        self.modelContext = ModelContext(modelContainer)
    }

    func fetchCities() throws -> [City] {
        let descriptor = FetchDescriptor<CityEntity>(sortBy: [SortDescriptor(\.addedAt)])
        let entities = try modelContext.fetch(descriptor)
        var result: [City] = []
        for entity in entities {
            result.append(City(id: entity.id, name: entity.name))
        }
        return result
    }

    func saveCity(_ city: City) throws {
        let existing = try fetchCities()
        // не даем добавить один и тот же город дважды
        for c in existing {
            if c.name.lowercased() == city.name.lowercased() {
                throw CitiesStorageError.duplicateCity
            }
        }
        let entity = CityEntity(id: city.id, name: city.name, addedAt: Date())
        modelContext.insert(entity)
        try modelContext.save()
    }

    func deleteCity(id: UUID) throws {
        let descriptor = FetchDescriptor<CityEntity>(predicate: #Predicate { $0.id == id })
        let entities = try modelContext.fetch(descriptor)
        for entity in entities {
            modelContext.delete(entity)
        }
        try modelContext.save()
    }
}

enum CitiesStorageError: LocalizedError {
    case duplicateCity
    case saveFailed(Error)

    var errorDescription: String? {
        switch self {
        case .duplicateCity:
            return "This city is already in the list."
        case .saveFailed(let error):
            return "Failed to save: \(error.localizedDescription)"
        }
    }
}
