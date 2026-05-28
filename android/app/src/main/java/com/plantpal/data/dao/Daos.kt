package com.plantpal.data.dao

import androidx.room.*
import com.plantpal.data.entity.PlantEntity
import com.plantpal.data.entity.SpriteEntity
import com.plantpal.data.entity.HabitTaskEntity
import com.plantpal.data.entity.InteractionEntity
import com.plantpal.data.entity.PlayerWalletEntity

@Dao
interface PlantDao {
    @Query("SELECT * FROM plants LIMIT 1")
    suspend fun getPlant(): PlantEntity?

    @Query("SELECT * FROM plants")
    fun getPlantFlow(): kotlinx.coroutines.flow.Flow<PlantEntity?>

    @Insert(onConflict = OnConflictStrategy.REPLACE)
    suspend fun insert(plant: PlantEntity)

    @Update
    suspend fun update(plant: PlantEntity)

    @Query("DELETE FROM plants")
    suspend fun deleteAll()
}

@Dao
interface SpriteDao {
    @Query("SELECT * FROM sprites LIMIT 1")
    suspend fun getSprite(): SpriteEntity?

    @Query("SELECT * FROM sprites")
    fun getSpriteFlow(): kotlinx.coroutines.flow.Flow<SpriteEntity?>

    @Insert(onConflict = OnConflictStrategy.REPLACE)
    suspend fun insert(sprite: SpriteEntity)

    @Update
    suspend fun update(sprite: SpriteEntity)

    @Query("DELETE FROM sprites")
    suspend fun deleteAll()
}

@Dao
interface HabitTaskDao {
    @Query("SELECT * FROM habit_tasks ORDER BY createdAt DESC")
    fun getAllTasksFlow(): kotlinx.coroutines.flow.Flow<List<HabitTaskEntity>>

    @Insert(onConflict = OnConflictStrategy.REPLACE)
    suspend fun insert(task: HabitTaskEntity)

    @Update
    suspend fun update(task: HabitTaskEntity)

    @Delete
    suspend fun delete(task: HabitTaskEntity)

    @Query("DELETE FROM habit_tasks")
    suspend fun deleteAll()
}

@Dao
interface InteractionDao {
    @Query("SELECT * FROM interactions WHERE plantId = :plantId ORDER BY timestamp DESC")
    suspend fun getInteractionsForPlant(plantId: String): List<InteractionEntity>

    @Insert
    suspend fun insert(interaction: InteractionEntity)

    @Query("DELETE FROM interactions")
    suspend fun deleteAll()
}

@Dao
interface PlayerWalletDao {
    @Query("SELECT * FROM wallets LIMIT 1")
    suspend fun getWallet(): PlayerWalletEntity?

    @Query("SELECT * FROM wallets")
    fun getWalletFlow(): kotlinx.coroutines.flow.Flow<PlayerWalletEntity?>

    @Insert(onConflict = OnConflictStrategy.REPLACE)
    suspend fun insert(wallet: PlayerWalletEntity)

    @Update
    suspend fun update(wallet: PlayerWalletEntity)
}