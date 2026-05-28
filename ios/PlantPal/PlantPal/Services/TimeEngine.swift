import Foundation
import OSLog

final class TimeEngine {
    
    private let logger = Logger(subsystem: "com.plantpal", category: "TimeEngine")
    
    struct CooldownState {
        var lastUsedAt: [InteractionType: Date] = [:]
        
        func isOnCooldown(type: InteractionType, now: Date = .now) -> Bool {
            guard let lastUsed = lastUsedAt[type] else { return false }
            return now.timeIntervalSince(lastUsed) < type.cooldownSeconds
        }
        
        func remainingCooldown(type: InteractionType, now: Date = .now) -> Double {
            guard let lastUsed = lastUsedAt[type] else { return 0 }
            let elapsed = now.timeIntervalSince(lastUsed)
            return max(0, type.cooldownSeconds - elapsed)
        }
        
        mutating func markUsed(type: InteractionType, now: Date = .now) {
            lastUsedAt[type] = now
        }
    }
    
    @Published var cooldownState = CooldownState()
    
    func calculateTimeEffects(plant: Plant, sprite: Sprite, wallet: PlayerWallet? = nil, now: Date = .now) {
        let elapsedSeconds = now.timeIntervalSince(plant.lastCalculatedAt)
        let elapsedHours = max(0, elapsedSeconds / 3600)
        
        guard elapsedHours >= 0.01 else { return }
        
        let isShielded = now < plant.shieldedUntil
        
        if !isShielded {
            plant.waterLevel = max(0, min(1, plant.waterLevel - plant.species.waterDecayPerHour * elapsedHours))
            plant.lightLevel = max(0, min(1, plant.lightLevel - plant.species.lightDecayPerHour * elapsedHours))
        }
        
        if plant.waterLevel < 0.2 && plant.lightLevel < 0.2 && !isShielded {
            plant.isSick = true
        }
        
        if plant.isSick && !isShielded {
            plant.health = max(0, plant.health - plant.species.healthDecayPerHour * 2 * elapsedHours)
        } else if plant.waterLevel < 0.3 || plant.lightLevel < 0.3 {
            if !isShielded {
                plant.health = max(0, plant.health - plant.species.healthDecayPerHour * elapsedHours)
            }
        } else if plant.health < 1.0 {
            plant.health = min(1, plant.health + 0.01 * elapsedHours)
        }
        
        if plant.health < 0.3 && plant.growthStage != .wilted {
            plant.growthStage = .wilted
        } else if plant.growthStage == .wilted && plant.health >= 0.3 && plant.waterLevel >= 0.3 && plant.lightLevel >= 0.3 {
            plant.growthStage = .sprout
        }
        
        if plant.growthStage != .wilted && !plant.isSick {
            let nutrientMultiplier = 1 + plant.nutrients / 200
            let effectiveGrowth = plant.species.baseGrowthRate * plant.waterLevel * plant.lightLevel * plant.health * nutrientMultiplier * elapsedHours
            plant.growthProgress = min(1, plant.growthProgress + effectiveGrowth)
            
            if plant.growthProgress >= 1.0 {
                let threshold = plant.growthStage.evolutionThreshold
                if plant.waterLevel >= threshold.minWater && plant.lightLevel >= threshold.minLight && plant.nutrients >= threshold.minNutrients {
                    if let next = plant.growthStage.nextStage {
                        plant.growthStage = next
                        plant.growthProgress = 0
                        sprite.mood = .excited
                        wallet?.coins += 5
                    }
                }
            }
        }
        
        let newLevel = SpriteEvolutionThreshold.evolutionLevelFor(sprite: sprite, plant: plant)
        if newLevel > sprite.evolutionLevel {
            sprite.evolutionLevel = newLevel
            sprite.mood = .excited
            wallet?.coins += 10
        }
        
        sprite.fatigue = max(0, sprite.fatigue - 0.02 * elapsedHours)
        
        deriveSpriteMood(sprite: sprite, plant: plant, now: now)
        
        plant.totalDaysAlive = Calendar.current.dateComponents([.day], from: plant.plantedAt, to: now).day ?? 0
        plant.lastCalculatedAt = now
    }
    
