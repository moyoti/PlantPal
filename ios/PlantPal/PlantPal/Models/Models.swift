import Foundation
import SwiftData

enum PlantSpecies: String, Codable {
    case succulent
    case flower
    case tree
    case herb
    
    var displayName: String {
        switch self {
        case .succulent: return "多肉植物"
        case .flower: return "花仙子"
        case .tree: return "小树苗"
        case .herb: return "香草精灵"
        }
    }
    
    var waterDecayPerHour: Double {
        switch self {
        case .succulent: return 0.02
        case .flower: return 0.04
        case .tree: return 0.05
        case .herb: return 0.03
        }
    }
    
    var lightDecayPerHour: Double {
        switch self {
        case .succulent: return 0.03
        case .flower: return 0.04
        case .tree: return 0.03
        case .herb: return 0.05
        }
    }
    
    var healthDecayPerHour: Double {
        switch self {
        case .succulent: return 0.01
        case .flower: return 0.02
        case .tree: return 0.02
        case .herb: return 0.02
        }
    }
    
    var baseGrowthRate: Double {
        switch self {
        case .succulent: return 0.005
        case .flower: return 0.010
        case .tree: return 0.003
        case .herb: return 0.015
        }
    }
}

struct EvolutionThreshold {
    var minWater: Double
    var minLight: Double
    var minNutrients: Double = 0
}

enum GrowthStage: String, Codable {
    case seed
    case sprout
    case bud
    case bloom
    case fruit
    case wilted
    
    var displayName: String {
        switch self {
        case .seed: return "种子"
        case .sprout: return "嫩芽"
        case .bud: return "花蕾"
        case .bloom: return "开花"
        case .fruit: return "结果"
        case .wilted: return "枯萎"
        }
    }
    
    var evolutionThreshold: EvolutionThreshold {
        switch self {
        case .seed: return EvolutionThreshold(minWater: 0.3, minLight: 0.3)
        case .sprout: return EvolutionThreshold(minWater: 0.4, minLight: 0.4)
        case .bud: return EvolutionThreshold(minWater: 0.5, minLight: 0.5)
        case .bloom: return EvolutionThreshold(minWater: 0.6, minLight: 0.6, minNutrients: 30)
        case .fruit: return EvolutionThreshold(minWater: 0.6, minLight: 0.6, minNutrients: 30)
        case .wilted: return EvolutionThreshold(minWater: 0.3, minLight: 0.3)
        }
    }
    
    var nextStage: GrowthStage? {
        switch self {
        case .seed: return .sprout
        case .sprout: return .bud
        case .bud: return .bloom
        case .bloom: return .fruit
        case .fruit: return .seed
        case .wilted: return nil
        }
    }
}

enum SpriteMood: String, Codable {
    case happy
    case sad
    case worried
    case excited
    case sleeping
}

enum SpriteEvolutionThreshold: Int, Codable {
    case level1 = 1
    case level2 = 2
    case level3 = 3
    case level4 = 4
    case level5 = 5
    
    var requiredInteractionCount: Int {
        switch self {
        case .level1: return 0
        case .level2: return 10
        case .level3: return 30
        case .level4: return 60
        case .level5: return 100
        }
    }
    
    var requiredHappiness: Double {
        switch self {
        case .level1: return 0.0
        case .level2: return 0.3
        case .level3: return 0.5
        case .level4: return 0.7
        case .level5: return 0.9
        }
    }
    
    var requiredPlantGrowthStage: GrowthStage {
        switch self {
        case .level1: return .seed
        case .level2: return .sprout
        case .level3: return .bud
        case .level4: return .bloom
        case .level5: return .fruit
        }
    }
    
    static func evolutionLevelFor(sprite: Sprite, plant: Plant) -> Int {
        let stages: [SpriteEvolutionThreshold] = [.level5, .level4, .level3, .level2, .level1]
        for threshold in stages {
            if sprite.interactionCount >= threshold.requiredInteractionCount
                && sprite.happiness >= threshold.requiredHappiness
                && plantGrowthStageReached(plant: plant, required: threshold.requiredPlantGrowthStage) {
                return threshold.rawValue
            }
        }
        return 1
    }
    
    private static func plantGrowthStageReached(plant: Plant, required: GrowthStage) -> Bool {
        let stageOrder: [GrowthStage] = [.seed, .sprout, .bud, .bloom, .fruit]
        let currentIndex = stageOrder.firstIndex(of: plant.growthStage) ?? 0
        let requiredIndex = stageOrder.firstIndex(of: required) ?? 0
        return currentIndex >= requiredIndex
    }
}

