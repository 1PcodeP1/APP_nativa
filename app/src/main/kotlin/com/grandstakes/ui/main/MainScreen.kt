package com.grandstakes.ui.main

import androidx.compose.foundation.layout.padding
import androidx.compose.material3.*
import androidx.compose.runtime.*
import androidx.compose.ui.Modifier
import androidx.hilt.navigation.compose.hiltViewModel
import androidx.navigation.compose.NavHost
import androidx.navigation.compose.composable
import androidx.navigation.compose.currentBackStackEntryAsState
import androidx.navigation.compose.rememberNavController
import com.grandstakes.ui.games.*
import com.grandstakes.ui.components.GrandStakesAppBar
import com.grandstakes.ui.components.GrandStakesBottomNavBar

@Composable
fun MainScreen(
    onLogout: () -> Unit,
    viewModel: LobbyViewModel = hiltViewModel()
) {
    val navController = rememberNavController()
    val navBackStackEntry by navController.currentBackStackEntryAsState()
    val currentRoute = navBackStackEntry?.destination?.route
    val user by viewModel.currentUser.collectAsState()

    Scaffold(
        topBar = {
            if (shouldShowTopBar(currentRoute)) {
                GrandStakesAppBar(
                    balance = user?.balance ?: 0,
                    onNavigateToConfig = { navController.navigate("config") },
                    onNavigateToBanking = { navController.navigate("ledger") },
                    onLogout = onLogout,
                    title = getTitleForRoute(currentRoute)
                )
            }
        },
        bottomBar = {
            if (shouldShowBottomBar(currentRoute)) {
                GrandStakesBottomNavBar(
                    currentRoute = currentRoute,
                    onNavigate = { route ->
                        navController.navigate(route) {
                            popUpTo("lobby") { saveState = true }
                            launchSingleTop = true
                            restoreState = true
                        }
                    }
                )
            }
        }
    ) { padding ->
        NavHost(
            navController = navController,
            startDestination = "lobby",
            modifier = Modifier.padding(padding)
        ) {
            composable("lobby") { 
                LobbyScreen(
                    onNavigateToGame = { route -> 
                        if (route == "slots") navController.navigate("slots_list")
                        else navController.navigate(route)
                    }
                ) 
            }
            composable("ledger") { TransactionsScreen(onNavigateBack = { navController.popBackStack() }) }
            composable("config") { ConfigScreen(onLogout = onLogout) }
            
            // Slots Listing
            composable("slots_list") { 
                SlotsScreen(
                    onNavigateBack = { navController.popBackStack() },
                    onPlaySlot = { theme ->
                        // We will update SlotGameScreen to accept these parameters or use a Shared ViewModel
                        navController.navigate("slot_game/${theme.title}")
                    }
                ) 
            }

            // Game Routes
            composable("roulette") { RouletteScreen(onNavigateBack = { navController.popBackStack() }) }
            composable("blackjack") { BlackjackScreen(onNavigateBack = { navController.popBackStack() }) }
            composable("slot_game/{themeTitle}") { backStackEntry ->
                val themeTitle = backStackEntry.arguments?.getString("themeTitle") ?: "Grand Pit"
                // Resolve theme logic here or in ViewModel
                SlotGameScreen(
                    themeTitle = themeTitle,
                    onNavigateBack = { navController.popBackStack() }
                )
            }
            composable("baccarat") { BaccaratScreen(onNavigateBack = { navController.popBackStack() }) }
        }
    }
}

fun shouldShowTopBar(route: String?): Boolean {
    // Show top bar on primary screens and non-minimized game views
    return route != null
}

fun shouldShowBottomBar(route: String?): Boolean {
    // Show bottom bar on primary screens
    return route in listOf("lobby", "ledger", "config", "slots_list")
}

fun getTitleForRoute(route: String?): String {
    return when {
        route == "blackjack" -> "BLACKJACK"
        route == "roulette" -> "ROULETTE"
        route == "baccarat" -> "BACCARAT"
        route == "ledger" -> "BANKING"
        route == "config" -> "SETTINGS"
        route == "slots_list" -> "SLOT MACHINES"
        route?.startsWith("slot_game") == true -> "SLOTS"
        else -> "GRAND STAKES"
    }
}
