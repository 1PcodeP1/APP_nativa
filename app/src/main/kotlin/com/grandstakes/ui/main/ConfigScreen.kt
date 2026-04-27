package com.grandstakes.ui.main

import androidx.compose.foundation.BorderStroke
import androidx.compose.foundation.background
import androidx.compose.foundation.clickable
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.lazy.LazyColumn
import androidx.compose.foundation.rememberScrollState
import androidx.compose.foundation.shape.CircleShape
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.foundation.verticalScroll
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.*
import androidx.compose.material.icons.outlined.*
import androidx.compose.material3.*
import androidx.compose.runtime.*
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.graphics.vector.ImageVector
import androidx.compose.ui.text.font.FontStyle
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import androidx.hilt.navigation.compose.hiltViewModel
import com.grandstakes.ui.theme.GoldPrimary
import com.grandstakes.ui.theme.OnSurfaceVariant

@Composable
fun ConfigScreen(
    onLogout: () -> Unit,
    viewModel: LobbyViewModel = hiltViewModel()
) {
    val user by viewModel.currentUser.collectAsState()

    LazyColumn(
        modifier = Modifier
            .fillMaxSize()
            .background(Color.Black)
    ) {
        item {
            Column(
                modifier = Modifier
                    .fillMaxWidth()
                    .padding(vertical = 48.dp),
                horizontalAlignment = Alignment.CenterHorizontally
            ) {
                Surface(
                    modifier = Modifier.size(100.dp),
                    color = Color(0xFF1E1E1E),
                    shape = CircleShape,
                    border = BorderStroke(1.dp, GoldPrimary.copy(alpha = 0.5f))
                ) {
                    Box(contentAlignment = Alignment.Center) {
                        Icon(Icons.Default.Person, contentDescription = null, tint = GoldPrimary, modifier = Modifier.size(48.dp))
                    }
                }
                Spacer(Modifier.height(16.dp))
                Text(
                    user?.username?.uppercase() ?: "PRESTIGIOUS MEMBER",
                    style = MaterialTheme.typography.titleLarge.copy(color = Color.White, letterSpacing = 2.sp)
                )
                Text(
                    "PLATINUM CIRCLE MEMBER",
                    style = MaterialTheme.typography.labelSmall.copy(color = GoldPrimary, letterSpacing = 1.sp)
                )
            }
        }

        item {
            Column(modifier = Modifier.padding(horizontal = 24.dp)) {
                Text(
                    "ACCOUNT PREFERENCES",
                    style = MaterialTheme.typography.labelSmall.copy(color = OnSurfaceVariant, letterSpacing = 2.sp)
                )
                Spacer(Modifier.height(16.dp))
                SettingsItem(Icons.Default.Security, "SECURITY & BEYOND")
                SettingsItem(Icons.Default.Notifications, "NOTIFICATION ELITE")
                SettingsItem(Icons.Default.Translate, "LANGUAGE & LOCALE")
                SettingsItem(Icons.Default.Help, "CONCIERGE SUPPORT")
                
                Spacer(Modifier.height(32.dp))
                
                Text(
                    "SESSIONS",
                    style = MaterialTheme.typography.labelSmall.copy(color = OnSurfaceVariant, letterSpacing = 2.sp)
                )
                Spacer(Modifier.height(16.dp))
                SettingsItem(
                    Icons.Default.Logout, 
                    "EXIT THE ATELIER", 
                    onClick = onLogout,
                    tint = Color.White
                )
            }
        }
        
        item { Spacer(Modifier.height(96.dp)) }
    }
}

@Composable
fun SettingsItem(
    icon: ImageVector, 
    title: String, 
    onClick: () -> Unit = {},
    tint: Color = GoldPrimary
) {
    Surface(
        modifier = Modifier
            .fillMaxWidth()
            .clickable(onClick = onClick)
            .padding(vertical = 12.dp),
        color = Color.Transparent
    ) {
        Row(verticalAlignment = Alignment.CenterVertically) {
            Icon(icon, contentDescription = null, tint = tint, modifier = Modifier.size(20.dp))
            Spacer(Modifier.width(16.dp))
            Text(
                title, 
                style = MaterialTheme.typography.bodyLarge.copy(color = Color.White, fontSize = 14.sp, fontWeight = FontWeight.Bold)
            )
            Spacer(Modifier.weight(1f))
            Icon(Icons.Default.ChevronRight, contentDescription = null, tint = OnSurfaceVariant, modifier = Modifier.size(16.dp))
        }
    }
}