enum InteractionType: String, Codable {
    case water       // 浇水 — 恢复水分
    case light       // 光照 — 恢复光照
    case fertilize   // 施肥 — 消耗养分加速生长
    case touch       // 摸摸 — 提升精灵幸福感
    case talk        // 说话 — 对精灵说话，小幅提升幸福感
    case sing        // 唱歌 — 大幅提升幸福感，有冷却
    case heal        // 治疗 — 植物生病时恢复健康
    case play        // 玩耍 — 互动小游戏，提升幸福感+互动计数
    case shield      // 护盾 — 临时防止环境伤害
    case dance       // 跳舞 — 精灵共舞，大幅提升幸福感+经验
    case pet         // 梳毛 — 精细照料，中等幸福感+降低疲劳
    
    var displayName: String {
        switch self {
        case .water: return "浇水"
        case .light: return "光照"
        case .fertilize: return "施肥"
        case .touch: return "摸摸"
        case .talk: return "说话"
        case .sing: return "唱歌"
        case .heal: return "治疗"
        case .play: return "玩耍"
        case .shield: return "护盾"
        case .dance: return "跳舞"
        case .pet: return "梳毛"
        }
    }
    
    var icon: String {
        switch self {
        case .water: return "icon_water"
        case .light: return "icon_light"
        case .fertilize: return "icon_fertilize"
        case .touch: return "icon_touch"
        case .talk: return "icon_talk"
        case .sing: return "icon_sing"
        case .heal: return "icon_heal"
        case .play: return "icon_play"
        case .shield: return "icon_shield"
        case .dance: return "icon_dance"
        case .pet: return "icon_pet"
        }
    }
    
    var color: String {
        switch self {
        case .water: return "blueWater"
        case .light: return "yellowSun"
        case .fertilize: return "brownEarth"
        case .touch: return "pinkLove"
        case .talk: return "purpleNight"
        case .sing: return "pinkLove"
        case .heal: return "greenLight"
        case .play: return "orangeWarn"
        case .shield: return "blueWater"
        case .dance: return "pinkLove"
        case .pet: return "cream"
        }
    }
    
    /// Cooldown in seconds before this interaction can be used again
    var cooldownSeconds: Double {
        switch self {
        case .water: return 5
        case .light: return 5
        case .fertilize: return 10
        case .touch: return 3
        case .talk: return 5
        case .sing: return 15
        case .heal: return 30
        case .play: return 20
        case .shield: return 60
        case .dance: return 20
        case .pet: return 8
        }
    }
}

enum TaskFrequency: String, Codable {
    case daily
    case weekly
    case custom
}

@Model
class Plant {
    var id: UUID = UUID()
    var name: String = "小绿"
    var speciesRaw: String = PlantSpecies.flower.rawValue
    var growthStageRaw: String = GrowthStage.seed.rawValue
    var health: Double = 1.0
    var growthProgress: Double = 0.0
    var waterLevel: Double = 1.0
    var lightLevel: Double = 1.0
    var nutrients: Double = 0.0
    var lastWateredAt: Date = Date()
    var lastLightAt: Date = Date()
    var plantedAt: Date = Date()
    var lastCalculatedAt: Date = Date()
    var totalDaysAlive: Int = 0
    var potStyle: String = "default"
    var backgroundScene: String = "garden"
    var isSick: Bool = false
    var shieldedUntil: Date = Date.distantPast
    var currentWeatherRaw: String = WeatherType.sunny.rawValue
    var lastWeatherChangeAt: Date = Date()
    
    init(
        id: UUID = UUID(),
        name: String = "小绿",
        speciesRaw: String = PlantSpecies.flower.rawValue,
        growthStageRaw: String = GrowthStage.seed.rawValue,
        health: Double = 1.0,
        growthProgress: Double = 0.0,
        waterLevel: Double = 1.0,
        lightLevel: Double = 1.0,
        nutrients: Double = 0.0,
        lastWateredAt: Date = Date(),
        lastLightAt: Date = Date(),
        plantedAt: Date = Date(),
        lastCalculatedAt: Date = Date(),
        totalDaysAlive: Int = 0,
        potStyle: String = "default",
        backgroundScene: String = "garden",
        isSick: Bool = false,
        shieldedUntil: Date = Date.distantPast,
        currentWeatherRaw: String = WeatherType.sunny.rawValue,
        lastWeatherChangeAt: Date = Date()
    ) {
        self.id = id
        self.name = name
        self.speciesRaw = speciesRaw
        self.growthStageRaw = growthStageRaw
        self.health = health
        self.growthProgress = growthProgress
        self.waterLevel = waterLevel
        self.lightLevel = lightLevel
        self.nutrients = nutrients
        self.lastWateredAt = lastWateredAt
        self.lastLightAt = lastLightAt
        self.plantedAt = plantedAt
        self.lastCalculatedAt = lastCalculatedAt
        self.totalDaysAlive = totalDaysAlive
        self.potStyle = potStyle
        self.backgroundScene = backgroundScene
        self.isSick = isSick
        self.shieldedUntil = shieldedUntil
        self.currentWeatherRaw = currentWeatherRaw
        self.lastWeatherChangeAt = lastWeatherChangeAt
    }
    
