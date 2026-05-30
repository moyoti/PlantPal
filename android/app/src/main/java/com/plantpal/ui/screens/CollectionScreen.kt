package com.plantpal.ui.screens

import androidx.compose.foundation.layout.*
import androidx.compose.foundation.lazy.LazyColumn
import androidx.compose.foundation.lazy.items
import androidx.compose.material3.*
import androidx.compose.runtime.*
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.text.style.TextAlign
import androidx.compose.ui.text.style.TextOverflow
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import com.plantpal.data.entity.AchievementEntity
import com.plantpal.data.entity.PetEntity
import com.plantpal.data.entity.PlantEntity
import com.plantpal.data.entity.PlayerWalletEntity
import com.plantpal.data.entity.SpriteEntity
import com.plantpal.model.Achievement
import com.plantpal.model.PetType
import androidx.compose.foundation.clickable
import androidx.compose.foundation.interaction.MutableInteractionSource

@Composable
fun CollectionScreen(
    plant: PlantEntity?,
    sprite: SpriteEntity?,
    wallet: PlayerWalletEntity?,
    pets: List<PetEntity>,
    achievements: List<AchievementEntity>,
    onPurchasePet: (PetType) -> Unit,
    onNavigateToDecorationStore: () -> Unit = {}
) {
    if (plant == null || sprite == null) return

    val ownedPetTypes = remember(pets) { pets.filter { it.isOwned }.map { it.petTypeRaw }.toSet() }
    val unlockedAchievementIds = remember(achievements) { achievements.filter { it.isUnlocked }.map { it.achievementIdRaw }.toSet() }
    val achievementList = Achievement.entries
    val petTypeList = PetType.entries

    LazyColumn(
        modifier = Modifier.fillMaxSize().padding(horizontal = 16.dp),
        verticalArrangement = Arrangement.spacedBy(12.dp),
        contentPadding = PaddingValues(vertical = 16.dp)
    ) {
        item {
            Text("当前植物", style = MaterialTheme.typography.titleMedium)
            Spacer(Modifier.height(8.dp))
            Card(modifier = Modifier.fillMaxWidth()) {
                Row(modifier = Modifier.padding(16.dp), verticalAlignment = Alignment.CenterVertically) {
                    Text("🌱", fontSize = 32.sp)
                    Spacer(Modifier.width(12.dp))
                    Column {
                        Text(plant.name, fontWeight = FontWeight.Medium)
                        Text("存活 ${plant.totalCareEvents} 天", fontSize = 12.sp, color = MaterialTheme.colorScheme.onSurfaceVariant)
                    }
                }
            }
        }

        item {
            Text("精灵进化", style = MaterialTheme.typography.titleMedium)
            Spacer(Modifier.height(8.dp))
            val evolutionNames = listOf("种子精灵", "嫩芽仙女", "花蕾精灵", "花仙子", "果实女王")
            evolutionNames.forEachIndexed { index, name ->
                val level = index + 1
                val unlocked = level <= sprite.evolutionLevel
                Card(modifier = Modifier.fillMaxWidth().padding(vertical = 2.dp)) {
                    Row(modifier = Modifier.padding(12.dp), verticalAlignment = Alignment.CenterVertically) {
                        Text(if (unlocked) "✨" else "🔒", fontSize = 24.sp)
                        Spacer(Modifier.width(12.dp))
                        Text(name, color = if (unlocked) MaterialTheme.colorScheme.onSurface else MaterialTheme.colorScheme.onSurfaceVariant)
                    }
                }
            }
        }

        item {
            Text("宠物商店", style = MaterialTheme.typography.titleMedium)
            Spacer(Modifier.height(4.dp))
            Row(verticalAlignment = Alignment.CenterVertically) {
                Text("🪙", fontSize = 14.sp)
                Spacer(Modifier.width(4.dp))
                Text(
                    "¥${wallet?.coins ?: 0}",
                    fontSize = 14.sp,
                    fontWeight = FontWeight.Bold,
                    color = MaterialTheme.colorScheme.primary
                )
                Spacer(Modifier.weight(1f))
            }
            Spacer(Modifier.height(8.dp))
            Row(
                modifier = Modifier.fillMaxWidth(),
                horizontalArrangement = Arrangement.spacedBy(8.dp)
            ) {
                petTypeList.forEach { petType ->
                    Box(modifier = Modifier.weight(1f)) {
                        PetShopCard(
                            petType = petType,
                            isOwned = ownedPetTypes.contains(petType.name),
                            canAfford = (wallet?.coins ?: 0) >= petType.unlockCost,
                            onPurchase = { onPurchasePet(petType) }
                        )
                    }
                }
            }
        }

        item {
            val unlockedCount = achievementList.count { unlockedAchievementIds.contains(it.name) }
            Text("成就", style = MaterialTheme.typography.titleMedium)
            Spacer(Modifier.height(4.dp))
            Text(
                "${unlockedCount}/${achievementList.size}",
                fontSize = 13.sp,
                color = MaterialTheme.colorScheme.onSurfaceVariant
            )
            Spacer(Modifier.height(8.dp))
        }

        items(achievementList) { achievement ->
            val isUnlocked = unlockedAchievementIds.contains(achievement.name)
            Card(
                modifier = Modifier.fillMaxWidth(),
                colors = CardDefaults.cardColors(
                    containerColor = if (isUnlocked) MaterialTheme.colorScheme.surfaceVariant
                    else MaterialTheme.colorScheme.surface.copy(alpha = 0.6f)
                )
            ) {
                Row(
                    modifier = Modifier.padding(12.dp),
                    verticalAlignment = Alignment.CenterVertically
                ) {
                    Text(achievement.iconEmoji, fontSize = 24.sp)
                    Spacer(Modifier.width(12.dp))
                    Column(modifier = Modifier.weight(1f)) {
                        Text(
                            achievement.displayName,
                            fontWeight = FontWeight.Medium,
                            color = if (isUnlocked) MaterialTheme.colorScheme.onSurface
                            else MaterialTheme.colorScheme.onSurfaceVariant
                        )
                        Text(
                            achievement.description,
                            fontSize = 12.sp,
                            maxLines = 1,
                            overflow = TextOverflow.Ellipsis,
                            color = MaterialTheme.colorScheme.onSurfaceVariant
                        )
                    }
                    Text(if (isUnlocked) "✅" else "🔒", fontSize = 16.sp)
                }
            }
        }

        item {
            Spacer(Modifier.height(8.dp))
            Text("装饰", style = MaterialTheme.typography.titleMedium)
            Spacer(Modifier.height(8.dp))
            Card(
                modifier = Modifier.fillMaxWidth().clickable(
                    interactionSource = remember { MutableInteractionSource() },
                    indication = null,
                    onClick = onNavigateToDecorationStore
                )
            ) {
                Row(
                    modifier = Modifier.padding(16.dp),
                    verticalAlignment = Alignment.CenterVertically
                ) {
                    Text("🏪", fontSize = 20.sp)
                    Spacer(Modifier.width(12.dp))
                    Text("前往装饰商店", fontWeight = FontWeight.Medium)
                    Spacer(Modifier.weight(1f))
                    Text("›", fontSize = 18.sp, color = MaterialTheme.colorScheme.onSurfaceVariant)
                }
            }
        }
    }
}

