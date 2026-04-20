package com.grandstakes.ui.main

import androidx.compose.foundation.layout.*
import androidx.compose.foundation.rememberScrollState
import androidx.compose.foundation.verticalScroll
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.outlined.AccountCircle
import androidx.compose.material.icons.outlined.Diamond
import androidx.compose.material.icons.outlined.Timer
import androidx.compose.material3.*
import androidx.compose.runtime.*
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.text.font.FontStyle
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.text.TextStyle
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import androidx.hilt.navigation.compose.hiltViewModel
import com.grandstakes.ui.theme.GoldPrimary

@Composable
fun ConfigScreen(
    onLogout: () -> Unit,
    viewModel: LobbyViewModel = hiltViewModel()
) {
    val user by viewModel.currentUser.collectAsState()

    Scaffold(
        containerColor = Color.Black
    ) { padding ->
        Column(
            modifier = Modifier
                .fillMaxSize()
                .padding(padding)
                .padding(24.dp)
                .verticalScroll(rememberScrollState())
        ) {
            Text("Member Settings", style = MaterialTheme.typography.displayLarge.copy(color = GoldPrimary))
            Text("Tailor your high-stakes experience.", style = TextStyle(color = MaterialTheme.colorScheme.onSurfaceVariant, fontStyle = FontStyle.Italic))
            
            Spacer(modifier = Modifier.height(32.dp))
            
            SettingsSection("Account Essentials", Icons.Outlined.AccountCircle) {
                LabelValue("FULL LEGAL NAME", user?.name ?: "Guest")
                LabelValue("MEMBERSHIP TIER", if (user?.isVip == true) "Platinum Member" else "Standard Member")
                LabelValue("EMAIL ADDRESS", user?.email ?: "N/A")
            }
            
            Spacer(modifier = Modifier.height(24.dp))
            
            SettingsSection("Player Care", Icons.Outlined.Timer) {
                Text("We prioritize your sophisticated play and well-being.", color = MaterialTheme.colorScheme.onSurfaceVariant, fontSize = 12.sp)
                Spacer(modifier = Modifier.height(16.dp))
                ActionRow("Time-Out (Cooling Off)")
                ActionRow("Self-Exclusion")
            }
            
            Spacer(modifier = Modifier.height(48.dp))
            
            TextButton(
                onClick = onLogout,
                modifier = Modifier.fillMaxWidth()
            ) {
                Text("SIGN OUT", style = TextStyle(color = MaterialTheme.colorScheme.onSurfaceVariant, fontWeight = FontWeight.Bold, letterSpacing = 2.sp))
            }
        }
    }
}

@Composable
fun SettingsSection(title: String, icon: androidx.compose.ui.graphics.vector.ImageVector, content: @Composable ColumnScope.() -> Unit) {
    Surface(
        color = MaterialTheme.colorScheme.surfaceVariant,
        shape = androidx.compose.foundation.shape.RoundedCornerShape(4.dp),
        modifier = Modifier.fillMaxWidth()
    ) {
        Column(Modifier.padding(24.dp)) {
            Row(verticalAlignment = Alignment.CenterVertically) {
                Icon(icon, contentDescription = null, tint = GoldPrimary, modifier = Modifier.size(20.dp))
                Spacer(modifier = Modifier.width(8.dp))
                Text(title, style = MaterialTheme.typography.headlineMedium.copy(color = GoldPrimary))
            }
            Spacer(modifier = Modifier.height(24.dp))
            content()
        }
    }
}

@Composable
fun LabelValue(label: String, value: String) {
    Column(Modifier.padding(bottom = 16.dp)) {
        Text(label, style = MaterialTheme.typography.labelSmall.copy(color = MaterialTheme.colorScheme.onSurfaceVariant))
        Text(value, color = Color.White, fontWeight = FontWeight.Bold)
        HorizontalDivider(Modifier.padding(top = 4.dp), color = MaterialTheme.colorScheme.surface)
    }
}

@Composable
fun ActionRow(title: String) {
    Surface(
        color = MaterialTheme.colorScheme.surface,
        modifier = Modifier.fillMaxWidth().padding(vertical = 4.dp),
        shape = androidx.compose.foundation.shape.RoundedCornerShape(4.dp)
    ) {
        Row(Modifier.padding(12.dp), horizontalArrangement = Arrangement.SpaceBetween) {
            Text(title, color = Color.White, fontSize = 12.sp)
            Icon(Icons.Outlined.Timer, contentDescription = null, tint = GoldPrimary, modifier = Modifier.size(16.dp))
        }
    }
}
