package com.plantpal.engine

import com.plantpal.data.entity.PlantEntity
import com.plantpal.data.entity.SpriteEntity
import com.plantpal.data.entity.PlayerWalletEntity
import com.plantpal.data.entity.AchievementEntity
import com.plantpal.data.entity.DailyLoginEntity
import com.plantpal.data.entity.PetEntity
import com.plantpal.model.Achievement
import com.plantpal.model.GrowthStage
import com.plantpal.model.InteractionType
import com.plantpal.model.PetType
import com.plantpal.model.SpriteMood
import com.plantpal.model.SpriteEvolutionThreshold
import com.plantpal.model.WeatherType
import java.util.Calendar

class TimeEngine {

    data class CooldownState(
        val lastUsedAt: MutableMap<InteractionType, Long> = mutableMapOf()
    ) {
        fun isOnCooldown(type: InteractionType, now: Long = System.currentTimeMillis()): Boolean {
            val lastUsed = lastUsedAt[type] ?: return false
            val elapsedSec = (now - lastUsed) / 1000.0
            return elapsedSec < type.cooldownSeconds
        }

        fun remainingCooldown(type: InteractionType, now: Long = System.currentTimeMillis()): Double {
            val lastUsed = lastUsedAt[type] ?: return 0.0
            val elapsedSec = (now - lastUsed) / 1000.0
            return maxOf(0.0, type.cooldownSeconds - elapsedSec)
        }

        fun markUsed(type: InteractionType, now: Long = System.currentTimeMillis()) {
            lastUsedAt[type] = now
        }
    }

    var cooldownState = CooldownState()

    fun calculateTimeEffects(
        plant: PlantEntity, sprite: SpriteEntity,
        wallet: PlayerWalletEntity? = null, now: Long = System.currentTimeMillis()
    ): Triple<PlantEntity, SpriteEntity, PlayerWalletEntity?> {
        val elapsedMs = now - plant.lastUpdated
        val elapsedHours = elapsedMs / 3600000.0
        if (elapsedHours < 0.01) return Triple(plant, sprite, wallet)

        val isShielded = now < plant.shieldedUntil
        var p = plant

        p = updateWeather(p, now)
        val weather = p.currentWeather

        if (!isShielded) {
            p = p.copy(
                waterLevel = (p.waterLevel - p.species.waterDecayPerHour * weather.waterDecayMultiplier * elapsedHours).coerceIn(0.0, 1.0),
                lightLevel = (p.lightLevel - p.species.lightDecayPerHour * weather.lightDecayMultiplier * elapsedHours).coerceIn(0.0, 1.0)
            )
        }

        if (p.waterLevel < 0.2 && p.lightLevel < 0.2 && !isShielded) {
            p = p.copy(isSick = true)
        }

        if (p.isSick && !isShielded) {
            p = p.copy(health = (p.health - p.species.healthDecayPerHour * 2 * weather.healthDecayMultiplier * elapsedHours).coerceIn(0.0, 1.0))
        } else if (p.waterLevel < 0.3 || p.lightLevel < 0.3) {
            if (!isShielded) {
                p = p.copy(health = (p.health - p.species.healthDecayPerHour * weather.healthDecayMultiplier * elapsedHours).coerceIn(0.0, 1.0))
            }
        } else if (p.health < 1.0) {
            p = p.copy(health = (p.health + 0.01 * elapsedHours).coerceIn(0.0, 1.0))
        }

        if (p.health < 0.3 && p.growthStage != GrowthStage.WILTED) {
            p = p.withGrowthStage(GrowthStage.WILTED)
        } else if (p.growthStage == GrowthStage.WILTED && p.health >= 0.3 && p.waterLevel >= 0.3 && p.lightLevel >= 0.3) {
            p = p.withGrowthStage(GrowthStage.SPROUT)
        }

        var w = wallet
        if (p.growthStage != GrowthStage.WILTED && !p.isSick) {
            val nm = 1 + p.nutrients / 200
            val eg = p.species.baseGrowthRate * p.waterLevel * p.lightLevel * p.health * nm * p.currentWeather.growthMultiplier * elapsedHours
            p = p.copy(growthProgress = (p.growthProgress + eg).coerceIn(0.0, 1.0))
            if (p.growthProgress >= 1.0) {
                val t = p.growthStage.evolutionThreshold
                if (p.waterLevel >= t.minWater && p.lightLevel >= t.minLight && p.nutrients >= t.minNutrients) {
                    p.growthStage.nextStage?.let { next ->
                        p = p.withGrowthStage(next).copy(growthProgress = 0.0)
                    }
                }
            }
        }

        var s = sprite
        val newLevel = SpriteEvolutionThreshold.evolutionLevelFor(s.interactionCount, s.happiness, p.growthStage)
        if (newLevel > s.evolutionLevel) {
            s = s.copy(evolutionLevel = newLevel)
            w = w?.copy(coins = w.coins + 10)
        }

        s = s.copy(fatigue = maxOf(0.0, s.fatigue - 0.1 * elapsedHours))

        val hour = Calendar.getInstance().apply { timeInMillis = now }.get(Calendar.HOUR_OF_DAY)
        s = deriveSpriteMood(s, p, hour)

        val days = ((now - p.createdAt) / 86400000).toInt()
        p = p.copy(totalCareEvents = days, lastUpdated = now)

        return Triple(p, s, w)
    }

