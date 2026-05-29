package com.plantpal.data.entity

import androidx.room.ColumnInfo
import androidx.room.Entity
import androidx.room.PrimaryKey
import java.util.UUID

@Entity(tableName = "achievements")
data class AchievementEntity(
    @PrimaryKey val id: String = UUID.randomUUID().toString(),
    val achievementIdRaw: String = "FIRST_WATER",
    val unlockedAt: Long = System.currentTimeMillis(),
    @ColumnInfo(defaultValue = "0") val isUnlocked: Boolean = false
)
