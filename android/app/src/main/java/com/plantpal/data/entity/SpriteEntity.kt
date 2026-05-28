package com.plantpal.data.entity

import androidx.room.ColumnInfo
import androidx.room.Entity
import androidx.room.PrimaryKey
import com.plantpal.model.SpriteMood
import java.util.UUID

@Entity(tableName = "sprites")
data class SpriteEntity(
    @PrimaryKey
    val id: String = UUID.randomUUID().toString(),
    val plantId: String = "",
    @ColumnInfo(defaultValue = "小精灵")
    val name: String = "小精灵",
    @ColumnInfo(name = "moodRaw", defaultValue = "HAPPY")
    val moodRaw: String = SpriteMood.HAPPY.name,
    @ColumnInfo(defaultValue = "1")
    val evolutionLevel: Int = 1,
    @ColumnInfo(defaultValue = "0.5")
    val happiness: Double = 0.5,
    @ColumnInfo(defaultValue = "default")
    val outfit: String = "default",
    @ColumnInfo(defaultValue = "0")
    val interactionCount: Int = 0,
    @ColumnInfo(defaultValue = "0.0")
    val fatigue: Double = 0.0,
    val lastInteractionTime: Long = System.currentTimeMillis()
) {
    val mood: SpriteMood
        get() = try { SpriteMood.valueOf(moodRaw) } catch (_: Exception) { SpriteMood.HAPPY }

    fun withMood(mood: SpriteMood): SpriteEntity = copy(moodRaw = mood.name)

    companion object {
        fun create(
            plantId: String = "",
            name: String = "小精灵",
            mood: SpriteMood = SpriteMood.HAPPY,
            evolutionLevel: Int = 1
        ): SpriteEntity = SpriteEntity(
            plantId = plantId,
            name = name,
            moodRaw = mood.name,
            evolutionLevel = evolutionLevel
        )
    }
}