    fun applyInteraction(
        plant: PlantEntity, sprite: SpriteEntity, type: InteractionType,
        wallet: PlayerWalletEntity? = null
    ): Triple<PlantEntity, SpriteEntity, PlayerWalletEntity?> {
        val now = System.currentTimeMillis()
        if (cooldownState.isOnCooldown(type, now)) return Triple(plant, sprite, wallet)
        cooldownState.markUsed(type, now)

        var p = plant
        var s = sprite
        var w = wallet

        val fatiguePenalty = 1.0 - s.fatigue * 0.75
        val moodMultiplier = when (s.mood) {
            SpriteMood.EXCITED -> 1.25
            SpriteMood.HAPPY -> 1.0
            SpriteMood.WORRIED -> 0.8
            SpriteMood.SAD -> 0.6
            SpriteMood.SLEEPING -> 1.0
        }
        val effect = fatiguePenalty * moodMultiplier

        when (type) {
            InteractionType.WATER -> {
                p = p.copy(waterLevel = (p.waterLevel + 0.3 * effect).coerceIn(0.0, 1.0))
                w = w?.copy(coins = w.coins + 1)
            }
            InteractionType.LIGHT -> {
                p = p.copy(lightLevel = (p.lightLevel + 0.3 * effect).coerceIn(0.0, 1.0))
                w = w?.copy(coins = w.coins + 1)
            }
            InteractionType.FERTILIZE -> {
                if (p.nutrients >= 5) p = p.copy(nutrients = p.nutrients - 5, growthProgress = (p.growthProgress + 0.05 * effect).coerceIn(0.0, 1.0))
                w = w?.copy(coins = w.coins + 1)
            }
            InteractionType.TOUCH -> {
                s = s.copy(happiness = (s.happiness + 0.1 * effect).coerceIn(0.0, 1.0), interactionCount = s.interactionCount + 1)
                w = w?.copy(coins = w.coins + 2)
            }
            InteractionType.TALK -> {
                s = s.copy(happiness = (s.happiness + 0.05 * effect).coerceIn(0.0, 1.0), interactionCount = s.interactionCount + 1)
                w = w?.copy(coins = w.coins + 2)
            }
            InteractionType.SING -> {
                s = s.copy(happiness = (s.happiness + 0.15 * effect).coerceIn(0.0, 1.0), interactionCount = s.interactionCount + 2, fatigue = (s.fatigue + 0.05).coerceIn(0.0, 1.0))
                w = w?.copy(coins = w.coins + 3)
            }
            InteractionType.HEAL -> {
                if (p.isSick) { p = p.copy(isSick = false, health = (p.health + 0.4 * effect).coerceIn(0.0, 1.0)) }
                else { p = p.copy(health = (p.health + 0.1 * effect).coerceIn(0.0, 1.0)) }
                w = w?.copy(coins = w.coins + 2)
            }
            InteractionType.PLAY -> {
                s = s.copy(happiness = (s.happiness + 0.12 * effect).coerceIn(0.0, 1.0), interactionCount = s.interactionCount + 3, fatigue = (s.fatigue + 0.08).coerceIn(0.0, 1.0))
                w = w?.copy(coins = w.coins + 3)
            }
            InteractionType.SHIELD -> {
                p = p.copy(shieldedUntil = now + (3600000L * effect).toLong())
                s = s.copy(happiness = (s.happiness + 0.05 * effect).coerceIn(0.0, 1.0))
                w = w?.copy(coins = w.coins + 4)
            }
            InteractionType.DANCE -> {
                s = s.copy(happiness = (s.happiness + 0.2 * effect).coerceIn(0.0, 1.0), interactionCount = s.interactionCount + 2, fatigue = (s.fatigue + 0.06).coerceIn(0.0, 1.0))
                p = p.copy(growthProgress = (p.growthProgress + 0.02 * effect).coerceIn(0.0, 1.0))
                w = w?.copy(coins = w.coins + 4)
            }
            InteractionType.PET -> {
                s = s.copy(happiness = (s.happiness + 0.08).coerceIn(0.0, 1.0), fatigue = maxOf(0.0, s.fatigue - 0.1), interactionCount = s.interactionCount + 1)
                w = w?.copy(coins = w.coins + 2)
            }
        }

        s = s.copy(lastInteractionTime = now)
        val hour = Calendar.getInstance().apply { timeInMillis = now }.get(Calendar.HOUR_OF_DAY)
        s = deriveSpriteMood(s, p, hour)

        return Triple(p, s, w)
    }

