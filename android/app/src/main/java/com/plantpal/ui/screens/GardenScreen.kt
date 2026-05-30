package com.plantpal.ui.screens

import android.os.Build
import android.view.HapticFeedbackConstants
import androidx.compose.animation.AnimatedVisibility
import androidx.compose.animation.core.*
import androidx.compose.animation.fadeIn
import androidx.compose.animation.fadeOut
import androidx.compose.animation.slideInVertically
import androidx.compose.animation.slideOutVertically
import androidx.compose.foundation.BorderStroke
import androidx.compose.foundation.Image
import androidx.compose.foundation.background
import androidx.compose.foundation.border
import androidx.compose.foundation.clickable
import androidx.compose.foundation.gestures.detectDragGestures
import androidx.compose.foundation.interaction.MutableInteractionSource
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material3.*
import androidx.compose.runtime.*
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clipToBounds
import androidx.compose.ui.geometry.Offset
import androidx.compose.ui.graphics.Brush
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.input.pointer.pointerInput
import androidx.compose.ui.layout.ContentScale
import androidx.compose.ui.layout.onSizeChanged
import androidx.compose.ui.platform.LocalContext
import androidx.compose.ui.platform.LocalView
import androidx.compose.ui.res.painterResource
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.unit.IntOffset
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import com.plantpal.data.entity.PlantEntity
import com.plantpal.data.entity.SpriteEntity
import com.plantpal.data.entity.PlayerWalletEntity
import com.plantpal.data.entity.PetEntity
import com.plantpal.engine.TimeEngine
import com.plantpal.model.InteractionType
import com.plantpal.model.SpriteMood
import com.plantpal.model.PetType
import com.plantpal.ui.components.AnimatedSpriteView
import com.plantpal.ui.components.AnimatedPetView
import kotlinx.coroutines.delay
import kotlinx.coroutines.launch
import kotlin.random.Random

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
    val coinGold = Color(0xFFFFD700)
    val yellowSunDark = Color(0xFFF9A825)
}

private val primaryInteractions = listOf(
    InteractionType.WATER, InteractionType.LIGHT, InteractionType.FERTILIZE,
    InteractionType.TOUCH, InteractionType.PET
)

private val secondaryInteractions = listOf(
    InteractionType.TALK, InteractionType.SING, InteractionType.HEAL,
    InteractionType.PLAY, InteractionType.SHIELD, InteractionType.DANCE
)

@Composable
fun GardenScreen(
    plant: PlantEntity?,
    sprite: SpriteEntity?,
    wallet: PlayerWalletEntity?,
    pets: List<PetEntity> = emptyList(),
    cooldownState: TimeEngine.CooldownState,
    onInteraction: (InteractionType) -> Unit,
    onSpriteTap: () -> Unit = {},
    onPetTap: (PetEntity) -> Unit = {}
) {
    if (plant == null || sprite == null) {
        Box(Modifier.fillMaxSize(), contentAlignment = Alignment.Center) {
            CircularProgressIndicator()
        }
        return
    }

    var showInteractionMenu by remember { mutableStateOf(false) }
    var showStatusDetail by remember { mutableStateOf(false) }
    var spriteOffsetX by remember { mutableFloatStateOf(0f) }
    var spriteOffsetY by remember { mutableFloatStateOf(0f) }
    var spriteTapReaction by remember { mutableStateOf<String?>(null) }
    val scope = rememberCoroutineScope()

    Box(modifier = Modifier.fillMaxSize()) {
        FullscreenScene(
            plant = plant,
            sprite = sprite,
            pets = pets,
            spriteOffsetX = spriteOffsetX,
            spriteOffsetY = spriteOffsetY,
            spriteTapReaction = spriteTapReaction,
            onSpriteTap = {
                onSpriteTap()
                scope.launch {
                    spriteTapReaction = tapReactionText(sprite.mood)
                    delay(1500)
                    spriteTapReaction = null
                }
            },
            onPetTap = onPetTap
        )
        TopOverlay(
            sprite = sprite,
            plant = plant,
            wallet = wallet,
            showStatusDetail = showStatusDetail,
            onToggleStatus = { showStatusDetail = !showStatusDetail }
        )
        BottomOverlay(
            cooldownState = cooldownState,
            onInteraction = onInteraction,
            showInteractionMenu = showInteractionMenu,
            onToggleMenu = { showInteractionMenu = !showInteractionMenu }
        )
    }

    LaunchedEffect(sprite.mood) {
        while (true) {
            val delayMs = when (sprite.mood) {
                SpriteMood.SLEEPING -> 3000L
                SpriteMood.SAD -> if (Random.nextBoolean()) Random.nextLong(4000, 7000) else continue
                SpriteMood.WORRIED -> Random.nextLong(3000, 5000)
                SpriteMood.HAPPY -> Random.nextLong(2000, 4000)
                SpriteMood.EXCITED -> Random.nextLong(1000, 3000)
            }
            delay(delayMs)
            if (sprite.mood != SpriteMood.SLEEPING) {
                val rangeMultiplier = when (sprite.mood) {
                    SpriteMood.EXCITED -> 1.3f
                    SpriteMood.HAPPY -> 1.0f
                    SpriteMood.WORRIED -> 0.5f
                    SpriteMood.SAD -> 0.3f
                    else -> 1.0f
                }
                spriteOffsetX = Random.nextFloat() * 200f * rangeMultiplier - 100f * rangeMultiplier
                spriteOffsetY = Random.nextFloat() * 60f * rangeMultiplier - 30f * rangeMultiplier
            } else {
                spriteOffsetX = 0f
                spriteOffsetY = 0f
            }
        }
    }
}

