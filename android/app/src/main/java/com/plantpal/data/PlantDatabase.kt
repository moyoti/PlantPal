package com.plantpal.data

import androidx.room.Database
import androidx.room.RoomDatabase
import androidx.room.TypeConverters
import com.plantpal.data.dao.PlantDao
import com.plantpal.data.dao.SpriteDao
import com.plantpal.data.dao.HabitTaskDao
import com.plantpal.data.dao.InteractionDao
import com.plantpal.data.dao.PlayerWalletDao
import com.plantpal.data.entity.PlantEntity
import com.plantpal.data.entity.SpriteEntity
import com.plantpal.data.entity.HabitTaskEntity
import com.plantpal.data.entity.InteractionEntity
import com.plantpal.data.entity.PlayerWalletEntity

@Database(
    entities = [
        PlantEntity::class,
        SpriteEntity::class,
        HabitTaskEntity::class,
        InteractionEntity::class,
        PlayerWalletEntity::class
    ],
    version = 2,
    exportSchema = false
)
@TypeConverters(Converters::class)
abstract class PlantDatabase : RoomDatabase() {
    abstract fun plantDao(): PlantDao
    abstract fun spriteDao(): SpriteDao
    abstract fun habitTaskDao(): HabitTaskDao
    abstract fun interactionDao(): InteractionDao
    abstract fun walletDao(): PlayerWalletDao
}