    var species: PlantSpecies {
        get { PlantSpecies(rawValue: speciesRaw) ?? .flower }
        set { speciesRaw = newValue.rawValue }
    }
    
    var growthStage: GrowthStage {
        get { GrowthStage(rawValue: growthStageRaw) ?? .seed }
        set { growthStageRaw = newValue.rawValue }
    }
    
    var currentWeather: WeatherType {
        get { WeatherType(rawValue: currentWeatherRaw) ?? .sunny }
        set { currentWeatherRaw = newValue.rawValue }
    }
    
    static func createDefault(species: PlantSpecies = .flower, name: String = "小绿") -> Plant {
        let plant = Plant()
        plant.speciesRaw = species.rawValue
        plant.name = name
        plant.lastWateredAt = Date()
        plant.lastLightAt = Date()
        plant.plantedAt = Date()
        plant.lastCalculatedAt = Date()
        return plant
    }
}

@Model
class Sprite {
    var id: UUID = UUID()
    var name: String = "小精灵"
    var moodRaw: String = SpriteMood.happy.rawValue
    var evolutionLevel: Int = 1
    var happiness: Double = 0.5
    var outfit: String = "default"
    var lastInteractedAt: Date = Date()
    var interactionCount: Int = 0
    var fatigue: Double = 0.0
    
    init(
        id: UUID = UUID(),
        name: String = "小精灵",
        moodRaw: String = SpriteMood.happy.rawValue,
        evolutionLevel: Int = 1,
        happiness: Double = 0.5,
        outfit: String = "default",
        lastInteractedAt: Date = Date(),
        interactionCount: Int = 0,
        fatigue: Double = 0.0
    ) {
        self.id = id
        self.name = name
        self.moodRaw = moodRaw
        self.evolutionLevel = evolutionLevel
        self.happiness = happiness
        self.outfit = outfit
        self.lastInteractedAt = lastInteractedAt
        self.interactionCount = interactionCount
        self.fatigue = fatigue
    }
    
    var mood: SpriteMood {
        get { SpriteMood(rawValue: moodRaw) ?? .happy }
        set { moodRaw = newValue.rawValue }
    }
    
    static func createDefault() -> Sprite {
        let sprite = Sprite()
        sprite.lastInteractedAt = Date()
        return sprite
    }
}

@Model
class HabitTask {
    var id: UUID = UUID()
    var title: String
    var iconEmoji: String = "💧"
    var frequencyRaw: String = TaskFrequency.daily.rawValue
    var nutrientReward: Double = 2.0
    var sunlightReward: Double = 1.0
    var isCompletedToday: Bool = false
    var streakCount: Int = 0
    var completedAt: Date?
    var createdAt: Date = Date()
    
    init(
        id: UUID = UUID(),
        title: String = "",
        iconEmoji: String = "💧",
        frequencyRaw: String = TaskFrequency.daily.rawValue,
        nutrientReward: Double = 2.0,
        sunlightReward: Double = 1.0,
        isCompletedToday: Bool = false,
        streakCount: Int = 0,
        completedAt: Date? = nil,
        createdAt: Date = Date()
    ) {
        self.id = id
        self.title = title
        self.iconEmoji = iconEmoji
        self.frequencyRaw = frequencyRaw
        self.nutrientReward = nutrientReward
        self.sunlightReward = sunlightReward
        self.isCompletedToday = isCompletedToday
        self.streakCount = streakCount
        self.completedAt = completedAt
        self.createdAt = createdAt
    }
    
    var frequency: TaskFrequency {
        get { TaskFrequency(rawValue: frequencyRaw) ?? .daily }
        set { frequencyRaw = newValue.rawValue }
    }
}