private fun tapReactionText(mood: SpriteMood): String = when (mood) {
    SpriteMood.EXCITED -> listOf("❤️", "✨", "💕").random()
    SpriteMood.HAPPY -> listOf("😊", "🎵", "💛").random()
    SpriteMood.WORRIED -> listOf("🥺", "💧", "😔").random()
    SpriteMood.SAD -> listOf("😢", "💔", "🌧️").random()
    SpriteMood.SLEEPING -> listOf("💤", "😴", "🌙").random()
}

@Composable
private fun FullscreenScene(
    plant: PlantEntity,
    sprite: SpriteEntity,
    pets: List<PetEntity>,
    spriteOffsetX: Float,
    spriteOffsetY: Float,
    spriteTapReaction: String?,
    onSpriteTap: () -> Unit,
    onPetTap: (PetEntity) -> Unit
) {
    val context = LocalContext.current
    val bgResId = context.resources.getIdentifier(
        "bg_${plant.backgroundScene}", "drawable", context.packageName
    )
    if (bgResId != 0) {
        Image(
            painter = painterResource(id = bgResId),
            contentDescription = null,
            modifier = Modifier.fillMaxSize(),
            contentScale = ContentScale.Crop
        )
    } else {
        Box(Modifier.fillMaxSize().background(PixelPalette.greenBg))
    }
    Box(
        modifier = Modifier.fillMaxSize(),
        contentAlignment = Alignment.Center
    ) {
        Column(horizontalAlignment = Alignment.CenterHorizontally) {
            Spacer(Modifier.weight(1f))
            val plantResId = context.resources.getIdentifier(
                "plant_${plant.growthStageRaw.lowercase()}", "drawable", context.packageName
            )
            if (plantResId != 0) {
                Image(
                    painter = painterResource(id = plantResId),
                    contentDescription = plant.growthStage.displayName,
                    modifier = Modifier.size(width = 140.dp, height = 200.dp)
                )
            }
            val potResId = context.resources.getIdentifier(
                "pot_${plant.potStyle}", "drawable", context.packageName
            )
            if (potResId != 0) {
                Image(
                    painter = painterResource(id = potResId),
                    contentDescription = null,
                    modifier = Modifier.size(width = 110.dp, height = 55.dp)
                )
            }
            Spacer(Modifier.weight(1f))
        }

        AnimatedSpriteView(
            evolutionLevel = sprite.evolutionLevel,
            mood = sprite.mood,
            modifier = Modifier
                .offset(x = (72 + spriteOffsetX).dp, y = (-48 + spriteOffsetY).dp)
                .clickable(
                    interactionSource = remember { MutableInteractionSource() },
                    indication = null,
                    onClick = onSpriteTap
                )
        )

        if (spriteTapReaction != null) {
            Surface(
                color = Color.White.copy(alpha = 0.85f),
                shape = RoundedCornerShape(8.dp),
                border = BorderStroke(1.dp, PixelPalette.greenPrimary.copy(alpha = 0.5f)),
                modifier = Modifier.offset(x = (72 + spriteOffsetX).dp, y = (-100 + spriteOffsetY).dp)
            ) {
                Text(
                    spriteTapReaction,
                    fontSize = 18.sp,
                    modifier = Modifier.padding(horizontal = 8.dp, vertical = 4.dp)
                )
            }
        }

        pets.filter { it.isOwned }.forEachIndexed { index, pet ->
            val view = LocalView.current
            var isDragging by remember { mutableStateOf(false) }
            var isWandering by remember { mutableStateOf(true) }
            var petOffsetX by remember(pet.id) { mutableFloatStateOf(-88f - index * 40f) }
            var petOffsetY by remember(pet.id) { mutableFloatStateOf(-32f) }

            LaunchedEffect(pet.id, isWandering) {
                if (isWandering) {
                    while (true) {
                        delay(Random.nextLong(3000, 6000))
                        petOffsetX += Random.nextFloat() * 30f - 15f
                        petOffsetY += Random.nextFloat() * 10f - 5f
                    }
                }
            }

            AnimatedPetView(
                petType = pet.petType,
                isHappy = pet.friendshipLevel > 0.5,
                modifier = Modifier
                    .size(if (isDragging) 58.dp else 48.dp)
                    .offset { IntOffset(petOffsetX.dp.roundToPx(), petOffsetY.dp.roundToPx()) }
                    .pointerInput(Unit) {
                        detectDragGestures(
                            onDragStart = {
                                isDragging = true
                                isWandering = false
                                if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O_MR1) {
                                    view.performHapticFeedback(HapticFeedbackConstants.TEXT_HANDLE_MOVE)
                                } else {
                                    view.performHapticFeedback(HapticFeedbackConstants.VIRTUAL_KEY)
                                }
                            },
                            onDrag = { change, dragAmount ->
                                change.consume()
                                val dpX = dragAmount.x / density
                                val dpY = dragAmount.y / density
                                petOffsetX += dpX
                                petOffsetY += dpY
                            },
                            onDragEnd = {
                                isDragging = false
                                if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q) {
                                    view.performHapticFeedback(HapticFeedbackConstants.CONFIRM)
                                } else {
                                    view.performHapticFeedback(HapticFeedbackConstants.LONG_PRESS)
                                }
                                isWandering = true
                            },
                            onDragCancel = {
                                isDragging = false
                                isWandering = true
                            }
                        )
                    }
                    .clickable(
                        interactionSource = remember { MutableInteractionSource() },
                        indication = null,
                        onClick = {
                            if (!isDragging) {
                                if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O_MR1) {
                                    view.performHapticFeedback(HapticFeedbackConstants.TEXT_HANDLE_MOVE)
                                } else {
                                    view.performHapticFeedback(HapticFeedbackConstants.VIRTUAL_KEY)
                                }
                                onPetTap(pet)
                            }
                        }
                    )
            )
        }
    }
}
@Composable
private fun BoxScope.TopOverlay(
    sprite: SpriteEntity,
    plant: PlantEntity,
    wallet: PlayerWalletEntity?,
    showStatusDetail: Boolean,
    onToggleStatus: () -> Unit
) {
    Column(
        modifier = Modifier
            .align(Alignment.TopStart)
            .fillMaxWidth()
            .background(
                Brush.verticalGradient(
                    colors = listOf(
                        Color.Black.copy(alpha = 0.55f),
                        Color.Black.copy(alpha = 0.25f),
                        Color.Transparent
                    )
                )
            )
            .clipToBounds()
    ) {
        Row(
            modifier = Modifier
                .fillMaxWidth()
                .padding(horizontal = 16.dp)
                .padding(top = 12.dp, bottom = 6.dp),
            horizontalArrangement = Arrangement.spacedBy(6.dp),
            verticalAlignment = Alignment.CenterVertically
        ) {
            Column {
                Row(
                    horizontalArrangement = Arrangement.spacedBy(4.dp),
                    verticalAlignment = Alignment.CenterVertically
                ) {
                    Text(sprite.name, fontSize = 14.sp, fontWeight = FontWeight.Bold, color = Color.White)
                    Text(plant.currentWeather.emoji, fontSize = 14.sp)
                    MoodBadge(sprite.mood)
                    if (plant.isSick) StatusBadge("生病", PixelPalette.redDanger)
                    if (System.currentTimeMillis() < plant.shieldedUntil) StatusBadge("护盾", PixelPalette.blueWater)
                }
                if (sprite.fatigue > 0.5) {
                    Row(
                        modifier = Modifier.padding(top = 2.dp),
                        horizontalArrangement = Arrangement.spacedBy(2.dp),
                        verticalAlignment = Alignment.CenterVertically
                    ) {
                        Text("疲僫", fontSize = 8.sp, color = PixelPalette.orangeWarnFix)
                        Box(
                            Modifier.width(28.dp).height(5.dp)
                                .background(Color.White.copy(alpha = 0.3f))
                                .border(1.dp, Color.White.copy(alpha = 0.5f), RoundedCornerShape(1.dp))
                        ) {
                            Box(
                                Modifier.width((28 * sprite.fatigue.coerceIn(0.0, 1.0)).dp).height(5.dp)
                                    .background(PixelPalette.orangeWarnFix)
                            )
                        }
                    }
                }
            }
            Spacer(Modifier.weight(1f))
            if (wallet != null) {
                Surface(
                    color = Color.Black.copy(alpha = 0.3f),
                    shape = RoundedCornerShape(3.dp),
                    border = BorderStroke(1.dp, PixelPalette.coinGold.copy(alpha = 0.4f))
                ) {
                    Row(
                        modifier = Modifier.padding(horizontal = 6.dp, vertical = 3.dp),
                        horizontalArrangement = Arrangement.spacedBy(3.dp),
                        verticalAlignment = Alignment.CenterVertically
                    ) {
                        Box(Modifier.size(10.dp)
                            .background(PixelPalette.coinGold, RoundedCornerShape(5.dp))
                            .border(1.dp, PixelPalette.yellowSunDark, RoundedCornerShape(5.dp))
                        )
                        Text("${wallet.coins}", fontSize = 10.sp, fontWeight = FontWeight.Bold, color = PixelPalette.coinGold)
                    }
                }
            }
            Box(
                modifier = Modifier.size(24.dp)
                    .background(Color.White.copy(alpha = 0.15f), RoundedCornerShape(4.dp))
                    .border(1.dp, Color.White.copy(alpha = 0.3f), RoundedCornerShape(4.dp))
                    .clickable(
                        interactionSource = remember { MutableInteractionSource() },
                        indication = null,
                        onClick = onToggleStatus
                    ),
                contentAlignment = Alignment.Center
            ) {
                Text(
                    if (showStatusDetail) "▲" else "▼",
                    fontSize = 10.sp, fontWeight = FontWeight.Bold,
                    color = Color.White.copy(alpha = 0.8f)
                )
            }
        }
        AnimatedVisibility(
            visible = showStatusDetail,
            enter = fadeIn() + slideInVertically { -it },
            exit = fadeOut() + slideOutVertically { -it }
        ) {
            Column(
                modifier = Modifier.fillMaxWidth().padding(horizontal = 16.dp).padding(bottom = 8.dp),
                verticalArrangement = Arrangement.spacedBy(4.dp)
            ) {
                StatusBarRow("水", plant.waterLevel, PixelPalette.blueWater)
                StatusBarRow("光", plant.lightLevel, PixelPalette.yellowSun)
                StatusBarRow("命", plant.health, PixelPalette.greenLight)
            }
        }
    }
}

