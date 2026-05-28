package com.plantpal.data.entity

import androidx.room.ColumnInfo
import androidx.room.Entity
import androidx.room.PrimaryKey
import com.plantpal.model.InteractionType
import java.util.UUID

@Entity(tableName = "interactions")
data class InteractionEntity(
    @PrimaryKey
    val id: String = UUID.randomUUID().toString(),
    val plantId: String = "",
    @ColumnInfo(name = "typeRaw")
    val typeRaw: String = InteractionType.WATER.name,
    val timestamp: Long = System.currentTimeMillis(),
    @ColumnInfo(defaultValue = "0.3")
    val effectiveness: Double = 0.3
) {
    val type: InteractionType
        get() = try { InteractionType.valueOf(typeRaw) } catch (_: Exception) { InteractionType.WATER }

    fun withType(type: InteractionType): InteractionEntity = copy(typeRaw = type.name)

    companion object {
        fun create(
            plantId: String,
            type: InteractionType,
            timestamp: Long = System.currentTimeMillis(),
            effectiveness: Double = 0.3
        ): InteractionEntity = InteractionEntity(
            plantId = plantId,
            typeRaw = type.name,
            timestamp = timestamp,
            effectiveness = effectiveness
        )
    }
}