@Composable
private fun PetShopCard(
    petType: PetType,
    isOwned: Boolean,
    canAfford: Boolean,
    onPurchase: () -> Unit
) {
    Card(
        modifier = Modifier.fillMaxWidth(),
        colors = CardDefaults.cardColors(
            containerColor = if (isOwned) MaterialTheme.colorScheme.primaryContainer
            else MaterialTheme.colorScheme.surfaceVariant
        )
    ) {
        Column(
            modifier = Modifier.padding(8.dp),
            horizontalAlignment = Alignment.CenterHorizontally
        ) {
            Text(
                when (petType) {
                    PetType.CAT_SPRITE -> "🐱"
                    PetType.DOG_SPRITE -> "🐶"
                    PetType.BIRD_SPRITE -> "🐦"
                    PetType.FISH_SPRITE -> "🐟"
                    PetType.BUNNY_SPRITE -> "🐰"
                },
                fontSize = 28.sp
            )
            Spacer(Modifier.height(2.dp))
            Text(
                petType.displayName,
                fontSize = 12.sp,
                fontWeight = FontWeight.Medium,
                textAlign = TextAlign.Center
            )
            Text(
                petType.abilities,
                fontSize = 9.sp,
                maxLines = 2,
                overflow = TextOverflow.Ellipsis,
                textAlign = TextAlign.Center,
                color = MaterialTheme.colorScheme.onSurfaceVariant,
                lineHeight = 12.sp
            )
            Spacer(Modifier.height(4.dp))
            if (isOwned) {
                Text(
                    "已拥有",
                    fontSize = 11.sp,
                    fontWeight = FontWeight.Bold,
                    color = MaterialTheme.colorScheme.primary
                )
            } else {
                Row(verticalAlignment = Alignment.CenterVertically) {
                    Text("🪙", fontSize = 10.sp)
                    Spacer(Modifier.width(2.dp))
                    Text(
                        "${petType.unlockCost}",
                        fontSize = 11.sp,
                        color = if (canAfford) MaterialTheme.colorScheme.primary else MaterialTheme.colorScheme.onSurfaceVariant
                    )
                }
                Spacer(Modifier.height(2.dp))
                Button(
                    onClick = onPurchase,
                    enabled = canAfford,
                    modifier = Modifier.height(24.dp),
                    contentPadding = PaddingValues(horizontal = 12.dp, vertical = 0.dp)
                ) {
                    Text("购买", fontSize = 10.sp)
                }
            }
        }
    }
}
