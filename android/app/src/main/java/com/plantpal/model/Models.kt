package com.plantpal.model

import java.util.UUID

enum class PlantSpecies {
    SUCCULENT, FLOWER, TREE, HERB;

    val displayName: String
        get() = when (this) {
            SUCCULENT -> "多肉植物"
            FLOWER -> "花仙子"
            TREE -> "小树苗"
            HERB -> "香草精灵"
        }

    val waterDecayPerHour: Double
        get() = when (this) {
            SUCCULENT -> 0.02
            FLOWER -> 0.04
            TREE -> 0.05
            HERB -> 0.03
        }

    val lightDecayPerHour: Double
        get() = when (this) {
            SUCCULENT -> 0.03
            FLOWER -> 0.04
            TREE -> 0.03
            HERB -> 0.05
        }

    val healthDecayPerHour: Double
        get() = when (this) {
            SUCCULENT -> 0.01
            FLOWER -> 0.02
            TREE -> 0.02
            HERB -> 0.02
        }

    val baseGrowthRate: Double
        get() = when (this) {
            SUCCULENT -> 0.005
            FLOWER -> 0.010
            TREE -> 0.003
            HERB -> 0.015
        }
}

enum class GrowthStage {
    SEED, SPROUT, BUD, BLOOM, FRUIT, WILTED;

    val displayName: String
        get() = when (this) {
            SEED -> "种子"
            SPROUT -> "嫩芽"
            BUD -> "花蕾"
            BLOOM -> "开花"
            FRUIT -> "结果"
            WILTED -> "枯萎"
        }

    val evolutionThreshold: EvolutionThreshold
        get() = when (this) {
            SEED -> EvolutionThreshold(minWater = 0.3, minLight = 0.3)
            SPROUT -> EvolutionThreshold(minWater = 0.4, minLight = 0.4)
            BUD -> EvolutionThreshold(minWater = 0.5, minLight = 0.5)
            BLOOM -> EvolutionThreshold(minWater = 0.6, minLight = 0.6, minNutrients = 30.0)
            FRUIT -> EvolutionThreshold(minWater = 0.6, minLight = 0.6, minNutrients = 30.0)
            WILTED -> EvolutionThreshold(minWater = 0.3, minLight = 0.3)
        }

    val nextStage: GrowthStage?
        get() = when (this) {
            SEED -> SPROUT
            SPROUT -> BUD
            BUD -> BLOOM
            BLOOM -> FRUIT
            FRUIT -> SEED
            WILTED -> null
        }
}

data class EvolutionThreshold(
    val minWater: Double,
    val minLight: Double,
    val minNutrients: Double = 0.0
)

enum class SpriteMood {
    HAPPY, SAD, WORRIED, EXCITED, SLEEPING;

    val displayName: String
        get() = when (this) {
            HAPPY -> "开心"
            EXCITED -> "超开心"
            WORRIED -> "担心"
            SAD -> "难过"
            SLEEPING -> "睡觉"
        }
}

enum class InteractionType {
    WATER, LIGHT, FERTILIZE, TOUCH, TALK,
    SING, HEAL, PLAY, SHIELD, DANCE, PET;

    val displayName: String
        get() = when (this) {
            WATER -> "浇水"
            LIGHT -> "光照"
            FERTILIZE -> "施肥"
            TOUCH -> "摸摸"
            TALK -> "说话"
            SING -> "唱歌"
            HEAL -> "治疗"
            PLAY -> "玩耍"
            SHIELD -> "护盾"
            DANCE -> "跳舞"
            PET -> "梳毛"
        }

    val icon: String
        get() = when (this) {
            WATER -> "icon_water"
            LIGHT -> "icon_light"
            FERTILIZE -> "icon_fertilize"
            TOUCH -> "icon_touch"
            TALK -> "icon_talk"
            SING -> "icon_sing"
            HEAL -> "icon_heal"
            PLAY -> "icon_play"
            SHIELD -> "icon_shield"
            DANCE -> "icon_dance"
            PET -> "icon_pet"
        }

    val cooldownSeconds: Double
        get() = when (this) {
            WATER -> 5.0
            LIGHT -> 5.0
            FERTILIZE -> 10.0
            TOUCH -> 3.0
            TALK -> 5.0
            SING -> 15.0
            HEAL -> 30.0
            PLAY -> 20.0
            SHIELD -> 60.0
            DANCE -> 20.0
            PET -> 8.0
        }
}

enum class SpriteEvolutionThreshold(val level: Int) {
    LEVEL1(1), LEVEL2(2), LEVEL3(3), LEVEL4(4), LEVEL5(5);

    val requiredInteractionCount: Int
        get() = when (this) {
            LEVEL1 -> 0
            LEVEL2 -> 10
            LEVEL3 -> 30
            LEVEL4 -> 60
            LEVEL5 -> 100
        }

    val requiredHappiness: Double
        get() = when (this) {
            LEVEL1 -> 0.0
            LEVEL2 -> 0.3
            LEVEL3 -> 0.5
            LEVEL4 -> 0.7
            LEVEL5 -> 0.9
        }

    val requiredPlantGrowthStage: GrowthStage
        get() = when (this) {
            LEVEL1 -> GrowthStage.SEED
            LEVEL2 -> GrowthStage.SPROUT
            LEVEL3 -> GrowthStage.BUD
            LEVEL4 -> GrowthStage.BLOOM
            LEVEL5 -> GrowthStage.FRUIT
        }

    companion object {
        fun evolutionLevelFor(interactionCount: Int, happiness: Double, plantGrowthStage: GrowthStage): Int {
            val stageOrder = listOf(GrowthStage.SEED, GrowthStage.SPROUT, GrowthStage.BUD, GrowthStage.BLOOM, GrowthStage.FRUIT)
            val plantIndex = stageOrder.indexOf(plantGrowthStage).coerceAtLeast(0)
            for (threshold in entries.reversed()) {
                val requiredIndex = stageOrder.indexOf(threshold.requiredPlantGrowthStage).coerceAtLeast(0)
                if (interactionCount >= threshold.requiredInteractionCount &&
                    happiness >= threshold.requiredHappiness &&
                    plantIndex >= requiredIndex) {
                    return threshold.level
                }
            }
            return 1
        }
    }
}

enum class TaskFrequency {
    DAILY, WEEKLY, CUSTOM
}

enum class PetType {
    CAT_SPRITE, DOG_SPRITE, BIRD_SPRITE, FISH_SPRITE, BUNNY_SPRITE;

    val displayName: String
        get() = when (this) {
            CAT_SPRITE -> "猫咪精灵"
            DOG_SPRITE -> "狗狗精灵"
            BIRD_SPRITE -> "小鸟精灵"
            FISH_SPRITE -> "小鱼精灵"
            BUNNY_SPRITE -> "兔兔精灵"
        }

    val unlockCost: Int
        get() = when (this) {
            CAT_SPRITE -> 100
            DOG_SPRITE -> 150
            BIRD_SPRITE -> 200
            FISH_SPRITE -> 250
            BUNNY_SPRITE -> 300
        }

    val abilities: String
        get() = when (this) {
            CAT_SPRITE -> "自动收集金币，偶尔发现宝藏"
            DOG_SPRITE -> "保护植物免受伤害，提升友谊速度"
            BIRD_SPRITE -> "唱歌效果加倍，偶尔带来种子"
            FISH_SPRITE -> "浇水效果加倍，降低精灵疲劳"
            BUNNY_SPRITE -> "玩耍效果加倍，加速植物成长"
        }
}