    func applyInteraction(plant: Plant, sprite: Sprite, type: InteractionType, wallet: PlayerWallet? = nil) {
        let now = Date.now
        
        guard !cooldownState.isOnCooldown(type: type, now: now) else { return }
        cooldownState.markUsed(type: type, now: now)
        
        switch type {
        case .water:
            plant.waterLevel = min(1, plant.waterLevel + 0.3)
            plant.lastWateredAt = now
            wallet?.coins += 1
            
        case .light:
            plant.lightLevel = min(1, plant.lightLevel + 0.3)
            plant.lastLightAt = now
            wallet?.coins += 1
            
        case .fertilize:
            if plant.nutrients >= 5 {
                plant.nutrients -= 5
                plant.growthProgress = min(1, plant.growthProgress + 0.05)
            }
            wallet?.coins += 1
            
        case .touch:
            sprite.happiness = min(1, sprite.happiness + 0.1)
            sprite.interactionCount += 1
            wallet?.coins += 2
            
        case .talk:
            sprite.happiness = min(1, sprite.happiness + 0.05)
            sprite.interactionCount += 1
            wallet?.coins += 2
            
        case .sing:
            sprite.happiness = min(1, sprite.happiness + 0.15)
            sprite.interactionCount += 2
            sprite.fatigue = min(1, sprite.fatigue + 0.1)
            wallet?.coins += 3
            
        case .heal:
            if plant.isSick {
                plant.isSick = false
                plant.health = min(1, plant.health + 0.4)
            } else {
                plant.health = min(1, plant.health + 0.1)
            }
            wallet?.coins += 2
            
        case .play:
            sprite.happiness = min(1, sprite.happiness + 0.12)
            sprite.interactionCount += 3
            sprite.fatigue = min(1, sprite.fatigue + 0.15)
            wallet?.coins += 3
            
        case .shield:
            plant.shieldedUntil = now + 3600
            sprite.happiness = min(1, sprite.happiness + 0.05)
            wallet?.coins += 4
            
        case .dance:
            sprite.happiness = min(1, sprite.happiness + 0.2)
            sprite.interactionCount += 2
            sprite.fatigue = min(1, sprite.fatigue + 0.12)
            plant.growthProgress = min(1, plant.growthProgress + 0.02)
            wallet?.coins += 4
            
        case .pet:
            sprite.happiness = min(1, sprite.happiness + 0.08)
            sprite.fatigue = max(0, sprite.fatigue - 0.1)
            sprite.interactionCount += 1
            wallet?.coins += 2
        }
        
        sprite.lastInteractedAt = now
        deriveSpriteMood(sprite: sprite, plant: plant, now: now)
    }
    
    func applyHabitCompletion(plant: Plant, sprite: Sprite, task: HabitTask, wallet: PlayerWallet? = nil) {
        plant.nutrients += task.nutrientReward
        plant.lightLevel = min(1, plant.lightLevel + task.sunlightReward)
        sprite.interactionCount += 1
        wallet?.coins += 3 + task.streakCount
    }
    
    private func deriveSpriteMood(sprite: Sprite, plant: Plant, now: Date) {
        let hour = Calendar.current.component(.hour, from: now)
        if hour >= 22 || hour < 7 {
            sprite.mood = .sleeping
            return
        }
        
        if sprite.fatigue > 0.8 {
            sprite.mood = .worried
            return
        }
        
        if plant.isSick || plant.health < 0.3 || plant.growthStage == .wilted {
            sprite.mood = .sad
        } else if plant.health < 0.5 || plant.waterLevel < 0.3 || plant.lightLevel < 0.3 {
            sprite.mood = .worried
        } else if sprite.happiness > 0.8 {
            sprite.mood = .excited
        } else {
            sprite.mood = .happy
        }
    }
}