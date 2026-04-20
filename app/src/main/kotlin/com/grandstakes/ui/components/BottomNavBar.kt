package com.grandstakes.ui.components

import androidx.compose.foundation.background
import androidx.compose.foundation.layout.*
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.AccountCircle
import androidx.compose.material.icons.filled.Casino
import androidx.compose.material.icons.filled.GridView
import androidx.compose.material.icons.filled.History
import androidx.compose.material3.*
import androidx.compose.runtime.Composable
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.graphics.vector.ImageVector
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import com.grandstakes.ui.theme.GoldPrimary

@Composable
fun GrandStakesBottomNavBar(
    currentRoute: String?,
    onNavigate: (String) -> Unit
) {
    NavigationBar(
        containerColor = Color(0xFF0A0A0A),
        tonalElevation = 8.dp,
        modifier = Modifier.height(72.dp)
    ) {
        BottomNavItem(
            selected = currentRoute == "lobby",
            onClick = { onNavigate("lobby") },
            icon = Icons.Default.GridView,
            label = "LOBBY"
        )
        BottomNavItem(
            selected = currentRoute == "tables" || currentRoute == "roulette" || currentRoute == "blackjack" || currentRoute == "baccarat",
            onClick = { onNavigate("tables") },
            icon = Icons.Default.Casino,
            label = "TABLES"
        )
        BottomNavItem(
            selected = currentRoute == "slots_list" || currentRoute?.startsWith("slot_game") == true,
            onClick = { onNavigate("slots_list") },
            icon = Icons.Default.Casino, // Should ideally be a slot icon
            label = "SLOTS"
        )
        BottomNavItem(
            selected = currentRoute == "ledger",
            onClick = { onNavigate("ledger") },
            icon = Icons.Default.History,
            label = "LEDGER"
        )
    }
}

@Composable
private fun RowScope.BottomNavItem(
    selected: Boolean,
    onClick: () -> Unit,
    icon: ImageVector,
    label: String
) {
    NavigationBarItem(
        selected = selected,
        onClick = onClick,
        icon = {
            Icon(
                imageVector = icon,
                contentDescription = label,
                tint = if (selected) GoldPrimary else Color.Gray,
                modifier = Modifier.size(24.dp)
            )
        },
        label = {
            Text(
                text = label,
                style = MaterialTheme.typography.labelSmall.copy(
                    fontSize = 8.sp,
                    color = if (selected) GoldPrimary else Color.Gray,
                    letterSpacing = 1.sp
                )
            )
        },
        colors = NavigationBarItemDefaults.colors(
            indicatorColor = Color.Transparent
        )
    )
}
