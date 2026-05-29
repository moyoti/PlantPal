package com.plantpal.data.entity

import androidx.room.ColumnInfo
import androidx.room.Entity
import androidx.room.PrimaryKey
import com.plantpal.model.GrowthStage
import com.plantpal.model.PlantSpecies
import com.plantpal.model.WeatherType
import java.util.UUID

@Entity(tableName = "plants")
data class PlantEntity(
    @PrimaryKey
    val id: String = UUID.randomUUID().toString(),
    val name: String = "小绿",
    @ColumnInfo(name = "speciesRaw", defaultValue = "FLOWER")
    val speciesRaw: String = PlantSpecies.FLOWER.name,
    @ColumnInfo(name = "growthStageRaw", defaultValue = "SEED")
    val growthStageRaw: String = GrowthStage.SEED.name,
    val waterLevel: Double = 1.0,
    val lightLevel: Double = 1.0,
    val health: Double = 1.0,
    val nutrients: Double = 0.0,
    val growthProgress: Double = 0.0,
    val potStyle: String = "default",
    val backgroundScene: String = "garden",
    @ColumnInfo(defaultValue = "0")
    val isSick: Boolean = false,
    @ColumnInfo(defaultValue = "0")
    val shieldedUntil: Long = 0L,
    @ColumnInfo(defaultValue = "SUNNY")
    val currentWeatherRaw: String = "SUNNY",
    @ColumnInfo(defaultValue = "0")
    val lastWeatherChangeAt: Long = System.currentTimeMillis(),
    @ColumnInfo(name = "totalCareEvents", defaultValue = "0")
    val totalCareEvents: Int = 0,
    val createdAt: Long = System.currentTimeMillis(),
    @ColumnInfo(name = "lastUpdated")
    val lastUpdated: Long = System.currentTimeMillis()
) {
    val species: PlantSpecies
        get() = try { PlantSpecies.valueOf(speciesRaw) } catch (_: Exception) { PlantSpecies.FLOWER }

    val growthStage: GrowthStage
        get() = try { GrowthStage.valueOf(growthStageRaw) } catch (_: Exception) { GrowthStage.SEED }

    val currentWeather: WeatherType
        get() = try { WeatherType.valueOf(currentWeatherRaw) } catch (_: Exception) { WeatherType.SUNNY }

    fun withSpecies(species: PlantSpecies): PlantEntity = copy(speciesRaw = species.name)
    fun withGrowthStage(stage: GrowthStage): PlantEntity = copy(growthStageRaw = stage.name)

    companion object {
        fun create(
            name: String = "小绿",
            species: PlantSpecies = PlantSpecies.FLOWER,
            growthStage: GrowthStage = GrowthStage.SEED
        ): PlantEntity = PlantEntity(
            name = name,
            speciesRaw = species.name,
            growthStageRaw = growthStage.name
        )
    }
}