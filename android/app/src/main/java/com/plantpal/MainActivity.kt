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
import androidx.compose.ui.unit.dp
import androidx.navigation.compose.NavHost
import androidx.navigation.compose.composable
import androidx.navigation.compose.currentBackStackEntryAsState
import androidx.navigation.compose.rememberNavController
import com.plantpal.data.entity.PlantEntity
import com.plantpal.data.entity.SpriteEntity
import com.plantpal.data.entity.PlayerWalletEntity
import com.plantpal.engine.TimeEngine
import com.plantpal.model.InteractionType
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
    val navController = rememberNavController()
    val navBackStackEntry by navController.currentBackStackEntryAsState()
    val currentRoute = navBackStackEntry?.destination?.route

    var plant by remember { mutableStateOf<PlantEntity?>(null) }
    var sprite by remember { mutableStateOf<SpriteEntity?>(null) }
    var wallet by remember { mutableStateOf<PlayerWalletEntity?>(null) }
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
                    cooldownState = timeEngine.cooldownState,
                    onInteraction = { type ->
                        if (plant != null && sprite != null) {
                            val (p, s, w) = timeEngine.applyInteraction(plant!!, sprite!!, type, wallet)
                            plant = p
                            sprite = s
                            if (w != null) wallet = w
                        }
                    }
                )
            }
            composable("collection") {
                CollectionScreen(plant, sprite)
            }
            composable("settings") {
                SettingsScreen(plant) {
                    plant = PlantEntity()
                    sprite = SpriteEntity()
                    wallet = PlayerWalletEntity()
                }
            }
        }
    }
}