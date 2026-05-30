package com.plantpal.ui.screens

import androidx.compose.foundation.BorderStroke
import androidx.compose.foundation.Image
import androidx.compose.foundation.background
import androidx.compose.foundation.border
import androidx.compose.foundation.clickable
import androidx.compose.foundation.interaction.MutableInteractionSource
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.lazy.grid.GridCells
import androidx.compose.foundation.lazy.grid.LazyVerticalGrid
import androidx.compose.foundation.lazy.grid.items
import androidx.compose.foundation.rememberScrollState
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.foundation.verticalScroll
import androidx.compose.material3.*
import androidx.compose.runtime.*
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.Brush
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.layout.ContentScale
import androidx.compose.ui.platform.LocalContext
import androidx.compose.ui.res.painterResource
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.text.style.TextAlign
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import com.plantpal.data.entity.PlantEntity
import com.plantpal.data.entity.SpriteEntity
import com.plantpal.data.entity.PlayerWalletEntity
import com.plantpal.model.DecorationCategory
import com.plantpal.model.DecorationItem

@Composable
fun DecorationStoreScreen(
    coins: Int,
    ownedItemIds: Set<String>,
    equippedPot: String,
    equippedBg: String,
    equippedOutfit: String,
    onPurchase: (DecorationItem) -> Unit,
    onEquip: (DecorationItem) -> Unit
) {
    var selectedCategory by remember { mutableStateOf(DecorationCategory.POT) }
    var showConfirmPurchase by remember { mutableStateOf<DecorationItem?>(null) }

    Column(
        modifier = Modifier
            .fillMaxSize()
            .background(
                Brush.verticalGradient(
                    colors = listOf(Color(0xFFE8F5E9), Color(0xFFFFF8E1))
                )
            )
            .padding(16.dp)
    ) {
        Text(
            "装饰商店",
            fontSize = 16.sp,
            fontWeight = FontWeight.Bold,
            color = Color(0xFF2E2E2E),
            modifier = Modifier.fillMaxWidth(),
            textAlign = TextAlign.Center
        )
        Spacer(Modifier.height(4.dp))
        Box(
            modifier = Modifier
                .width(80.dp)
                .height(3.dp)
                .background(Color(0xFF4CAF50))
                .align(Alignment.CenterHorizontally)
        )

        Spacer(Modifier.height(12.dp))

        Surface(
            color = Color.White.copy(alpha = 0.6f),
            shape = RoundedCornerShape(4.dp),
            border = BorderStroke(2.dp, Color(0xFFFFD700).copy(alpha = 0.5f))
        ) {
            Row(
                modifier = Modifier.padding(horizontal = 12.dp, vertical = 6.dp),
                verticalAlignment = Alignment.CenterVertically,
                horizontalArrangement = Arrangement.spacedBy(6.dp)
            ) {
                Box(
                    modifier = Modifier.size(20.dp)
                        .background(Color(0xFFFFD700), RoundedCornerShape(10.dp))
                        .border(1.dp, Color(0xFFF9A825), RoundedCornerShape(10.dp))
                )
                Text("¥$coins", fontSize = 14.sp, fontWeight = FontWeight.Bold, color = Color(0xFFFFD700))
            }
        }

        Spacer(Modifier.height(12.dp))

        Row(
            modifier = Modifier.fillMaxWidth(),
            horizontalArrangement = Arrangement.spacedBy(8.dp)
        ) {
            DecorationCategory.entries.forEach { cat ->
                val isSelected = selectedCategory == cat
                Surface(
                    color = if (isSelected) Color(0xFF4CAF50).copy(alpha = 0.2f) else Color.Transparent,
                    shape = RoundedCornerShape(4.dp),
                    border = BorderStroke(
                        width = if (isSelected) 2.dp else 1.dp,
                        color = if (isSelected) Color(0xFF4CAF50) else Color(0xFFBDBDBD)
                    )
                ) {
                    Text(
                        "${cat.icon} ${cat.displayName}",
                        fontSize = 11.sp,
                        fontWeight = if (isSelected) FontWeight.Bold else FontWeight.Normal,
                        color = if (isSelected) Color(0xFF2E2E2E) else Color(0xFF9E9E9E),
                        modifier = Modifier
                            .clickable { selectedCategory = cat }
                            .padding(horizontal = 10.dp, vertical = 6.dp)
                    )
                }
            }
        }

        Spacer(Modifier.height(12.dp))

        val items = when (selectedCategory) {
            DecorationCategory.POT -> DecorationItem.pots()
            DecorationCategory.BACKGROUND -> DecorationItem.backgrounds()
            DecorationCategory.OUTFIT -> DecorationItem.outfits()
        }

        LazyVerticalGrid(
            columns = GridCells.Fixed(2),
            horizontalArrangement = Arrangement.spacedBy(12.dp),
            verticalArrangement = Arrangement.spacedBy(12.dp),
            modifier = Modifier.weight(1f)
        ) {
            items(items) { item ->
                DecorationCard(
                    item = item,
                    isOwned = ownedItemIds.contains(item.id) || item.isUnlockedByDefault,
                    isEquipped = isItemEquipped(item, equippedPot, equippedBg, equippedOutfit),
                    canAfford = coins >= item.cost,
                    onPurchase = { showConfirmPurchase = item },
                    onEquip = { onEquip(item) }
                )
            }
        }
    }

    if (showConfirmPurchase != null) {
        val item = showConfirmPurchase!!
        AlertDialog(
            onDismissRequest = { showConfirmPurchase = null },
            title = { Text("确认购买?") },
            text = { Text("${item.name} - ${item.cost} 金币") },
            confirmButton = {
                TextButton(onClick = {
                    onPurchase(item)
                    onEquip(item)
                    showConfirmPurchase = null
                }) { Text("确认") }
            },
            dismissButton = {
                TextButton(onClick = { showConfirmPurchase = null }) { Text("取消") }
            }
        )
    }
}

