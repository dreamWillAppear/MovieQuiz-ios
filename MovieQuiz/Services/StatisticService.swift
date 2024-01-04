import UIKit

final class StatisticServiceImplementation: StatisticService {
    func store(correct count: Int, total amount: Int) {
        <#code#>
    }
    
    var totalAccuracy: Double
    var gamesCount: Int
    var bestGame: GameRecord {
        get {
            guard let data = userDefaults.data(forKey: Keys.bestGame.rawValue),
            let record = try? JSONDecoder().decode(GameRecord.self, from: data) else {
                return .init(correct: 0, total: 0, date: Date())
            }

            return record
        }

        set {
            guard let data = try? JSONEncoder().encode(newValue) else {
                print("Невозможно сохранить результат")
                return
            }

            userDefaults.set(data, forKey: Keys.bestGame.rawValue)
        }
    }
    
    private enum Keys: String {
        case correct, total, bestGame, gamesCount
    }
    
    private var newValue = String()
    private let userDefaults = UserDefaults.standard
    
}
