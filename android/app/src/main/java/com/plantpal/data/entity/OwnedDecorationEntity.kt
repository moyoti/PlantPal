package com.plantpal.data.entity

import androidx.room.ColumnInfo
import androidx.room.Entity
import androidx.room.PrimaryKey
import java.util.UUID

@Entity(tableName = "owned_decorations")
data class OwnedDecorationEntity(
    @PrimaryKey
    val id: String = UUID.randomUUID().toString(),
    @ColumnInfo(name = "itemId")
    val itemId: String,
    @ColumnInfo(defaultValue = "0")
    val purchasedAt: Long = System.currentTimeMillis()
)
