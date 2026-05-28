package com.plantpal.ui.screens

import androidx.compose.foundation.layout.*
import androidx.compose.material3.*
import androidx.compose.runtime.Composable
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import com.plantpal.data.entity.PlantEntity
import com.plantpal.data.entity.SpriteEntity
import com.plantpal.model.GrowthStage

@Composable
fun CollectionScreen(plant: PlantEntity?, sprite: SpriteEntity?) {
    if (plant == null || sprite == null) return

    Column(modifier = Modifier.fillMaxSize().padding(16.dp)) {
        Text("当前植物", style = MaterialTheme.typography.titleMedium)
        Spacer(Modifier.height(8.dp))
        Card(modifier = Modifier.fillMaxWidth()) {
            Row(modifier = Modifier.padding(16.dp), verticalAlignment = Alignment.CenterVertically) {
                Text("🌱", fontSize = 32.sp)
                Spacer(Modifier.width(12.dp))
                Column {
                    Text(plant.name)
                    Text("存活 ${plant.totalCareEvents} 天", fontSize = 12.sp, color = MaterialTheme.colorScheme.onSurfaceVariant)
                }
            }
        }

        Spacer(Modifier.height(24.dp))

        Text("精灵进化", style = MaterialTheme.typography.titleMedium)
        Spacer(Modifier.height(8.dp))

        val evolutionNames = listOf("种子精灵", "嫩芽仙女", "花蕾精灵", "花仙子", "果实女王")
        evolutionNames.forEachIndexed { index, name ->
            val level = index + 1
            val unlocked = level <= sprite.evolutionLevel
            Card(modifier = Modifier.fillMaxWidth().padding(vertical = 4.dp)) {
                Row(modifier = Modifier.padding(12.dp), verticalAlignment = Alignment.CenterVertically) {
                    Text(if (unlocked) "✨" else "🔒", fontSize = 24.sp)
                    Spacer(Modifier.width(12.dp))
                    Text(name, color = if (unlocked) MaterialTheme.colorScheme.onSurface else MaterialTheme.colorScheme.onSurfaceVariant)
                }
            }
        }

        Spacer(Modifier.height(24.dp))

        Text("装饰", style = MaterialTheme.typography.titleMedium)
        Spacer(Modifier.height(8.dp))
        Text("即将推出...", color = MaterialTheme.colorScheme.onSurfaceVariant)
    }
}
