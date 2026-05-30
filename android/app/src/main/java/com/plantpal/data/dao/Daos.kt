package com.plantpal.data.dao

import androidx.room.*
import com.plantpal.data.entity.PlantEntity
import com.plantpal.data.entity.SpriteEntity
import com.plantpal.data.entity.InteractionEntity
import com.plantpal.data.entity.PlayerWalletEntity
import com.plantpal.data.entity.PetEntity
import com.plantpal.data.entity.AchievementEntity
import com.plantpal.data.entity.DailyLoginEntity
import com.plantpal.data.entity.OwnedDecorationEntity

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

@Dao
interface PetDao {
    @Query("SELECT * FROM pets")
    fun getAllPetsFlow(): kotlinx.coroutines.flow.Flow<List<PetEntity>>

    @Query("SELECT * FROM pets WHERE isOwned = 1")
    fun getOwnedPetsFlow(): kotlinx.coroutines.flow.Flow<List<PetEntity>>

    @Insert(onConflict = OnConflictStrategy.REPLACE)
    suspend fun insert(pet: PetEntity)

    @Update
    suspend fun update(pet: PetEntity)

    @Delete
    suspend fun delete(pet: PetEntity)

    @Query("DELETE FROM pets")
    suspend fun deleteAll()
}

@Dao
interface AchievementDao {
    @Query("SELECT * FROM achievements WHERE achievementIdRaw = :achievementIdRaw LIMIT 1")
    suspend fun getByAchievementId(achievementIdRaw: String): AchievementEntity?

    @Query("SELECT * FROM achievements")
    fun getAllAchievementsFlow(): kotlinx.coroutines.flow.Flow<List<AchievementEntity>>

    @Insert(onConflict = OnConflictStrategy.REPLACE)
    suspend fun insert(achievement: AchievementEntity)

    @Update
    suspend fun update(achievement: AchievementEntity)

    @Query("DELETE FROM achievements")
    suspend fun deleteAll()
}

@Dao
interface DailyLoginDao {
    @Query("SELECT * FROM daily_logins LIMIT 1")
    suspend fun getDailyLogin(): DailyLoginEntity?

    @Query("SELECT * FROM daily_logins")
    fun getDailyLoginFlow(): kotlinx.coroutines.flow.Flow<DailyLoginEntity?>

    @Insert(onConflict = OnConflictStrategy.REPLACE)
    suspend fun insert(dailyLogin: DailyLoginEntity)

    @Update
    suspend fun update(dailyLogin: DailyLoginEntity)
}

@Dao
interface OwnedDecorationDao {
    @Query("SELECT * FROM owned_decorations")
    fun getAllFlow(): kotlinx.coroutines.flow.Flow<List<OwnedDecorationEntity>>

    @Insert(onConflict = OnConflictStrategy.REPLACE)
    suspend fun insert(entity: OwnedDecorationEntity)

    @Query("DELETE FROM owned_decorations")
    suspend fun deleteAll()
}