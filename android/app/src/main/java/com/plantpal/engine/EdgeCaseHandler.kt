package com.plantpal.engine

import com.plantpal.data.entity.PlantEntity
import com.plantpal.data.entity.SpriteEntity

object EdgeCaseHandler {

    fun handleLongAbsence(plant: PlantEntity, now: Long = System.currentTimeMillis()): PlantEntity {
        val elapsedHours = (now - plant.lastUpdated) / 3600000.0
        return if (elapsedHours > 72) {
            plant.copy(lastUpdated = now - minOf(elapsedHours, 48.0).toLong() * 3600000)
        } else {
            plant
        }
    }

    fun clampAllValues(plant: PlantEntity): PlantEntity {
        return plant.copy(
            health = plant.health.coerceIn(0.0, 1.0),
            waterLevel = plant.waterLevel.coerceIn(0.0, 1.0),
            lightLevel = plant.lightLevel.coerceIn(0.0, 1.0),
            growthProgress = plant.growthProgress.coerceIn(0.0, 1.0),
            nutrients = maxOf(0.0, plant.nutrients)
        )
    }

    fun handleSpriteRecovery(sprite: SpriteEntity): SpriteEntity {
        return if (sprite.happiness < 0.1) {
            sprite.copy(happiness = 0.1)
        } else {
            sprite
        }
    }

    fun handleNewPlantCreation(): PlantEntity {
        return PlantEntity.create()
    }
}