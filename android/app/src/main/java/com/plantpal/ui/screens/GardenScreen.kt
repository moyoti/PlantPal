package com.plantpal.ui.screens

import androidx.compose.foundation.background
import androidx.compose.foundation.border
import androidx.compose.foundation.clickable
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material3.*
import androidx.compose.runtime.*
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.Color
import androidx.compose.foundation.BorderStroke
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import com.plantpal.data.entity.PlantEntity
import com.plantpal.data.entity.SpriteEntity
import com.plantpal.data.entity.PlayerWalletEntity
import com.plantpal.engine.TimeEngine
import com.plantpal.model.GrowthStage
import com.plantpal.model.InteractionType
import com.plantpal.model.SpriteMood

object PixelPalette {
    val greenBg = Color(0xFFE8F5E9)
    val greenPrimary = Color(0xFF4CAF50)
    val blueWater = Color(0xFF42A5F5)
    val yellowSun = Color(0xFFFFD54F)
    val brownEarth = Color(0xFF8D6E63)
    val pinkLove = Color(0xFFEC407A)
    val purpleNight = Color(0xFF9C27B0)
    val greenLight = Color(0xFF66BB6A)
    val orangeWarnFix = Color(0xFFFF9800)
    val redDanger = Color(0xFFF44336)
    val cream = Color(0xFFFFF8E1)
    val darkText = Color(0xFF2E2E2E)
    val mutedText = Color(0xFF9E9E9E)
    val cardBorder = Color(0xFFBDBDBD)
}

enum class InteractionTab(val label: String) {
    CARE("照料"), PLAY("互动")
}

