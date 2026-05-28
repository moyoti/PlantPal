package com.plantpal.data.entity

import androidx.room.ColumnInfo
import androidx.room.Entity
import androidx.room.PrimaryKey
import java.util.UUID

@Entity(tableName = "wallets")
data class PlayerWalletEntity(
    @PrimaryKey
    val id: String = UUID.randomUUID().toString(),
    @ColumnInfo(defaultValue = "0")
    val coins: Int = 0
) {
    companion object {
        fun create(): PlayerWalletEntity = PlayerWalletEntity()
    }
}