    private fun deriveSpriteMood(sprite: SpriteEntity, plant: PlantEntity, hour: Int): SpriteEntity {
        val mood = when {
            hour >= 22 || hour < 7 -> SpriteMood.SLEEPING
            sprite.fatigue > 0.8 -> SpriteMood.WORRIED
            plant.isSick || plant.health < 0.3 || plant.growthStage == GrowthStage.WILTED -> SpriteMood.SAD
            plant.health < 0.5 || plant.waterLevel < 0.3 || plant.lightLevel < 0.3 -> SpriteMood.WORRIED
            sprite.happiness > 0.8 -> SpriteMood.EXCITED
            else -> SpriteMood.HAPPY
        }
        return sprite.withMood(mood)
    }

    private fun updateWeather(plant: PlantEntity, now: Long): PlantEntity {
        val hoursSinceChange = (now - plant.lastWeatherChangeAt) / 3600000.0
        if (hoursSinceChange >= 2.0 + Math.random() * 2.0) {
            val newWeather = WeatherType.randomWeather(excluding = plant.currentWeather)
            return plant.copy(currentWeatherRaw = newWeather.name, lastWeatherChangeAt = now)
        }
        return plant
    }

    fun checkAchievements(
        plant: PlantEntity, sprite: SpriteEntity, wallet: PlayerWalletEntity?,
        achievementRecords: List<AchievementEntity>, pets: List<PetEntity>,
        interactionCounts: Map<InteractionType, Int>
    ): List<Achievement> {
        val unlocked = achievementRecords.filter { it.isUnlocked }.map { it.achievementIdRaw }.toSet()
        val newlyUnlocked = mutableListOf<Achievement>()
        fun check(a: Achievement) { if (!unlocked.contains(a.name)) newlyUnlocked.add(a) }
        if ((interactionCounts[InteractionType.WATER] ?: 0) > 0) check(Achievement.FIRST_WATER)
        if ((interactionCounts[InteractionType.WATER] ?: 0) >= 100) check(Achievement.GREEN_THUMB)
        if ((interactionCounts[InteractionType.LIGHT] ?: 0) >= 100) check(Achievement.SUNSHINE_LOVER)
        if (sprite.interactionCount >= 500) check(Achievement.PLANT_WHISPERER)
        if ((wallet?.coins ?: 0) >= 1000) check(Achievement.RICH_GARDENER)
        if (plant.growthStage == GrowthStage.FRUIT) check(Achievement.PLANT_MASTER)
        if ((interactionCounts[InteractionType.HEAL] ?: 0) >= 10) check(Achievement.HEALER)
        if ((interactionCounts[InteractionType.SHIELD] ?: 0) >= 10) check(Achievement.PROTECTOR)
        if ((interactionCounts[InteractionType.DANCE] ?: 0) >= 50) check(Achievement.DANCER)
        if ((interactionCounts[InteractionType.SING] ?: 0) >= 50) check(Achievement.SINGER)
        if (interactionCounts.size >= 11) check(Achievement.EXPLORER)
        if (pets.count { it.isOwned } >= PetType.entries.size) check(Achievement.PET_LOVER)
        val nonLegendary = Achievement.entries.filter { it != Achievement.LEGENDARY }
        if (nonLegendary.all { unlocked.contains(it.name) || newlyUnlocked.contains(it) }) check(Achievement.LEGENDARY)
        return newlyUnlocked
    }

    fun checkDailyLogin(login: DailyLoginEntity, wallet: PlayerWalletEntity, now: Long = System.currentTimeMillis()): Int {
        val cal = Calendar.getInstance()
        cal.timeInMillis = now
        cal.set(Calendar.HOUR_OF_DAY, 0)
        cal.set(Calendar.MINUTE, 0)
        cal.set(Calendar.SECOND, 0)
        cal.set(Calendar.MILLISECOND, 0)
        val todayStart = cal.timeInMillis
        if (login.lastLoginDate >= todayStart) return 0
        val calYesterday = Calendar.getInstance()
        calYesterday.add(Calendar.DAY_OF_YEAR, -1)
        calYesterday.set(Calendar.HOUR_OF_DAY, 0)
        calYesterday.set(Calendar.MINUTE, 0)
        calYesterday.set(Calendar.SECOND, 0)
        calYesterday.set(Calendar.MILLISECOND, 0)
        val isYesterday = login.lastLoginDate >= calYesterday.timeInMillis
        val consecutiveDays = if (isYesterday) login.consecutiveDays + 1 else 1
        val reward = when {
            consecutiveDays >= 30 -> 200
            consecutiveDays == 7 -> 50
            consecutiveDays >= 2 -> 10
            else -> 5
        }
        return reward
    }
}