@Model
class InteractionRecord {
    var id: UUID = UUID()
    var typeRaw: String = InteractionType.water.rawValue
    var plantId: UUID
    var timestamp: Date = Date()
    var effectValue: Double = 0.3
    
    init(
        id: UUID = UUID(),
        typeRaw: String = InteractionType.water.rawValue,
        plantId: UUID = UUID(),
        timestamp: Date = Date(),
        effectValue: Double = 0.3
    ) {
        self.id = id
        self.typeRaw = typeRaw
        self.plantId = plantId
        self.timestamp = timestamp
        self.effectValue = effectValue
    }
    
    var type: InteractionType {
        get { InteractionType(rawValue: typeRaw) ?? .water }
        set { typeRaw = newValue.rawValue }
    }
}

enum PetType: String, Codable, CaseIterable {
    case cat_sprite
    case dog_sprite
    case bird_sprite
    case fish_sprite
    case bunny_sprite

    var displayName: String {
        switch self {
        case .cat_sprite: return "猫咪精灵"
        case .dog_sprite: return "狗狗精灵"
        case .bird_sprite: return "小鸟精灵"
        case .fish_sprite: return "小鱼精灵"
        case .bunny_sprite: return "兔兔精灵"
        }
    }

    var unlockCost: Int {
        switch self {
        case .cat_sprite: return 100
        case .dog_sprite: return 150
        case .bird_sprite: return 200
        case .fish_sprite: return 250
        case .bunny_sprite: return 300
        }
    }

    var abilities: String {
        switch self {
        case .cat_sprite: return "自动收集金币，偶尔发现宝藏"
        case .dog_sprite: return "保护植物免受伤害，提升友谊速度"
        case .bird_sprite: return "唱歌效果加倍，偶尔带来种子"
        case .fish_sprite: return "浇水效果加倍，降低精灵疲劳"
        case .bunny_sprite: return "玩耍效果加倍，加速植物成长"
        }
    }
}

@Model
class Pet {
    var id: UUID = UUID()
    var name: String = ""
    var petTypeRaw: String = PetType.cat_sprite.rawValue
    var isOwned: Bool = false
    var friendshipLevel: Double = 0.0
    var lastFedAt: Date = Date.distantPast
    var lastPlayedAt: Date = Date.distantPast

    init(
        id: UUID = UUID(),
        name: String = "",
        petTypeRaw: String = PetType.cat_sprite.rawValue,
        isOwned: Bool = false,
        friendshipLevel: Double = 0.0,
        lastFedAt: Date = Date.distantPast,
        lastPlayedAt: Date = Date.distantPast
    ) {
        self.id = id
        self.name = name
        self.petTypeRaw = petTypeRaw
        self.isOwned = isOwned
        self.friendshipLevel = friendshipLevel
        self.lastFedAt = lastFedAt
        self.lastPlayedAt = lastPlayedAt
    }

    var petType: PetType {
        get { PetType(rawValue: petTypeRaw) ?? .cat_sprite }
        set { petTypeRaw = newValue.rawValue }
    }
}

// MARK: - Weather System

enum WeatherType: String, Codable {
    case sunny
    case cloudy
    case rainy
    case stormy
    case snowy

    var displayName: String {
        switch self {
        case .sunny: return "晴天"
        case .cloudy: return "多云"
        case .rainy: return "雨天"
        case .stormy: return "暴风"
        case .snowy: return "雪天"
        }
    }

    var emoji: String {
        switch self {
        case .sunny: return "☀️"
        case .cloudy: return "☁️"
        case .rainy: return "🌧️"
        case .stormy: return "⛈️"
        case .snowy: return "❄️"
        }
    }

    var waterDecayMultiplier: Double {
        switch self {
        case .sunny: return 1.0
        case .cloudy: return 0.9
        case .rainy: return 0.5
        case .stormy: return 1.2
        case .snowy: return 0.6
        }
    }

    var lightDecayMultiplier: Double {
        switch self {
        case .sunny: return 0.8
        case .cloudy: return 1.2
        case .rainy: return 1.3
        case .stormy: return 1.5
        case .snowy: return 1.4
        }
    }

    var healthDecayMultiplier: Double {
        switch self {
        case .sunny: return 1.0
        case .cloudy: return 1.0
        case .rainy: return 1.1
        case .stormy: return 1.5
        case .snowy: return 1.0
        }
    }

    var growthMultiplier: Double {
        switch self {
        case .sunny: return 1.2
        case .cloudy: return 1.0
        case .rainy: return 0.9
        case .stormy: return 0.3
        case .snowy: return 0.0
        }
    }

