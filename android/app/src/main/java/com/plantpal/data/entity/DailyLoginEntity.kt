package com.plantpal.data.entity

import androidx.room.Entity
import androidx.room.PrimaryKey
import java.util.UUID

@Entity(tableName = "daily_logins")
data class DailyLoginEntity(
    @PrimaryKey val id: String = UUID.randomUUID().toString(),
    val lastLoginDate: Long = System.currentTimeMillis(),
    val consecutiveDays: Int = 0,
    val totalLogins: Int = 0,
    val lastRewardClaimed: Long = 0L
)