@Composable
private fun BoxScope.BottomOverlay(
    cooldownState: TimeEngine.CooldownState,
    onInteraction: (InteractionType) -> Unit,
    showInteractionMenu: Boolean,
    onToggleMenu: () -> Unit
) {
    Column(modifier = Modifier.align(Alignment.BottomStart).fillMaxWidth()) {
        AnimatedVisibility(
            visible = showInteractionMenu,
            enter = fadeIn() + slideInVertically { it },
            exit = fadeOut() + slideOutVertically { it }
        ) {
            SecondaryMenu(cooldownState = cooldownState, onInteraction = onInteraction)
        }
        PrimaryBar(
            cooldownState = cooldownState,
            onInteraction = onInteraction,
            showInteractionMenu = showInteractionMenu,
            onToggleMenu = onToggleMenu
        )
    }
}

@Composable
private fun SecondaryMenu(
    cooldownState: TimeEngine.CooldownState,
    onInteraction: (InteractionType) -> Unit
) {
    val rows = splitIntoRows(secondaryInteractions, 3)
    Column(
        modifier = Modifier
            .fillMaxWidth()
            .padding(horizontal = 20.dp)
            .padding(bottom = 6.dp)
            .background(Color.Black.copy(alpha = 0.5f), RoundedCornerShape(8.dp))
            .border(1.dp, Color.White.copy(alpha = 0.2f), RoundedCornerShape(8.dp))
            .padding(horizontal = 16.dp, vertical = 8.dp),
        verticalArrangement = Arrangement.spacedBy(6.dp)
    ) {
        rows.forEach { row ->
            Row(
                modifier = Modifier.fillMaxWidth(),
                horizontalArrangement = Arrangement.spacedBy(8.dp)
            ) {
                row.forEach { type ->
                    InteractionButton(
                        type = type,
                        cooldownState = cooldownState,
                        onClick = onInteraction,
                        modifier = Modifier.weight(1f)
                    )
                }
                repeat(3 - row.size) { Spacer(Modifier.weight(1f)) }
            }
        }
    }
}