    static func randomWeather(excluding current: WeatherType? = nil) -> WeatherType {
        let all: [WeatherType] = [.sunny, .sunny, .cloudy, .cloudy, .rainy, .stormy, .snowy]
        let filtered = all.filter { $0 != current }
        return filtered.randomElement() ?? .sunny
    }
}

// MARK: - Achievement System

enum Achievement: String, Codable, CaseIterable {
    case first_water
    case green_thumb
    case sunshine_lover
    case plant_whisperer
    case early_bird
    case dedicated
    case rich_gardener
    case pet_lover
    case plant_master
    case healer
    case protector
    case dancer
    case singer
    case explorer
    case legendary

    var displayName: String {
        switch self {
        case .first_water: return "初露锋芒"
        case .green_thumb: return "绿手指"
        case .sunshine_lover: return "阳光爱好者"
        case .plant_whisperer: return "植物语者"
        case .early_bird: return "早起鸟"
        case .dedicated: return "坚持不懈"
        case .rich_gardener: return "富有园丁"
        case .pet_lover: return "宠物达人"
        case .plant_master: return "植物大师"
        case .healer: return "治愈之手"
        case .protector: return "守护者"
        case .dancer: return "舞者"
        case .singer: return "歌唱家"
        case .explorer: return "探索者"
        case .legendary: return "传奇园丁"
        }
    }

    var achievementDescription: String {
        switch self {
        case .first_water: return "第一次浇水"
        case .green_thumb: return "浇水100次"
        case .sunshine_lover: return "光照100次"
        case .plant_whisperer: return "互动500次"
        case .early_bird: return "连续登录7天"
        case .dedicated: return "连续登录30天"
        case .rich_gardener: return "拥有1000金币"
        case .pet_lover: return "拥有全部宠物"
        case .plant_master: return "植物达到结果阶段"
        case .healer: return "治疗10次"
        case .protector: return "护盾10次"
        case .dancer: return "跳舞50次"
        case .singer: return "唱歌50次"
        case .explorer: return "使用全部互动类型"
        case .legendary: return "解锁所有其他成就"
        }
    }

    var iconEmoji: String {
        switch self {
        case .first_water: return "💧"
        case .green_thumb: return "🌱"
        case .sunshine_lover: return "☀️"
        case .plant_whisperer: return "🌿"
        case .early_bird: return "🐦"
        case .dedicated: return "🔥"
        case .rich_gardener: return "💰"
        case .pet_lover: return "🐾"
        case .plant_master: return "🌳"
        case .healer: return "💚"
        case .protector: return "🛡️"
        case .dancer: return "💃"
        case .singer: return "🎤"
        case .explorer: return "🗺️"
        case .legendary: return "👑"
        }
    }
}

@Model
class AchievementRecord {
    var id: UUID = UUID()
    var achievementIdRaw: String = Achievement.first_water.rawValue
    var unlockedAt: Date = Date()
    var isUnlocked: Bool = false

    init(
        id: UUID = UUID(),
        achievementIdRaw: String = Achievement.first_water.rawValue,
        unlockedAt: Date = Date(),
        isUnlocked: Bool = false
    ) {
        self.id = id
        self.achievementIdRaw = achievementIdRaw
        self.unlockedAt = unlockedAt
        self.isUnlocked = isUnlocked
    }

    var achievement: Achievement {
        get { Achievement(rawValue: achievementIdRaw) ?? .first_water }
        set { achievementIdRaw = newValue.rawValue }
    }
}

// MARK: - Daily Login

@Model
class DailyLogin {
    var id: UUID = UUID()
    var lastLoginDate: Date = Date()
    var consecutiveDays: Int = 0
    var totalLogins: Int = 0
    var lastRewardClaimed: Date = Date.distantPast

    init(
        id: UUID = UUID(),
        lastLoginDate: Date = Date(),
        consecutiveDays: Int = 0,
        totalLogins: Int = 0,
        lastRewardClaimed: Date = Date.distantPast
    ) {
        self.id = id
        self.lastLoginDate = lastLoginDate
        self.consecutiveDays = consecutiveDays
        self.totalLogins = totalLogins
        self.lastRewardClaimed = lastRewardClaimed
    }

    var todayReward: Int {
        switch consecutiveDays {
        case 1: return 5
        case 2...6: return 10
        case 7: return 50
        case 8...29: return 15
        case 30...: return 200
        default: return 5
        }
    }
}