@Composable
fun GardenScreen(
    plant: PlantEntity?,
    sprite: SpriteEntity?,
    wallet: PlayerWalletEntity?,
    cooldownState: TimeEngine.CooldownState,
    onInteraction: (InteractionType) -> Unit
) {
    if (plant == null || sprite == null) {
        Box(Modifier.fillMaxSize(), contentAlignment = Alignment.Center) {
            CircularProgressIndicator()
        }
        return
    }

    var selectedTab by remember { mutableStateOf(InteractionTab.CARE) }
    val careInteractions = listOf(InteractionType.WATER, InteractionType.LIGHT, InteractionType.FERTILIZE, InteractionType.HEAL, InteractionType.SHIELD)
    val playInteractions = listOf(InteractionType.TOUCH, InteractionType.TALK, InteractionType.SING, InteractionType.PLAY, InteractionType.DANCE, InteractionType.PET)
    val currentInteractions = if (selectedTab == InteractionTab.CARE) careInteractions else playInteractions

    Column(
        modifier = Modifier.fillMaxSize().background(PixelPalette.greenBg).padding(10.dp),
        verticalArrangement = Arrangement.spacedBy(4.dp)
    ) {
        Row(Modifier.fillMaxWidth(), horizontalArrangement = Arrangement.SpaceBetween, verticalAlignment = Alignment.CenterVertically) {
            Column {
                Text("我的花园", fontSize = 13.sp, fontWeight = FontWeight.Bold, color = PixelPalette.darkText)
                Box(Modifier.width(72.dp).height(2.dp).background(PixelPalette.greenPrimary))
            }
            if (wallet != null) {
                Surface(color = PixelPalette.yellowSun.copy(alpha = 0.12f), shape = RoundedCornerShape(2.dp), border = BorderStroke(1.dp, PixelPalette.yellowSun.copy(alpha = 0.5f))) {
                    Row(Modifier.padding(horizontal = 4.dp, vertical = 2.dp), horizontalArrangement = Arrangement.spacedBy(2.dp)) {
                        Box(Modifier.size(8.dp).background(PixelPalette.yellowSun, RoundedCornerShape(4.dp)))
                        Text("${wallet.coins}", fontSize = 7.sp, fontWeight = FontWeight.Bold, color = PixelPalette.darkText)
                    }
                }
            }
        }

        Row(Modifier.fillMaxWidth(), horizontalArrangement = Arrangement.spacedBy(4.dp), verticalAlignment = Alignment.CenterVertically) {
            Text(sprite.name, fontSize = 9.sp, fontWeight = FontWeight.Bold, color = PixelPalette.greenPrimary)
            MoodBadge(sprite.mood)
            if (plant.isSick) StatusBadge("生病", PixelPalette.redDanger)
            if (System.currentTimeMillis() < plant.shieldedUntil) StatusBadge("护盾", PixelPalette.blueWater)
            Spacer(Modifier.weight(1f))
            if (sprite.fatigue > 0.5) {
                Row(horizontalArrangement = Arrangement.spacedBy(1.dp)) {
                    Text("疲惫", fontSize = 6.sp, color = PixelPalette.orangeWarnFix)
                    Box(Modifier.width(20.dp).height(4.dp).background(PixelPalette.orangeWarnFix.copy(alpha = 0.3f))) {
                        Box(Modifier.width((20 * sprite.fatigue.coerceIn(0.0, 1.0)).dp).height(4.dp).background(PixelPalette.orangeWarnFix))
                    }
                    if (sprite.fatigue > 0.6) {
                        Text("↓", fontSize = 6.sp, color = PixelPalette.redDanger)
                    }
                }
            }
        }

        Box(Modifier.fillMaxWidth().height(160.dp).background(PixelPalette.cream.copy(alpha = 0.3f), RoundedCornerShape(4.dp)).border(2.dp, PixelPalette.cardBorder, RoundedCornerShape(4.dp)), contentAlignment = Alignment.Center) {
            Text(stageEmoji(plant.growthStage), fontSize = 60.sp, modifier = Modifier.offset(y = (-16).dp))
            Text(spriteMoodEmoji(sprite.mood), fontSize = 28.sp, modifier = Modifier.offset(x = 50.dp, y = (-30).dp))
        }

        Column(verticalArrangement = Arrangement.spacedBy(3.dp)) {
            StatusBarRow("水", plant.waterLevel, PixelPalette.blueWater)
            StatusBarRow("光", plant.lightLevel, PixelPalette.yellowSun)
            StatusBarRow("命", plant.health, PixelPalette.greenLight)
        }

        Row(Modifier.fillMaxWidth(), horizontalArrangement = Arrangement.spacedBy(0.dp)) {
            TabButton("照料", selectedTab == InteractionTab.CARE, PixelPalette.greenPrimary) { selectedTab = InteractionTab.CARE }
            TabButton("互动", selectedTab == InteractionTab.PLAY, PixelPalette.pinkLove) { selectedTab = InteractionTab.PLAY }
        }

        if (currentInteractions.size <= 5) {
            Row(Modifier.fillMaxWidth(), horizontalArrangement = Arrangement.spacedBy(4.dp)) {
                currentInteractions.forEach { type -> InteractionBtn(type, cooldownState, onInteraction) }
            }
        } else {
            Column(verticalArrangement = Arrangement.spacedBy(4.dp)) {
                Row(Modifier.fillMaxWidth(), horizontalArrangement = Arrangement.spacedBy(4.dp)) {
                    currentInteractions.take(5).forEach { type -> InteractionBtn(type, cooldownState, onInteraction) }
                }
                Row(Modifier.fillMaxWidth(), horizontalArrangement = Arrangement.spacedBy(4.dp)) {
                    currentInteractions.drop(5).forEach { type -> InteractionBtn(type, cooldownState, onInteraction) }
                }
            }
        }
    }
}

@Composable
private fun MoodBadge(mood: SpriteMood) {
    val (text, color) = when (mood) {
        SpriteMood.HAPPY -> "开心" to PixelPalette.greenPrimary
        SpriteMood.EXCITED -> "超开心" to PixelPalette.greenPrimary
        SpriteMood.WORRIED -> "担心" to PixelPalette.orangeWarnFix
        SpriteMood.SAD -> "难过" to PixelPalette.redDanger
        SpriteMood.SLEEPING -> "睡觉" to PixelPalette.purpleNight
    }
    Surface(color = color, shape = RoundedCornerShape(1.dp)) {
        Text(text, modifier = Modifier.padding(horizontal = 4.dp, vertical = 2.dp), fontSize = 7.sp, color = Color.White)
    }
}

@Composable
private fun StatusBadge(text: String, color: Color) {
    Surface(color = color, shape = RoundedCornerShape(1.dp)) {
        Text(text, modifier = Modifier.padding(horizontal = 4.dp, vertical = 2.dp), fontSize = 6.sp, color = Color.White)
    }
}

