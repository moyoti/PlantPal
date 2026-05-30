package com.plantpal.services

import android.app.AlarmManager
import android.app.NotificationChannel
import android.app.NotificationManager
import android.app.PendingIntent
import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.os.Build
import androidx.core.app.NotificationCompat
import com.plantpal.MainActivity
import com.plantpal.R
import java.util.Calendar

class PlantPalNotificationManager(private val context: Context) {

    companion object {
        const val CHANNEL_PLANT_CARE = "plant_care"
        const val CHANNEL_EVOLUTION = "evolution"
        const val ACTION_WATER_REMINDER = "com.plantpal.WATER_REMINDER"
        const val ACTION_EVOLUTION = "com.plantpal.EVOLUTION"
        const val EXTRA_PLANT_NAME = "plant_name"
        const val EXTRA_NEW_STAGE = "new_stage"
    }

    private val notificationManager = context.getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager
    private val alarmManager = context.getSystemService(Context.ALARM_SERVICE) as AlarmManager

    fun createChannels() {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            val plantCareChannel = NotificationChannel(
                CHANNEL_PLANT_CARE,
                "植物照顾",
                NotificationManager.IMPORTANCE_DEFAULT
            ).apply {
                description = "浇水和光照提醒"
            }

            val evolutionChannel = NotificationChannel(
                CHANNEL_EVOLUTION,
                "进化通知",
                NotificationManager.IMPORTANCE_HIGH
            ).apply {
                description = "植物进化庆祝"
            }

            notificationManager.createNotificationChannels(listOf(plantCareChannel, evolutionChannel))
        }
    }

    fun scheduleWaterReminder(plantName: String, intervalHours: Int) {
        val intent = Intent(context, NotificationReceiver::class.java).apply {
            action = ACTION_WATER_REMINDER
            putExtra(EXTRA_PLANT_NAME, plantName)
        }

        val pendingIntent = PendingIntent.getBroadcast(
            context,
            1001,
            intent,
            PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
        )

        val intervalMs = intervalHours * 3600000L
        val triggerAtMs = System.currentTimeMillis() + intervalMs

        alarmManager.setRepeating(
            AlarmManager.RTC_WAKEUP,
            triggerAtMs,
            intervalMs,
            pendingIntent
        )
    }

    fun showEvolutionNotification(plantName: String, newStage: String) {
        val intent = Intent(context, MainActivity::class.java)
        val pendingIntent = PendingIntent.getActivity(
            context, 0, intent,
            PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
        )

        val notification = NotificationCompat.Builder(context, CHANNEL_EVOLUTION)
            .setSmallIcon(R.drawable.ic_launcher_foreground)
            .setContentTitle("🎉 $plantName 进化了！")
            .setContentText("恭喜！$plantName 成长到了「$newStage」阶段！")
            .setPriority(NotificationCompat.PRIORITY_HIGH)
            .setContentIntent(pendingIntent)
            .setAutoCancel(true)
            .build()

        notificationManager.notify(3001, notification)
    }

    fun cancelAllReminders() {
        // Cancel by recreating the same pending intents
        val waterIntent = Intent(context, NotificationReceiver::class.java).apply { action = ACTION_WATER_REMINDER }
        val waterPending = PendingIntent.getBroadcast(context, 1001, waterIntent, PendingIntent.FLAG_NO_CREATE or PendingIntent.FLAG_IMMUTABLE)
        waterPending?.let { alarmManager.cancel(it) }
    }
}

class NotificationReceiver : BroadcastReceiver() {
    override fun onReceive(context: Context, intent: Intent) {
        val notificationManager = context.getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager
        val plantName = intent.getStringExtra(PlantPalNotificationManager.EXTRA_PLANT_NAME) ?: "小绿"

        val notification = when (intent.action) {
            PlantPalNotificationManager.ACTION_WATER_REMINDER -> {
                NotificationCompat.Builder(context, PlantPalNotificationManager.CHANNEL_PLANT_CARE)
                    .setSmallIcon(R.drawable.ic_launcher_foreground)
                    .setContentTitle("🌿 $plantName 渴了")
                    .setContentText("快来给$plantName 浇水吧！")
                    .setAutoCancel(true)
                    .build()
            }
            else -> return
        }

        notificationManager.notify((System.currentTimeMillis() % 10000).toInt(), notification)
    }
}
