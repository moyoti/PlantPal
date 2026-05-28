package com.plantpal.ui.screens

import androidx.compose.foundation.layout.*
import androidx.compose.material3.*
import androidx.compose.runtime.*
import androidx.compose.ui.Modifier
import androidx.compose.ui.unit.dp
import com.plantpal.data.entity.PlantEntity

@Composable
fun SettingsScreen(plant: PlantEntity?, onResetData: () -> Unit) {
    var notificationsEnabled by remember { mutableStateOf(true) }
    var waterReminderInterval by remember { mutableStateOf(4) }

    Column(modifier = Modifier.fillMaxSize().padding(16.dp)) {
        Text("通知", style = MaterialTheme.typography.titleMedium)
        Spacer(Modifier.height(8.dp))
        Row(modifier = Modifier.fillMaxWidth(), horizontalArrangement = Arrangement.SpaceBetween) {
            Text("浇水提醒")
            Switch(checked = notificationsEnabled, onCheckedChange = { notificationsEnabled = it })
        }
        if (notificationsEnabled) {
            Row(modifier = Modifier.fillMaxWidth(), horizontalArrangement = Arrangement.SpaceBetween) {
                Text("间隔: ${waterReminderInterval}小时")
                Slider(value = waterReminderInterval.toFloat(), onValueChange = { waterReminderInterval = it.toInt() }, valueRange = 1f..12f, steps = 10, modifier = Modifier.weight(1f).padding(horizontal = 16.dp))
            }
        }

        Spacer(Modifier.height(24.dp))

        Text("植物信息", style = MaterialTheme.typography.titleMedium)
        Spacer(Modifier.height(8.dp))
        if (plant != null) {
            Card(modifier = Modifier.fillMaxWidth()) {
                Column(modifier = Modifier.padding(16.dp)) {
                    Row(modifier = Modifier.fillMaxWidth(), horizontalArrangement = Arrangement.SpaceBetween) {
                        Text("名字")
                        Text(plant.name)
                    }
                    Row(modifier = Modifier.fillMaxWidth(), horizontalArrangement = Arrangement.SpaceBetween) {
                        Text("品种")
                        Text(plant.species.displayName)
                    }
                    Row(modifier = Modifier.fillMaxWidth(), horizontalArrangement = Arrangement.SpaceBetween) {
                        Text("阶段")
                        Text(plant.growthStage.displayName)
                    }
                    Row(modifier = Modifier.fillMaxWidth(), horizontalArrangement = Arrangement.SpaceBetween) {
                        Text("存活天数")
                        Text("${plant.totalCareEvents}")
                    }
                }
            }
        }

        Spacer(Modifier.height(24.dp))

        Text("危险操作", style = MaterialTheme.typography.titleMedium)
        Spacer(Modifier.height(8.dp))
        Button(onClick = onResetData, colors = ButtonDefaults.buttonColors(containerColor = MaterialTheme.colorScheme.error)) {
            Text("重置所有数据")
        }
    }
}
