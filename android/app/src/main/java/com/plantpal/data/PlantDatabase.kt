package com.plantpal.data

import androidx.room.Database
import androidx.room.RoomDatabase
import androidx.room.TypeConverters
import androidx.room.migration.Migration
import androidx.sqlite.db.SupportSQLiteDatabase
import com.plantpal.data.dao.PlantDao
import com.plantpal.data.dao.SpriteDao
import com.plantpal.data.dao.HabitTaskDao
import com.plantpal.data.dao.InteractionDao
import com.plantpal.data.dao.PlayerWalletDao
import com.plantpal.data.dao.PetDao
import com.plantpal.data.dao.AchievementDao
import com.plantpal.data.dao.DailyLoginDao
import com.plantpal.data.entity.PlantEntity
import com.plantpal.data.entity.SpriteEntity
import com.plantpal.data.entity.HabitTaskEntity
import com.plantpal.data.entity.InteractionEntity
import com.plantpal.data.entity.PlayerWalletEntity
import com.plantpal.data.entity.PetEntity
import com.plantpal.data.entity.AchievementEntity
import com.plantpal.data.entity.DailyLoginEntity

@Database(
    entities = [
        PlantEntity::class,
        SpriteEntity::class,
        HabitTaskEntity::class,
        InteractionEntity::class,
        PlayerWalletEntity::class,
        PetEntity::class,
        AchievementEntity::class,
        DailyLoginEntity::class
    ],
    version = 3,
    exportSchema = false
)
@TypeConverters(Converters::class)
abstract class PlantDatabase : RoomDatabase() {
    abstract fun plantDao(): PlantDao
    abstract fun spriteDao(): SpriteDao
    abstract fun habitTaskDao(): HabitTaskDao
    abstract fun interactionDao(): InteractionDao
    abstract fun walletDao(): PlayerWalletDao
    abstract fun petDao(): PetDao
    abstract fun achievementDao(): AchievementDao
    abstract fun dailyLoginDao(): DailyLoginDao

    companion object {
        val MIGRATION_2_3 = object : Migration(2, 3) {
            override fun migrate(db: SupportSQLiteDatabase) {
                db.execSQL("CREATE TABLE IF NOT EXISTS `achievements` (`id` TEXT NOT NULL, `achievementIdRaw` TEXT NOT NULL, `unlockedAt` INTEGER NOT NULL, `isUnlocked` INTEGER NOT NULL DEFAULT 0, PRIMARY KEY(`id`))")
                db.execSQL("CREATE TABLE IF NOT EXISTS `daily_logins` (`id` TEXT NOT NULL, `lastLoginDate` INTEGER NOT NULL, `consecutiveDays` INTEGER NOT NULL, `totalLogins` INTEGER NOT NULL, `lastRewardClaimed` INTEGER NOT NULL, PRIMARY KEY(`id`))")
            }
        }
    }
}