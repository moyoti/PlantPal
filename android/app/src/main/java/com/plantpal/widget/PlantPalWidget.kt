package com.plantpal.widget

import android.content.Context
import androidx.compose.runtime.Composable
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import androidx.glance.*
import androidx.glance.appwidget.*
import androidx.glance.color.ColorProvider
import androidx.glance.layout.*
import androidx.glance.text.*
import com.plantpal.model.GrowthStage
import com.plantpal.model.SpriteMood

class PlantPalWidget : GlanceAppWidget() {
    override suspend fun provideGlance(context: Context, id: GlanceId) {
        provideContent {
            WidgetContent()
        }
    }
}

@Composable
private fun WidgetContent() {
    val plantName = "小绿"
    val growthStage = GrowthStage.BLOOM
    val waterLevel = 0.6
    val lightLevel = 0.7
    val health = 0.85
    val spriteMood = SpriteMood.HAPPY
    val needsAttention = waterLevel < 0.3 || lightLevel < 0.3 || health < 0.3

    Box(
        modifier = GlanceModifier
            .fillMaxSize()
            .background(ColorProvider(day = Color(0xFFF5F5DC), night = Color(0xFF1A1A2E)))
            .padding(12.dp)
    ) {
        Column(
            modifier = GlanceModifier.fillMaxSize(),
            verticalAlignment = Alignment.Top,
            horizontalAlignment = Alignment.CenterHorizontally
        ) {
            Row(
                modifier = GlanceModifier.fillMaxWidth(),
                horizontalAlignment = Alignment.CenterHorizontally
            ) {
                Text(
                    text = spriteEmoji(mood = spriteMood),
                    style = TextStyle(fontSize = 24.sp)
                )
                Spacer(modifier = GlanceModifier.width(8.dp))
                Text(
                    text = plantName,
                    style = TextStyle(
                        fontSize = 14.sp,
                        fontWeight = FontWeight.Bold,
                        color = ColorProvider(day = Color(0xFF4CAF50), night = Color(0xFF66BB6A))
                    )
                )
            }

            Spacer(modifier = GlanceModifier.height(8.dp))

            Row(
                modifier = GlanceModifier.fillMaxWidth(),
                horizontalAlignment = Alignment.Start
            ) {
                Text(text = "🌱 ${growthStage.displayName}", style = TextStyle(fontSize = 11.sp))
            }

            Spacer(modifier = GlanceModifier.height(4.dp))

            Column(modifier = GlanceModifier.fillMaxWidth()) {
                WidgetProgressBar("水", waterLevel)
                WidgetProgressBar("光", lightLevel)
                WidgetProgressBar("命", health)
            }

            if (needsAttention) {
                Spacer(modifier = GlanceModifier.height(4.dp))
                Text(
                    text = "⚠️ 需要照顾",
                    style = TextStyle(fontSize = 10.sp, color = ColorProvider(day = Color.Red, night = Color(0xFFEF5350)))
                )
            }
        }
    }
}

@Composable
private fun WidgetProgressBar(label: String, value: Double) {
    Row(
        modifier = GlanceModifier.fillMaxWidth().padding(vertical = 1.dp),
        verticalAlignment = Alignment.CenterVertically
    ) {
        Text(text = label, style = TextStyle(fontSize = 9.sp), modifier = GlanceModifier.width(16.dp))
        val filled = (value * 10).toInt()
        val empty = 10 - filled
        Text(text = "█".repeat(filled) + "░".repeat(empty), style = TextStyle(fontSize = 9.sp))
        Text(text = "${(value * 100).toInt()}%", style = TextStyle(fontSize = 8.sp), modifier = GlanceModifier.padding(start = 4.dp))
    }
}

private fun spriteEmoji(mood: SpriteMood): String = when (mood) {
    SpriteMood.HAPPY -> "🧚"
    SpriteMood.EXCITED -> "✨"
    SpriteMood.WORRIED -> "😟"
    SpriteMood.SAD -> "😢"
    SpriteMood.SLEEPING -> "💤"
}

class PlantPalWidgetReceiver : GlanceAppWidgetReceiver() {
    override val glanceAppWidget: GlanceAppWidget = PlantPalWidget()
}