package com.plantpal.ui.components

import androidx.compose.animation.core.*
import androidx.compose.foundation.Canvas
import androidx.compose.foundation.Image
import androidx.compose.foundation.layout.size
import androidx.compose.runtime.*
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.platform.LocalContext
import androidx.compose.ui.res.painterResource
import androidx.compose.ui.unit.dp
import com.plantpal.model.SpriteMood
import kotlinx.coroutines.delay

/**
 * Frame-based sprite animation data, matching iOS Animations.swift exactly.
 * Each evolution level has different frame counts per mood state.
 */
data class SpriteAnimationData(
    val idleFrames: List<String>,
    val happyFrames: List<String>,
    val worriedFrames: List<String>,
    val sleepingFrames: List<String>,
    val sadFrames: List<String>,
    val frameDurationMs: Long
) {
    fun framesForMood(mood: SpriteMood): List<String> = when (mood) {
        SpriteMood.HAPPY -> happyFrames
        SpriteMood.EXCITED -> happyFrames
        SpriteMood.WORRIED -> worriedFrames
        SpriteMood.SAD -> sadFrames
        SpriteMood.SLEEPING -> sleepingFrames
    }

    companion object {
        fun framesFor(evolutionLevel: Int): SpriteAnimationData = when (evolutionLevel) {
            1 -> SpriteAnimationData(
                idleFrames = listOf("sprite_1_idle_1", "sprite_1_idle_2", "sprite_1_idle_3", "sprite_1_idle_4"),
                happyFrames = listOf("sprite_1_happy_1", "sprite_1_happy_2", "sprite_1_happy_3", "sprite_1_happy_4"),
                worriedFrames = listOf("sprite_1_worried_1", "sprite_1_worried_2"),
                sleepingFrames = listOf("sprite_1_sleep_1", "sprite_1_sleep_2", "sprite_1_sleep_3", "sprite_1_sleep_4"),
                sadFrames = listOf("sprite_1_sad_1", "sprite_1_sad_2", "sprite_1_sad_3", "sprite_1_sad_4"),
                frameDurationMs = 250L
            )
            2 -> SpriteAnimationData(
                idleFrames = listOf("sprite_2_idle_1", "sprite_2_idle_2", "sprite_2_idle_3", "sprite_2_idle_4", "sprite_2_idle_5", "sprite_2_idle_6"),
                happyFrames = listOf("sprite_2_happy_1", "sprite_2_happy_2", "sprite_2_happy_3", "sprite_2_happy_4", "sprite_2_happy_5", "sprite_2_happy_6"),
                worriedFrames = listOf("sprite_2_worried_1", "sprite_2_worried_2", "sprite_2_worried_3"),
                sleepingFrames = listOf("sprite_2_sleep_1", "sprite_2_sleep_2", "sprite_2_sleep_3", "sprite_2_sleep_4"),
                sadFrames = listOf("sprite_2_sad_1", "sprite_2_sad_2", "sprite_2_sad_3", "sprite_2_sad_4"),
                frameDurationMs = 200L
            )
            3 -> SpriteAnimationData(
                idleFrames = (1..6).map { "sprite_3_idle_$it" },
                happyFrames = (1..6).map { "sprite_3_happy_$it" },
                worriedFrames = (1..4).map { "sprite_3_worried_$it" },
                sleepingFrames = (1..4).map { "sprite_3_sleep_$it" },
                sadFrames = (1..4).map { "sprite_3_sad_$it" },
                frameDurationMs = 200L
            )
            4 -> SpriteAnimationData(
                idleFrames = (1..8).map { "sprite_4_idle_$it" },
                happyFrames = (1..8).map { "sprite_4_happy_$it" },
                worriedFrames = (1..4).map { "sprite_4_worried_$it" },
                sleepingFrames = (1..4).map { "sprite_4_sleep_$it" },
                sadFrames = (1..4).map { "sprite_4_sad_$it" },
                frameDurationMs = 150L
            )
            5 -> SpriteAnimationData(
                idleFrames = (1..8).map { "sprite_5_idle_$it" },
                happyFrames = (1..8).map { "sprite_5_happy_$it" },
                worriedFrames = (1..4).map { "sprite_5_worried_$it" },
                sleepingFrames = (1..4).map { "sprite_5_sleep_$it" },
                sadFrames = (1..4).map { "sprite_5_sad_$it" },
                frameDurationMs = 150L
            )
            else -> framesFor(1)
        }
    }
}

/**
 * Frame-based animated sprite view, cycling through PNG frames at the
 * specified duration, matching iOS AnimatedSpriteView behavior.
 */
@Composable
fun AnimatedSpriteView(
    evolutionLevel: Int,
    mood: SpriteMood,
    modifier: Modifier = Modifier
) {
    val animationData = remember(evolutionLevel) { SpriteAnimationData.framesFor(evolutionLevel) }
    val frames = animationData.framesForMood(mood)
    var currentFrameIndex by remember { mutableIntStateOf(0) }

    // Cycle through animation frames
    LaunchedEffect(frames) {
        currentFrameIndex = 0
        if (frames.size > 1) {
            while (true) {
                delay(animationData.frameDurationMs)
                currentFrameIndex = (currentFrameIndex + 1) % frames.size
            }
        }
    }

    val frameName = frames.getOrElse(currentFrameIndex) { frames.first() }
    val context = LocalContext.current
    val resId = remember(frameName) {
        context.resources.getIdentifier(frameName, "drawable", context.packageName)
    }

    if (resId != 0) {
        Image(
            painter = painterResource(id = resId),
            contentDescription = "Sprite level $evolutionLevel mood $mood",
            modifier = modifier.size(64.dp)
        )
    }
}

@Composable
fun PulsingGlowEffect(modifier: Modifier = Modifier) {
    val infiniteTransition = rememberInfiniteTransition(label = "glow")
    val alpha by infiniteTransition.animateFloat(
        initialValue = 0.2f,
        targetValue = 0.6f,
        animationSpec = infiniteRepeatable(
            animation = tween(1500, easing = EaseInOut),
            repeatMode = RepeatMode.Reverse
        ),
        label = "glowAlpha"
    )

    Canvas(modifier = modifier.size(80.dp)) {
        drawCircle(
            color = Color(0xFF4CAF50),
            radius = size.minDimension / 2,
            alpha = alpha
        )
    }
}