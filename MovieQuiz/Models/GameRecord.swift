import UIKit
struct GameRecord: Codable {
    let correct: Int
    let total: Int
    let date: Date
    
    func isBetterThan(_ currentRecord: GameRecord) -> Bool {
        correct > currentRecord.correct
    }
}
