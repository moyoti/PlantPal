package com.plantpal

import android.os.Bundle
import androidx.activity.ComponentActivity
import androidx.activity.compose.setContent
import androidx.activity.enableEdgeToEdge
import androidx.compose.foundation.Image
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.size
import androidx.compose.material3.*
import androidx.compose.runtime.*
import androidx.compose.ui.Modifier
import androidx.compose.ui.res.painterResource
import androidx.compose.ui.platform.LocalContext
import androidx.compose.ui.unit.dp
import androidx.navigation.compose.NavHost
import androidx.navigation.compose.composable
import androidx.navigation.compose.currentBackStackEntryAsState
import androidx.navigation.compose.rememberNavController
import com.plantpal.data.entity.AchievementEntity
import com.plantpal.data.entity.PetEntity
import com.plantpal.data.entity.PlantEntity
import com.plantpal.data.entity.SpriteEntity
import com.plantpal.data.entity.PlayerWalletEntity
import com.plantpal.engine.TimeEngine
import com.plantpal.model.InteractionType
import com.plantpal.model.PetType
import com.plantpal.model.DecorationItem
import com.plantpal.service.AudioManager
import com.plantpal.ui.screens.*
import com.plantpal.ui.theme.PlantPalTheme

class MainActivity : ComponentActivity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        enableEdgeToEdge()
        setContent {
            PlantPalTheme {
                PlantPalApp()
            }
        }
    }
}

@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun PlantPalApp() {
    val context = LocalContext.current
    val navController = rememberNavController()
    val navBackStackEntry by navController.currentBackStackEntryAsState()
    val currentRoute = navBackStackEntry?.destination?.route

    var plant by remember { mutableStateOf<PlantEntity?>(null) }
    var sprite by remember { mutableStateOf<SpriteEntity?>(null) }
    var wallet by remember { mutableStateOf<PlayerWalletEntity?>(null) }
    var pets by remember { mutableStateOf<List<PetEntity>>(emptyList()) }
    var achievements by remember { mutableStateOf<List<AchievementEntity>>(emptyList()) }
    var ownedDecorationIds by remember { mutableStateOf<Set<String>>(emptySet()) }
    val timeEngine = remember { TimeEngine() }

    LaunchedEffect(Unit) {
        if (plant == null) {
            plant = PlantEntity()
            sprite = SpriteEntity()
            wallet = PlayerWalletEntity()
        }
    }

    LaunchedEffect(plant) {
        if (plant != null && sprite != null) {
            val (updatedPlant, updatedSprite, updatedWallet) = timeEngine.calculateTimeEffects(plant!!, sprite!!, wallet)
            plant = updatedPlant
            sprite = updatedSprite
            if (updatedWallet != null) wallet = updatedWallet
        }
        AudioManager.startBGM(context)
    }

    Scaffold(
        modifier = Modifier.fillMaxSize(),
        bottomBar = {
            NavigationBar {
                NavigationBarItem(
                    icon = { Image(painter = painterResource(id = R.drawable.tab_garden), contentDescription = "花园", modifier = Modifier.size(24.dp)) },
                    label = { Text("花园") },
                    selected = currentRoute == "garden",
                    onClick = { navController.navigate("garden") { popUpTo("garden") { inclusive = true } } }
                )
                NavigationBarItem(
                    icon = { Image(painter = painterResource(id = R.drawable.tab_collection), contentDescription = "收藏", modifier = Modifier.size(24.dp)) },
                    label = { Text("收藏") },
                    selected = currentRoute == "collection",
                    onClick = { navController.navigate("collection") { popUpTo("garden") } }
                )
                NavigationBarItem(
                    icon = { Image(painter = painterResource(id = R.drawable.tab_settings), contentDescription = "设置", modifier = Modifier.size(24.dp)) },
                    label = { Text("设置") },
                    selected = currentRoute == "settings",
                    onClick = { navController.navigate("settings") { popUpTo("garden") } }
                )
            }
        }
    ) { innerPadding ->
        NavHost(navController = navController, startDestination = "garden", Modifier.fillMaxSize()) {
            composable("garden") {
                GardenScreen(
                    plant = plant,
                    sprite = sprite,
                    wallet = wallet,
                    pets = pets,
                    cooldownState = timeEngine.cooldownState,
                    onInteraction = { type ->
                        if (plant != null && sprite != null) {
                            val (p, s, w) = timeEngine.applyInteraction(plant!!, sprite!!, type, wallet)
                            plant = p
                            sprite = s
                            if (w != null) wallet = w
                            AudioManager.playInteractionSFX(context, type)
                        }
                    },
                    onSpriteTap = {
                        if (sprite != null) {
                            sprite = sprite!!.copy(happiness = (sprite!!.happiness + 0.03).coerceAtMost(1.0))
                            AudioManager.playTap(context)
                        }
                    },
                    onPetTap = { pet ->
                        val idx = pets.indexOf(pet)
                        if (idx >= 0) {
                            pets = pets.toMutableList().also {
                                it[idx] = pet.copy(friendshipLevel = (pet.friendshipLevel + 0.03).coerceAtMost(1.0))
                            }
                            AudioManager.playSFX(context, "pet")
                        }
                    }
                )
            }
            composable("collection") {
                CollectionScreen(
                    plant = plant,
                    sprite = sprite,
                    wallet = wallet,
                    pets = pets,
                    achievements = achievements,
                    onPurchasePet = { petType ->
                        if (wallet != null && wallet!!.coins >= petType.unlockCost) {
                            wallet = wallet!!.copy(coins = wallet!!.coins - petType.unlockCost)
                            pets = pets + PetEntity(petTypeRaw = petType.name, isOwned = true, name = petType.displayName)
                        }
                    },
                    onNavigateToDecorationStore = { navController.navigate("decoration_store") }
                )
            }
            composable("settings") {
                SettingsScreen(plant) {
                    plant = PlantEntity()
                    sprite = SpriteEntity()
                    wallet = PlayerWalletEntity()
                }
            }
            composable("decoration_store") {
                DecorationStoreScreen(
                    coins = wallet?.coins ?: 0,
                    ownedItemIds = ownedDecorationIds,
                    equippedPot = plant?.potStyle ?: "default",
                    equippedBg = plant?.backgroundScene ?: "garden",
                    equippedOutfit = sprite?.outfit ?: "default",
                    onPurchase = { item ->
                        if (wallet != null && wallet!!.coins >= item.cost) {
                            wallet = wallet!!.copy(coins = wallet!!.coins - item.cost)
                            ownedDecorationIds = ownedDecorationIds + item.id
                            AudioManager.playPurchase(context)
                        }
                    },
                    onEquip = { item ->
                        when (item.category) {
                            com.plantpal.model.DecorationCategory.POT -> {
                                val potName = item.assetName.removePrefix("pot_")
                                if (plant != null) plant = plant!!.copy(potStyle = potName)
                            }
                            com.plantpal.model.DecorationCategory.BACKGROUND -> {
                                val bgName = item.assetName.removePrefix("bg_")
                                if (plant != null) plant = plant!!.copy(backgroundScene = bgName)
                            }
                            com.plantpal.model.DecorationCategory.OUTFIT -> {
                                val outfitName = item.assetName.removePrefix("outfit_")
                                if (sprite != null) sprite = sprite!!.copy(outfit = outfitName)
                            }
                        }
                        AudioManager.playEquip(context)
                    }
                )
            }
        }
    }
}