private fun isItemEquipped(item: DecorationItem, equippedPot: String, equippedBg: String, equippedOutfit: String): Boolean {
    return when (item.category) {
        DecorationCategory.POT -> item.assetName == "pot_$equippedPot"
        DecorationCategory.BACKGROUND -> item.assetName == "bg_$equippedBg"
        DecorationCategory.OUTFIT -> item.assetName == "outfit_$equippedOutfit"
    }
}

@Composable
private fun DecorationCard(
    item: DecorationItem,
    isOwned: Boolean,
    isEquipped: Boolean,
    canAfford: Boolean,
    onPurchase: () -> Unit,
    onEquip: () -> Unit
) {
    val context = LocalContext.current
    val resId = context.resources.getIdentifier(item.assetName, "drawable", context.packageName)

    Card(
        modifier = Modifier.fillMaxWidth(),
        shape = RoundedCornerShape(4.dp),
        border = BorderStroke(2.dp, if (isEquipped) Color(0xFF4CAF50) else Color(0xFFBDBDBD))
    ) {
        Column(
            modifier = Modifier.padding(8.dp),
            horizontalAlignment = Alignment.CenterHorizontally
        ) {
            Box(
                modifier = Modifier
                    .fillMaxWidth()
                    .height(60.dp)
                    .background(Color(0xFFFFF8E1), RoundedCornerShape(2.dp))
                    .border(2.dp, if (isEquipped) Color(0xFF4CAF50) else Color(0xFFBDBDBD), RoundedCornerShape(2.dp)),
                contentAlignment = Alignment.Center
            ) {
                if (resId != 0) {
                    Image(
                        painter = painterResource(id = resId),
                        contentDescription = item.name,
                        modifier = Modifier.size(40.dp),
                        contentScale = ContentScale.Fit
                    )
                } else {
                    Text(item.category.icon, fontSize = 28.sp)
                }
                if (isEquipped) {
                    Text(
                        "✓", fontSize = 10.sp, fontWeight = FontWeight.Bold,
                        color = Color.White,
                        modifier = Modifier
                            .align(Alignment.TopEnd)
                            .padding(4.dp)
                            .background(Color(0xFF4CAF50), RoundedCornerShape(1.dp))
                            .border(1.dp, Color(0xFF388E3C), RoundedCornerShape(1.dp))
                            .padding(horizontal = 3.dp, vertical = 1.dp)
                    )
                }
            }

            Spacer(Modifier.height(4.dp))

            Text(item.name, fontSize = 11.sp, color = Color(0xFF2E2E2E))

            Spacer(Modifier.height(4.dp))

            when {
                isEquipped -> {
                    Surface(
                        color = Color(0xFF4CAF50),
                        shape = RoundedCornerShape(1.dp)
                    ) {
                        Text("使用中", fontSize = 8.sp, color = Color.White, modifier = Modifier.padding(horizontal = 6.dp, vertical = 3.dp))
                    }
                }
                isOwned -> {
                    Button(
                        onClick = onEquip,
                        contentPadding = PaddingValues(horizontal = 12.dp, vertical = 2.dp),
                        colors = ButtonDefaults.buttonColors(containerColor = Color(0xFF4CAF50))
                    ) {
                        Text("装备", fontSize = 9.sp, color = Color.White)
                    }
                }
                item.isUnlockedByDefault -> {
                    Surface(
                        color = Color(0xFF9E9E9E),
                        shape = RoundedCornerShape(1.dp)
                    ) {
                        Text("默认", fontSize = 8.sp, color = Color.White, modifier = Modifier.padding(horizontal = 6.dp, vertical = 3.dp))
                    }
                }
                else -> {
                    Button(
                        onClick = onPurchase,
                        enabled = canAfford,
                        contentPadding = PaddingValues(horizontal = 12.dp, vertical = 2.dp),
                        colors = ButtonDefaults.buttonColors(
                            containerColor = if (canAfford) Color(0xFFFFD700).copy(alpha = 0.3f) else Color(0xFFEEEEEE)
                        )
                    ) {
                        Text("🪙 ${item.cost}", fontSize = 9.sp, color = if (canAfford) Color(0xFF2E2E2E) else Color(0xFF9E9E9E))
                    }
                }
            }
        }
    }
}

private val DecorationCategory.icon: String
    get() = when (this) {
        DecorationCategory.POT -> "🪴"
        DecorationCategory.BACKGROUND -> "🏞️"
        DecorationCategory.OUTFIT -> "🎩"
    }