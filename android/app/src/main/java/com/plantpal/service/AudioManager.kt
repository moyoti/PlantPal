package com.plantpal.service

import android.content.Context
import android.media.AudioAttributes
import android.media.SoundPool
import android.media.MediaPlayer
import com.plantpal.model.InteractionType

object AudioManager {
    private var soundPool: SoundPool? = null
    private var soundMap = mutableMapOf<String, Int>()
    private var bgmPlayer: MediaPlayer? = null
    private var isMusicOn = true
    private var isSfxOn = true
    private var isInitialized = false

    fun init(context: Context) {
        if (isInitialized) return
        isInitialized = true

        val attrs = AudioAttributes.Builder()
            .setUsage(AudioAttributes.USAGE_GAME)
            .setContentType(AudioAttributes.CONTENT_TYPE_SONIFICATION)
            .build()
        soundPool = SoundPool.Builder().setMaxStreams(6).setAudioAttributes(attrs).build()

        val sfxNames = listOf(
            "sfx_water", "sfx_light", "sfx_fertilize", "sfx_touch", "sfx_pet",
            "sfx_talk", "sfx_sing", "sfx_heal", "sfx_play", "sfx_shield",
            "sfx_dance", "sfx_purchase", "sfx_equip", "sfx_tap"
        )
        for (name in sfxNames) {
            val resId = context.resources.getIdentifier(name, "raw", context.packageName)
            if (resId != 0) {
                soundMap[name] = soundPool!!.load(context, resId, 1)
            }
        }
    }

    fun startBGM(context: Context) {
        if (!isMusicOn) return
        if (bgmPlayer?.isPlaying == true) return
        val resId = context.resources.getIdentifier("bgm_garden", "raw", context.packageName)
        if (resId == 0) return
        bgmPlayer = MediaPlayer.create(context, resId).apply {
            isLooping = true
            setVolume(0.4f, 0.4f)
            start()
        }
    }

    fun stopBGM() {
        bgmPlayer?.stop()
        bgmPlayer?.release()
        bgmPlayer = null
    }

    fun toggleMusic() {
        isMusicOn = !isMusicOn
        if (isMusicOn) {
            // caller must call startBGM with context
        } else {
            stopBGM()
        }
    }

    fun setMusicOn(on: Boolean) {
        isMusicOn = on
        if (!on) stopBGM()
    }

    fun setSfxOn(on: Boolean) {
        isSfxOn = on
    }

    fun getMusicOn(): Boolean = isMusicOn
    fun getSfxOn(): Boolean = isSfxOn

    fun playSFX(context: Context, name: String) {
        if (!isSfxOn) return
        init(context)
        val soundId = soundMap["sfx_$name"] ?: return
        soundPool?.play(soundId, 0.6f, 0.6f, 1, 0, 1f)
    }

    fun playInteractionSFX(context: Context, type: InteractionType) {
        val name = when (type) {
            InteractionType.WATER -> "water"
            InteractionType.LIGHT -> "light"
            InteractionType.FERTILIZE -> "fertilize"
            InteractionType.TOUCH -> "touch"
            InteractionType.PET -> "pet"
            InteractionType.TALK -> "talk"
            InteractionType.SING -> "sing"
            InteractionType.HEAL -> "heal"
            InteractionType.PLAY -> "play"
            InteractionType.SHIELD -> "shield"
            InteractionType.DANCE -> "dance"
        }
        playSFX(context, name)
    }

    fun playPurchase(context: Context) { playSFX(context, "purchase") }
    fun playEquip(context: Context) { playSFX(context, "equip") }
    fun playTap(context: Context) { playSFX(context, "tap") }

    fun release() {
        soundPool?.release()
        soundPool = null
        bgmPlayer?.release()
        bgmPlayer = null
        isInitialized = false
    }
}
