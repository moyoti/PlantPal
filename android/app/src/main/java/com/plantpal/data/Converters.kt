package com.plantpal.data

import androidx.room.TypeConverter
import com.plantpal.model.PlantSpecies
import com.plantpal.model.GrowthStage
import com.plantpal.model.SpriteMood
import com.plantpal.model.InteractionType
import com.plantpal.model.PetType

class Converters {
    @TypeConverter
    fun fromPlantSpecies(value: PlantSpecies): String = value.name

    @TypeConverter
    fun toPlantSpecies(value: String): PlantSpecies = try { PlantSpecies.valueOf(value) } catch (_: Exception) { PlantSpecies.SUCCULENT }

    @TypeConverter
    fun fromGrowthStage(value: GrowthStage): String = value.name

    @TypeConverter
    fun toGrowthStage(value: String): GrowthStage = try { GrowthStage.valueOf(value) } catch (_: Exception) { GrowthStage.SEED }

    @TypeConverter
    fun fromSpriteMood(value: SpriteMood): String = value.name

    @TypeConverter
    fun toSpriteMood(value: String): SpriteMood = try { SpriteMood.valueOf(value) } catch (_: Exception) { SpriteMood.HAPPY }

    @TypeConverter
    fun fromInteractionType(value: InteractionType): String = value.name

    @TypeConverter
    fun toInteractionType(value: String): InteractionType = try { InteractionType.valueOf(value) } catch (_: Exception) { InteractionType.WATER }

    @TypeConverter
    fun fromPetType(value: PetType): String = value.name

    @TypeConverter
    fun toPetType(value: String): PetType = try { PetType.valueOf(value) } catch (_: Exception) { PetType.CAT_SPRITE }
}