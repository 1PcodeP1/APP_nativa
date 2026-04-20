package com.grandstakes.ui.main

import androidx.compose.foundation.layout.padding
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.Casino
import androidx.compose.material.icons.filled.Home
import androidx.compose.material.icons.filled.List
import androidx.compose.material.icons.filled.Settings
import androidx.compose.material3.*
import androidx.compose.runtime.*
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.graphics.vector.ImageVector
import androidx.navigation.NavHostController
import androidx.navigation.compose.NavHost
import androidx.navigation.compose.composable
import androidx.navigation.compose.currentBackStackEntryAsState
import androidx.navigation.compose.rememberNavController
import com.grandstakes.ui.games.*
import com.grandstakes.ui.theme.GoldPrimary

sealed class Screen(val route: String, val icon: ImageVector, val label: String) {
    object Lobby : Screen("lobby", Icons.Default.Home, "Lobby")
    object Tables : Screen("tables", Icons.Default.Casino, "Tables")
    object Ledger : Screen("ledger", Icons.Default.List, "Ledger")
    object Config : Screen("config", Icons.Default.Settings, "Config")
}

@Composable
fun MainScreen(
    onLogout: () -> Unit
) {
    val navController = rememberNavController()
    val navBackStackEntry by navController.currentBackStackEntryAsState()
    val currentRoute = navBackStackEntry?.destination?.route

    Scaffold(
        bottomBar = {
            if (shouldShowBottomBar(currentRoute)) {
                NavigationBar(containerColor = Color(0xFF0D0D0D)) {
                    val items = listOf(Screen.Lobby, Screen.Tables, Screen.Ledger, Screen.Config)
                    items.forEach { screen ->
                        NavigationBarItem(
                            icon = { Icon(screen.icon, contentDescription = null) },
                            label = { Text(screen.label) },
                            selected = currentRoute == screen.route,
                            onClick = {
                                navController.navigate(screen.route) {
                                    popUpTo(navController.graph.startDestinationId)
                                    launchSingleTop = true
                                }
                            },
                            colors = NavigationBarItemDefaults.colors(
                                selectedIconColor = GoldPrimary,
                                unselectedIconColor = Color.Gray,
                                selectedTextColor = GoldPrimary,
                                indicatorColor = Color.Transparent
                            )
                        )
                    }
                }
            }
        }
    ) { padding ->
        NavHost(
            navController = navController,
            startDestination = Screen.Lobby.route,
            modifier = Modifier.padding(padding)
        ) {
            composable(Screen.Lobby.route) { LobbyScreen(onNavigateToGame = { navController.navigate(it) }) }
            composable(Screen.Ledger.route) { TransactionsScreen(onNavigateBack = { navController.popBackStack() }) }
            composable(Screen.Config.route) { ConfigScreen(onLogout = onLogout) }
            
            // Game Routes
            composable("roulette") { RouletteScreen(onNavigateBack = { navController.popBackStack() }) }
            composable("blackjack") { BlackjackScreen(onNavigateBack = { navController.popBackStack() }) }
            composable("slots") { SlotGameScreen(
                slotTheme = SlotTheme("Grand Pit", listOf("💰", "💎", "7️⃣", "🔔", "🌟"), GoldPrimary),
                onNavigateBack = { navController.popBackStack() }
            ) }
            composable("baccarat") { BaccaratScreen(onNavigateBack = { navController.popBackStack() }) }
        }
    }
}

fun shouldShowBottomBar(route: String?): Boolean {
    return route in listOf(Screen.Lobby.route, Screen.Ledger.route, Screen.Config.route)
}
