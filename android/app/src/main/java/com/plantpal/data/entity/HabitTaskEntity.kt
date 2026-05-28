package com.plantpal.data.entity

import androidx.room.ColumnInfo
import androidx.room.Entity
import androidx.room.PrimaryKey
import com.plantpal.model.TaskFrequency
import java.util.UUID

@Entity(tableName = "habit_tasks")
data class HabitTaskEntity(
    @PrimaryKey
    val id: String = UUID.randomUUID().toString(),
    val title: String = "",
    @ColumnInfo(defaultValue = "💧")
    val iconEmoji: String = "💧",
    @ColumnInfo(name = "frequencyRaw", defaultValue = "DAILY")
    val frequencyRaw: String = TaskFrequency.DAILY.name,
    @ColumnInfo(defaultValue = "2.0")
    val nutrientReward: Double = 2.0,
    @ColumnInfo(defaultValue = "1.0")
    val sunlightReward: Double = 1.0,
    @ColumnInfo(name = "isCompletedToday", defaultValue = "0")
    val isCompletedToday: Boolean = false,
    @ColumnInfo(defaultValue = "0")
    val streakCount: Int = 0,
    @ColumnInfo(name = "lastCompletedAt")
    val lastCompletedAt: Long? = null,
    val createdAt: Long = System.currentTimeMillis()
) {
    val frequency: TaskFrequency
        get() = try { TaskFrequency.valueOf(frequencyRaw) } catch (_: Exception) { TaskFrequency.DAILY }

    fun withFrequency(frequency: TaskFrequency): HabitTaskEntity = copy(frequencyRaw = frequency.name)

    companion object {
        fun create(
            title: String,
            iconEmoji: String = "💧",
            frequency: TaskFrequency = TaskFrequency.DAILY,
            nutrientReward: Double = 2.0,
            sunlightReward: Double = 1.0
        ): HabitTaskEntity = HabitTaskEntity(
            title = title,
            iconEmoji = iconEmoji,
            frequencyRaw = frequency.name,
            nutrientReward = nutrientReward,
            sunlightReward = sunlightReward
        )
    }
}