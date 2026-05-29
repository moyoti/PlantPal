package com.plantpal.data.entity

import androidx.room.ColumnInfo
import androidx.room.Entity
import androidx.room.PrimaryKey
import com.plantpal.model.PetType
import java.util.UUID

@Entity(tableName = "pets")
data class PetEntity(
    @PrimaryKey
    val id: String = UUID.randomUUID().toString(),
    val name: String = "",
    @ColumnInfo(name = "petTypeRaw", defaultValue = "CAT_SPRITE")
    val petTypeRaw: String = PetType.CAT_SPRITE.name,
    @ColumnInfo(defaultValue = "0")
    val isOwned: Boolean = false,
    @ColumnInfo(defaultValue = "0.0")
    val friendshipLevel: Double = 0.0,
    @ColumnInfo(defaultValue = "0")
    val lastFedAt: Long = 0L,
    @ColumnInfo(defaultValue = "0")
    val lastPlayedAt: Long = 0L
) {
    val petType: PetType
        get() = try { PetType.valueOf(petTypeRaw) } catch (_: Exception) { PetType.CAT_SPRITE }

    fun withPetType(type: PetType): PetEntity = copy(petTypeRaw = type.name)
}
