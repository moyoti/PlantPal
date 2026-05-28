import Foundation
import SwiftData

final class EdgeCaseHandler {
    
    static func handleDayRollover(plant: Plant, sprite: Sprite, now: Date = .now) {
        let calendar = Calendar.current
        let lastCalcDay = calendar.component(.day, from: plant.lastCalculatedAt)
        let currentDay = calendar.component(.day, from: now)
        
        if lastCalcDay != currentDay {
            resetDailyHabits(plant: plant)
        }
    }
    
    static func resetDailyHabits(plant: Plant) {
        // In real implementation, this would query and reset HabitTask.isCompletedToday
        // The daily reset happens when a new day is detected
    }
    
    static func handleLongAbsence(plant: Plant, sprite: Sprite, now: Date = .now) {
        let elapsedHours = now.timeIntervalSince(plant.lastCalculatedAt) / 3600
        
        if elapsedHours > 72 {
            // After 3+ days absence, cap the damage so plant doesn't instantly die
            // Apply max 48 hours of decay (prevents total death from long absence)
            plant.lastCalculatedAt = now.addingTimeInterval(-min(elapsedHours, 48) * 3600)
        }
    }
    
    static func handleNewPlantCreation(plant: Plant) {
        plant.health = 1.0
        plant.waterLevel = 1.0
        plant.lightLevel = 1.0
        plant.growthProgress = 0.0
        plant.nutrients = 0.0
        plant.plantedAt = Date()
        plant.lastCalculatedAt = Date()
        plant.lastWateredAt = Date()
        plant.lastLightAt = Date()
    }
    
    static func clampAllValues(plant: Plant) {
        plant.health = max(0, min(1, plant.health))
        plant.waterLevel = max(0, min(1, plant.waterLevel))
        plant.lightLevel = max(0, min(1, plant.lightLevel))
        plant.growthProgress = max(0, min(1, plant.growthProgress))
        plant.nutrients = max(0, plant.nutrients)
    }
    
    static func handleSpriteRecovery(sprite: Sprite) {
        if sprite.happiness < 0.1 {
            sprite.happiness = 0.1
        }
    }
}