@Composable
private fun RowScope.TabButton(label: String, selected: Boolean, color: Color, onClick: () -> Unit) {
    Box(Modifier.weight(1f).clickable { onClick() }.background(if (selected) color.copy(alpha = 0.15f) else PixelPalette.greenBg.copy(alpha = 0.5f)).padding(vertical = 5.dp), contentAlignment = Alignment.Center) {
        Column(horizontalAlignment = Alignment.CenterHorizontally) {
            Text(label, fontSize = 8.sp, fontWeight = FontWeight.Bold, color = if (selected) color else PixelPalette.mutedText)
            Box(Modifier.width(40.dp).height(if (selected) 2.dp else 1.dp).background(if (selected) color else PixelPalette.cardBorder.copy(alpha = 0.3f)))
        }
    }
}

@Composable
private fun RowScope.InteractionBtn(type: InteractionType, cooldownState: TimeEngine.CooldownState, onClick: (InteractionType) -> Unit) {
    val remaining = cooldownState.remainingCooldown(type)
    val onCooldown = remaining > 0
    val btnColor = typeToColor(type)

    Box(Modifier.weight(1f).clickable(enabled = !onCooldown) { onClick(type) }.background(btnColor.copy(alpha = if (onCooldown) 0.04f else 0.12f), RoundedCornerShape(4.dp)).border(if (onCooldown) 1.dp else 2.dp, btnColor.copy(alpha = if (onCooldown) 0.15f else 0.4f), RoundedCornerShape(4.dp)).padding(vertical = 6.dp), contentAlignment = Alignment.Center) {
        if (onCooldown) {
            Box(Modifier.fillMaxWidth().height(32.dp).background(Color.Black.copy(alpha = 0.45f), RoundedCornerShape(4.dp)), contentAlignment = Alignment.Center) {
                Text("${remaining.toInt() + 1}", fontSize = 9.sp, fontWeight = FontWeight.Bold, color = Color.White)
            }
        } else {
            Column(horizontalAlignment = Alignment.CenterHorizontally, verticalArrangement = Arrangement.spacedBy(2.dp)) {
                Text(type.icon, fontSize = 16.sp)
                Text(type.displayName, fontSize = 7.sp, color = PixelPalette.darkText)
            }
        }
    }
}

private fun typeToColor(type: InteractionType): Color = when (type) {
    InteractionType.WATER -> PixelPalette.blueWater
    InteractionType.LIGHT -> PixelPalette.yellowSun
    InteractionType.FERTILIZE -> PixelPalette.brownEarth
    InteractionType.TOUCH -> PixelPalette.pinkLove
    InteractionType.TALK -> PixelPalette.purpleNight
    InteractionType.SING -> PixelPalette.pinkLove
    InteractionType.HEAL -> PixelPalette.greenLight
    InteractionType.PLAY -> PixelPalette.orangeWarnFix
    InteractionType.SHIELD -> PixelPalette.blueWater
    InteractionType.DANCE -> PixelPalette.pinkLove
    InteractionType.PET -> Color(0xFFA1887F)
}

private fun stageEmoji(stage: GrowthStage): String = when (stage) {
    GrowthStage.SEED -> "🌱"
    GrowthStage.SPROUT -> "🌿"
    GrowthStage.BUD -> "🌸"
    GrowthStage.BLOOM -> "🌺"
    GrowthStage.FRUIT -> "🍎"
    GrowthStage.WILTED -> "🥀"
}

private fun spriteMoodEmoji(mood: SpriteMood): String = when (mood) {
    SpriteMood.HAPPY -> "🧚"
    SpriteMood.EXCITED -> "✨"
    SpriteMood.WORRIED -> "😟"
    SpriteMood.SAD -> "😢"
    SpriteMood.SLEEPING -> "💤"
}

@Composable
private fun StatusBarRow(label: String, value: Double, color: Color) {
    Row(verticalAlignment = Alignment.CenterVertically, horizontalArrangement = Arrangement.spacedBy(4.dp)) {
        Text(label, fontSize = 9.sp, color = color, modifier = Modifier.width(20.dp))
        LinearProgressIndicator(
            progress = { value.toFloat() },
            modifier = Modifier.weight(1f).height(10.dp),
            color = color,
            trackColor = color.copy(alpha = 0.2f)
        )
        Text("${(value * 100).toInt()}%", fontSize = 8.sp, color = PixelPalette.mutedText, modifier = Modifier.width(30.dp))
    }
}