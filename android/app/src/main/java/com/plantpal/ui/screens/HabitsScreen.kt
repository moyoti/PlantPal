package com.plantpal.ui.screens

import androidx.compose.foundation.layout.*
import androidx.compose.foundation.lazy.LazyColumn
import androidx.compose.foundation.lazy.LazyRow
import androidx.compose.foundation.lazy.items
import androidx.compose.material3.*
import androidx.compose.runtime.*
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.text.style.TextDecoration
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import com.plantpal.data.entity.HabitTaskEntity

@Composable
fun HabitsScreen(
    tasks: List<HabitTaskEntity>,
    onToggleTask: (HabitTaskEntity) -> Unit,
    onAddTask: (String, String, Double, Double) -> Unit,
    onDeleteTask: (HabitTaskEntity) -> Unit
) {
    var showAddDialog by remember { mutableStateOf(false) }

    Scaffold(
        floatingActionButton = {
            FloatingActionButton(onClick = { showAddDialog = true }) {
                Text("+")
            }
        }
    ) { padding ->
        LazyColumn(
            modifier = Modifier.fillMaxSize().padding(padding).padding(16.dp),
            verticalArrangement = Arrangement.spacedBy(8.dp)
        ) {
            items(tasks, key = { it.id }) { task ->
                HabitTaskCard(task, onToggle = { onToggleTask(task) }, onDelete = { onDeleteTask(task) })
            }
        }
    }

    if (showAddDialog) {
        AddHabitDialog(
            onDismiss = { showAddDialog = false },
            onAdd = { title, emoji, nutrient, sunlight ->
                onAddTask(title, emoji, nutrient, sunlight)
                showAddDialog = false
            }
        )
    }
}

@Composable
private fun HabitTaskCard(task: HabitTaskEntity, onToggle: () -> Unit, onDelete: () -> Unit) {
    Card(modifier = Modifier.fillMaxWidth()) {
        Row(modifier = Modifier.padding(12.dp), verticalAlignment = Alignment.CenterVertically) {
            Text(task.iconEmoji, fontSize = 24.sp)
            Spacer(Modifier.width(12.dp))
            Column(modifier = Modifier.weight(1f)) {
                Text(task.title, fontSize = 14.sp, textDecoration = if (task.isCompletedToday) TextDecoration.LineThrough else TextDecoration.None)
                Row(horizontalArrangement = Arrangement.spacedBy(4.dp)) {
                    Text("🔥${task.streakCount}", fontSize = 10.sp)
                    Text("💧+${task.nutrientReward.toInt()}", fontSize = 10.sp)
                    Text("☀️+${task.sunlightReward.toInt()}", fontSize = 10.sp)
                }
            }
            IconButton(onClick = onToggle, enabled = !task.isCompletedToday) {
                Text(if (task.isCompletedToday) "✅" else "⭕", fontSize = 20.sp)
            }
        }
    }
}

@Composable
private fun AddHabitDialog(
    onDismiss: () -> Unit,
    onAdd: (String, String, Double, Double) -> Unit
) {
    var title by remember { mutableStateOf("") }
    var emoji by remember { mutableStateOf("💧") }
    var nutrientReward by remember { mutableStateOf(2.0) }
    var sunlightReward by remember { mutableStateOf(1.0) }

    val emojiOptions = listOf("💧", "🏃", "🌅", "📚", "🧘", "🍎", "💪", "🎨", "🎵", "🛌")

    AlertDialog(
        onDismissRequest = onDismiss,
        title = { Text("添加习惯") },
        text = {
            Column(verticalArrangement = Arrangement.spacedBy(8.dp)) {
                OutlinedTextField(value = title, onValueChange = { title = it }, label = { Text("任务名称") })
                LazyRow(horizontalArrangement = Arrangement.spacedBy(4.dp)) {
                    items(emojiOptions) { option ->
                        TextButton(onClick = { emoji = option }) {
                            Text(option, fontSize = 24.sp)
                        }
                    }
                }
                Row(horizontalArrangement = Arrangement.spacedBy(8.dp)) {
                    Column(modifier = Modifier.weight(1f)) {
                        Text("养分奖励: ${nutrientReward.toInt()}", fontSize = 12.sp)
                        Slider(value = nutrientReward.toFloat(), onValueChange = { nutrientReward = it.toDouble() }, valueRange = 0f..10f, steps = 9)
                    }
                    Column(modifier = Modifier.weight(1f)) {
                        Text("阳光奖励: ${sunlightReward.toInt()}", fontSize = 12.sp)
                        Slider(value = sunlightReward.toFloat(), onValueChange = { sunlightReward = it.toDouble() }, valueRange = 0f..10f, steps = 9)
                    }
                }
            }
        },
        confirmButton = {
            TextButton(onClick = { onAdd(title, emoji, nutrientReward, sunlightReward) }, enabled = title.isNotBlank()) {
                Text("添加")
            }
        },
        dismissButton = { TextButton(onClick = onDismiss) { Text("取消") } }
    )
}