@Composable
private fun PrimaryBar(
    cooldownState: TimeEngine.CooldownState,
    onInteraction: (InteractionType) -> Unit,
    showInteractionMenu: Boolean,
    onToggleMenu: () -> Unit
) {
    Row(
        modifier = Modifier
            .fillMaxWidth()
            .padding(horizontal = 12.dp)
            .padding(bottom = 8.dp)
            .background(Color.Black.copy(alpha = 0.5f), RoundedCornerShape(10.dp))
            .border(1.dp, Color.White.copy(alpha = 0.2f), RoundedCornerShape(10.dp))
            .padding(horizontal = 12.dp, vertical = 8.dp),
        horizontalArrangement = Arrangement.spacedBy(6.dp)
    ) {
        primaryInteractions.forEach { type ->
            InteractionButton(
                type = type,
                cooldownState = cooldownState,
                onClick = onInteraction,
                modifier = Modifier.weight(1f)
            )
        }
        Column(
            modifier = Modifier.weight(1f),
            horizontalAlignment = Alignment.CenterHorizontally
        ) {
            Box(
                modifier = Modifier
                    .width(40.dp).height(36.dp)
                    .background(Color.White.copy(alpha = 0.15f), RoundedCornerShape(6.dp))
                    .border(2.dp, Color.White.copy(alpha = 0.4f), RoundedCornerShape(6.dp))
                    .clickable(
                        interactionSource = remember { MutableInteractionSource() },
                        indication = null,
                        onClick = onToggleMenu
                    ),
                contentAlignment = Alignment.Center
            ) {
                Text(
                    if (showInteractionMenu) "✕" else "…",
                    fontSize = 14.sp, fontWeight = FontWeight.Bold, color = Color.White
                )
            }
            Text(
                if (showInteractionMenu) "收起" else "更多",
                fontSize = 8.sp, color = Color.White.copy(alpha = 0.8f)
            )
        }
    }
}

