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
        
        updateWeather(plant: plant, now: now)
        
        let weather = plant.currentWeather
        let isShielded = now < plant.shieldedUntil
        
        if !isShielded {
            plant.waterLevel = max(0, min(1, plant.waterLevel - plant.species.waterDecayPerHour * weather.waterDecayMultiplier * elapsedHours))
            plant.lightLevel = max(0, min(1, plant.lightLevel - plant.species.lightDecayPerHour * weather.lightDecayMultiplier * elapsedHours))
        }
        
        if plant.waterLevel < 0.2 && plant.lightLevel < 0.2 && !isShielded {
            if !plant.isSick {
                NotificationManager.shared.scheduleSicknessAlert(plantName: plant.name)
            }
            plant.isSick = true
        }
        
        if plant.isSick && !isShielded {
            plant.health = max(0, plant.health - plant.species.healthDecayPerHour * 2 * weather.healthDecayMultiplier * elapsedHours)
        } else if plant.waterLevel < 0.3 || plant.lightLevel < 0.3 {
            if !isShielded {
                plant.health = max(0, plant.health - plant.species.healthDecayPerHour * weather.healthDecayMultiplier * elapsedHours)
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
            let effectiveGrowth = plant.species.baseGrowthRate * plant.waterLevel * plant.lightLevel * plant.health * nutrientMultiplier * weather.growthMultiplier * elapsedHours
            plant.growthProgress = min(1, plant.growthProgress + effectiveGrowth)
            
            if plant.growthProgress >= 1.0 {
                let threshold = plant.growthStage.evolutionThreshold
                if plant.waterLevel >= threshold.minWater && plant.lightLevel >= threshold.minLight && plant.nutrients >= threshold.minNutrients {
                    if let next = plant.growthStage.nextStage {
                        plant.growthStage = next
                        plant.growthProgress = 0
                        sprite.mood = .excited
                        wallet?.coins += 5
                        NotificationManager.shared.sendEvolutionCelebration(plantName: plant.name, newStage: next.displayName)
                    }
                }
            }
        }
        
        let newLevel = SpriteEvolutionThreshold.evolutionLevelFor(sprite: sprite, plant: plant)
        if newLevel > sprite.evolutionLevel {
            sprite.evolutionLevel = newLevel
            sprite.mood = .excited
            wallet?.coins += 10
            NotificationManager.shared.sendSpriteEvolutionCelebration(spriteName: sprite.name, newLevel: newLevel)
        }
        
        sprite.fatigue = max(0, sprite.fatigue - 0.1 * elapsedHours)
        
        deriveSpriteMood(sprite: sprite, plant: plant, now: now)
        
        plant.totalDaysAlive = Calendar.current.dateComponents([.day], from: plant.plantedAt, to: now).day ?? 0
        plant.lastCalculatedAt = now
    }
    
    func applyInteraction(plant: Plant, sprite: Sprite, type: InteractionType, wallet: PlayerWallet? = nil) {
        let now = Date.now
        
        guard !cooldownState.isOnCooldown(type: type, now: now) else { return }
        cooldownState.markUsed(type: type, now: now)
        
        let fatiguePenalty = 1.0 - sprite.fatigue * 0.75
        let moodMultiplier: Double = {
            switch sprite.mood {
            case .excited: return 1.25
            case .happy: return 1.0
            case .worried: return 0.8
            case .sad: return 0.6
            case .sleeping: return 1.0
            }
        }()
        let effect = fatiguePenalty * moodMultiplier
        
        switch type {
        case .water:
            plant.waterLevel = min(1, plant.waterLevel + 0.3 * effect)
            plant.lastWateredAt = now
            wallet?.coins += 1
            
        case .light:
            plant.lightLevel = min(1, plant.lightLevel + 0.3 * effect)
            plant.lastLightAt = now
            wallet?.coins += 1
            
        case .fertilize:
            if plant.nutrients >= 5 {
                plant.nutrients -= 5
                plant.growthProgress = min(1, plant.growthProgress + 0.05 * effect)
            }
            wallet?.coins += 1
            
        case .touch:
            sprite.happiness = min(1, sprite.happiness + 0.1 * effect)
            sprite.interactionCount += 1
            wallet?.coins += 2
            
        case .talk:
            sprite.happiness = min(1, sprite.happiness + 0.05 * effect)
            sprite.interactionCount += 1
            wallet?.coins += 2
            
        case .sing:
            sprite.happiness = min(1, sprite.happiness + 0.15 * effect)
            sprite.interactionCount += 2
            sprite.fatigue = min(1, sprite.fatigue + 0.05)
            wallet?.coins += 3
            
        case .heal:
            if plant.isSick {
                plant.isSick = false
                plant.health = min(1, plant.health + 0.4 * effect)
            } else {
                plant.health = min(1, plant.health + 0.1 * effect)
            }
            wallet?.coins += 2
            
        case .play:
            sprite.happiness = min(1, sprite.happiness + 0.12 * effect)
            sprite.interactionCount += 3
            sprite.fatigue = min(1, sprite.fatigue + 0.08)
            wallet?.coins += 3
            
        case .shield:
            plant.shieldedUntil = now + 3600.0 * effect
            sprite.happiness = min(1, sprite.happiness + 0.05 * effect)
            wallet?.coins += 4
            
        case .dance:
            sprite.happiness = min(1, sprite.happiness + 0.2 * effect)
            sprite.interactionCount += 2
            sprite.fatigue = min(1, sprite.fatigue + 0.06)
            plant.growthProgress = min(1, plant.growthProgress + 0.02 * effect)
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
    
    func checkAchievements(plant: Plant, sprite: Sprite, wallet: PlayerWallet?, records: [AchievementRecord], pets: [Pet], interactionCounts: [InteractionType: Int]) -> [Achievement] {
        let unlocked = Set(records.filter { $0.isUnlocked }.map { $0.achievementIdRaw })
        var newlyUnlocked: [Achievement] = []
        
        func check(_ achievement: Achievement) {
            if unlocked.contains(achievement.rawValue) { return }
            newlyUnlocked.append(achievement)
        }
        
        if interactionCounts[.water] ?? 0 > 0 { check(.first_water) }
        if interactionCounts[.water] ?? 0 >= 100 { check(.green_thumb) }
        if interactionCounts[.light] ?? 0 >= 100 { check(.sunshine_lover) }
        if sprite.interactionCount >= 500 { check(.plant_whisperer) }
        if wallet?.coins ?? 0 >= 1000 { check(.rich_gardener) }
        if plant.growthStage == .fruit { check(.plant_master) }
        if interactionCounts[.heal] ?? 0 >= 10 { check(.healer) }
        if interactionCounts[.shield] ?? 0 >= 10 { check(.protector) }
        if interactionCounts[.dance] ?? 0 >= 50 { check(.dancer) }
        if interactionCounts[.sing] ?? 0 >= 50 { check(.singer) }
        if interactionCounts.count >= 11 { check(.explorer) }
        if pets.filter({ $0.isOwned }).count >= PetType.allCases.count { check(.pet_lover) }
        
        let nonLegendary = Achievement.allCases.filter { $0 != .legendary }
        let allUnlocked = nonLegendary.allSatisfy { unlocked.contains($0.rawValue) || newlyUnlocked.contains($0) }
        if allUnlocked { check(.legendary) }
        
        return newlyUnlocked
    }

    private func updateWeather(plant: Plant, now: Date) {
        let hoursSinceChange = now.timeIntervalSince(plant.lastWeatherChangeAt) / 3600
        if hoursSinceChange >= 2 + Double.random(in: 0...2) {
            plant.currentWeather = WeatherType.randomWeather(excluding: plant.currentWeather)
            plant.lastWeatherChangeAt = now
        }
    }

    func checkDailyLogin(login: DailyLogin, wallet: PlayerWallet, now: Date = .now) -> Int {
        let calendar = Calendar.current
        let isSameDay = calendar.isDate(login.lastLoginDate, inSameDayAs: now)
        
        if isSameDay { return 0 }
        
        let isYesterday = calendar.isDate(calendar.date(byAdding: .day, value: -1, to: now)!, inSameDayAs: login.lastLoginDate)
        login.consecutiveDays = isYesterday ? login.consecutiveDays + 1 : 1
        login.totalLogins += 1
        login.lastLoginDate = now
        
        let reward = login.todayReward
        wallet.coins += reward
        login.lastRewardClaimed = now
        return reward
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