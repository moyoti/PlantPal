package com.plantpal.ui.screens

import androidx.compose.foundation.layout.*
import androidx.compose.foundation.lazy.grid.GridCells
import androidx.compose.foundation.lazy.grid.LazyVerticalGrid
import androidx.compose.foundation.lazy.grid.items
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material3.*
import androidx.compose.runtime.*
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import com.plantpal.model.DecorationCategory
import com.plantpal.model.DecorationItem

@Composable
fun DecorationStoreScreen(
    coins: Int,
    ownedItemIds: Set<String>,
    onPurchase: (DecorationItem) -> Unit
) {
    var selectedCategory by remember { mutableStateOf(DecorationCategory.POT) }

    Column(modifier = Modifier.fillMaxSize().padding(16.dp)) {
        Row(
            modifier = Modifier.fillMaxWidth(),
            horizontalArrangement = Arrangement.End,
            verticalAlignment = Alignment.CenterVertically
        ) {
            Text("🪙 $coins", fontSize = 18.sp)
        }

        Spacer(Modifier.height(12.dp))

        Row(modifier = Modifier.fillMaxWidth(), horizontalArrangement = Arrangement.spacedBy(8.dp)) {
            DecorationCategory.entries.forEach { cat ->
                FilterChip(
                    selected = selectedCategory == cat,
                    onClick = { selectedCategory = cat },
                    label = { Text("${cat.icon} ${cat.displayName}") }
                )
            }
        }

        Spacer(Modifier.height(12.dp))

        val items = when (selectedCategory) {
            DecorationCategory.POT -> DecorationItem.pots()
            DecorationCategory.BACKGROUND -> DecorationItem.backgrounds()
            DecorationCategory.OUTFIT -> DecorationItem.outfits()
        }

        LazyVerticalGrid(columns = GridCells.Fixed(2), horizontalArrangement = Arrangement.spacedBy(12.dp), verticalArrangement = Arrangement.spacedBy(12.dp)) {
            items(items) { item ->
                DecorationCard(
                    item = item,
                    isOwned = ownedItemIds.contains(item.id),
                    canAfford = coins >= item.cost,
                    onPurchase = { onPurchase(item) }
                )
            }
        }
    }
}

@Composable
private fun DecorationCard(item: DecorationItem, isOwned: Boolean, canAfford: Boolean, onPurchase: () -> Unit) {
    Card(modifier = Modifier.fillMaxWidth(), shape = RoundedCornerShape(12.dp)) {
        Column(
            modifier = Modifier.padding(12.dp),
            horizontalAlignment = Alignment.CenterHorizontally
        ) {
            Text(item.category.icon, fontSize = 36.sp)
            Spacer(Modifier.height(4.dp))
            Text(item.name, fontSize = 12.sp)

            Spacer(Modifier.height(4.dp))

            when {
                isOwned -> Text("已拥有 ✅", fontSize = 10.sp, color = MaterialTheme.colorScheme.primary)
                item.isUnlockedByDefault -> Text("默认", fontSize = 10.sp, color = MaterialTheme.colorScheme.onSurfaceVariant)
                else -> {
                    Button(
                        onClick = onPurchase,
                        enabled = canAfford,
                        contentPadding = PaddingValues(horizontal = 12.dp, vertical = 4.dp)
                    ) {
                        Text("🪙 ${item.cost}", fontSize = 10.sp)
                    }
                }
            }
        }
    }
}