@Composable
private fun InteractionButton(
    type: InteractionType,
    cooldownState: TimeEngine.CooldownState,
    onClick: (InteractionType) -> Unit,
    modifier: Modifier = Modifier
) {
    val remaining = cooldownState.remainingCooldown(type)
    val onCooldown = remaining > 0
    val btnColor = typeToColor(type)
    val context = LocalContext.current
    Column(modifier = modifier, horizontalAlignment = Alignment.CenterHorizontally) {
        Box(
            modifier = Modifier
                .width(40.dp).height(36.dp)
                .background(btnColor.copy(alpha = if (onCooldown) 0.06f else 0.2f), RoundedCornerShape(6.dp))
                .border(
                    width = if (onCooldown) 1.dp else 2.dp,
                    color = btnColor.copy(alpha = if (onCooldown) 0.2f else 0.6f),
                    shape = RoundedCornerShape(6.dp)
                )
                .clickable(
                    enabled = !onCooldown,
                    interactionSource = remember { MutableInteractionSource() },
                    indication = null,
                    onClick = { onClick(type) }
                ),
            contentAlignment = Alignment.Center
        ) {
            val resId = context.resources.getIdentifier(type.icon, "drawable", context.packageName)
            if (resId != 0) {
                Image(
                    painter = painterResource(id = resId),
                    contentDescription = type.displayName,
                    modifier = Modifier.size(24.dp),
                    alpha = if (onCooldown) 0.3f else 1f
                )
            }
            if (onCooldown) {
                Box(
                    Modifier.fillMaxWidth().height(36.dp)
                        .background(Color.Black.copy(alpha = 0.5f), RoundedCornerShape(6.dp)),
                    contentAlignment = Alignment.Center
                ) {
                    Text("${remaining.toInt() + 1}", fontSize = 11.sp, fontWeight = FontWeight.Bold, color = Color.White)
                }
            }
        }
        Text(
            type.displayName,
            fontSize = 8.sp,
            color = if (onCooldown) PixelPalette.mutedText else Color.White,
            lineHeight = 10.sp
        )
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
        Text(text, modifier = Modifier.padding(horizontal = 4.dp, vertical = 2.dp), fontSize = 8.sp, color = Color.White)
    }
}

@Composable
private fun StatusBadge(text: String, color: Color) {
    Surface(color = color, shape = RoundedCornerShape(1.dp)) {
        Text(text, modifier = Modifier.padding(horizontal = 4.dp, vertical = 2.dp), fontSize = 7.sp, color = Color.White)
    }
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

private fun splitIntoRows(items: List<InteractionType>, columns: Int): List<List<InteractionType>> {
    val rows = mutableListOf<List<InteractionType>>()
    var index = 0
    while (index < items.size) {
        val end = minOf(index + columns, items.size)
        rows.add(items.subList(index, end))
        index = end
    }
    return rows
}
