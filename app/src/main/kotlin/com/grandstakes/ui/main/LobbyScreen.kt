package com.grandstakes.ui.main

import androidx.compose.foundation.BorderStroke
import androidx.compose.foundation.Image
import androidx.compose.foundation.background
import androidx.compose.foundation.clickable
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.lazy.LazyColumn
import androidx.compose.foundation.shape.CircleShape
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.outlined.Diamond
import androidx.compose.material.icons.filled.Menu
import androidx.compose.material3.*
import androidx.compose.runtime.*
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.graphics.Brush
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.layout.ContentScale
import androidx.compose.ui.res.painterResource
import androidx.compose.ui.text.TextStyle
import androidx.compose.ui.text.font.FontStyle
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import androidx.hilt.navigation.compose.hiltViewModel
import com.grandstakes.R
import com.grandstakes.ui.theme.GoldPrimary

@Composable
fun LobbyScreen(
    onNavigateToGame: (String) -> Unit,
    viewModel: LobbyViewModel = hiltViewModel()
) {
    val user by viewModel.currentUser.collectAsState()

    Scaffold(
        containerColor = Color.Black,
        topBar = {
            LobbyTopBar(balance = user?.balance ?: 0)
        }
    ) { padding ->
        LazyColumn(
            modifier = Modifier
                .fillMaxSize()
                .padding(padding)
        ) {
            item { LobbyHero() }
            item { LobbyStats() }
            item { LobbyGameTitle("THE PIT FLOOR") }
            item {
                Row(Modifier.padding(horizontal = 24.dp)) {
                    GameCard(
                        title = "Baccarat",
                        subtitle = "Classic Punto Banco",
                        imageRes = R.drawable.baccarat_cover,
                        modifier = Modifier.weight(1f),
                        onClick = { onNavigateToGame("baccarat") }
                    )
                    Spacer(Modifier.width(16.dp))
                    GameCard(
                        title = "Blackjack",
                        subtitle = "The Royale Table",
                        imageRes = R.drawable.blackjack_cover,
                        modifier = Modifier.weight(1f),
                        onClick = { onNavigateToGame("blackjack") }
                    )
                }
            }
            item { Spacer(Modifier.height(16.dp)) }
            item {
                Row(Modifier.padding(horizontal = 24.dp)) {
                    GameCard(
                        title = "Roulette",
                        subtitle = "Grand Wheel",
                        imageRes = R.drawable.roulette_cover,
                        modifier = Modifier.weight(1f),
                        onClick = { onNavigateToGame("roulette") }
                    )
                    Spacer(Modifier.width(16.dp))
                    GameCard(
                        title = "Slots",
                        subtitle = "Atelier Reels",
                        imageRes = R.drawable.slots_cover,
                        modifier = Modifier.weight(1f),
                        onClick = { onNavigateToGame("slots") }
                    )
                }
            }
            item { Spacer(Modifier.height(48.dp)) }
            item { VipBanner(isVip = user?.isVip ?: false) }
            item { Spacer(Modifier.height(48.dp)) }
        }
    }
}

@Composable
fun LobbyTopBar(balance: Int) {
    Row(
        modifier = Modifier
            .fillMaxWidth()
            .padding(16.dp),
        verticalAlignment = Alignment.CenterVertically,
        horizontalArrangement = Arrangement.SpaceBetween
    ) {
        Row(verticalAlignment = Alignment.CenterVertically) {
            Box(
                modifier = Modifier
                    .size(32.dp)
                    .clip(CircleShape)
                    .background(GoldPrimary)
            )
            Spacer(Modifier.width(12.dp))
            Column {
                Text("GRAND", style = MaterialTheme.typography.labelSmall.copy(color = GoldPrimary, fontStyle = FontStyle.Italic, fontWeight = FontWeight.Bold))
                Text("STAKES", style = MaterialTheme.typography.labelSmall.copy(color = GoldPrimary, fontStyle = FontStyle.Italic, fontWeight = FontWeight.Bold))
            }
        }
        
        Column(horizontalAlignment = Alignment.End) {
            Text("AVAILABLE", style = TextStyle(color = MaterialTheme.colorScheme.onSurfaceVariant, fontSize = 8.sp))
            Text("BALANCE", style = TextStyle(color = MaterialTheme.colorScheme.onSurfaceVariant, fontSize = 8.sp))
            Text("$${balance}", style = TextStyle(color = GoldPrimary, fontWeight = FontWeight.Bold, fontSize = 12.sp))
        }
    }
}

@Composable
fun LobbyHero() {
    Box(
        modifier = Modifier
            .fillMaxWidth()
            .height(280.dp)
    ) {
        Image(
            painter = painterResource(id = R.drawable.lobby_hero),
            contentDescription = null,
            modifier = Modifier.fillMaxSize(),
            contentScale = ContentScale.Crop
        )
        Box(
            modifier = Modifier
                .fillMaxSize()
                .background(Brush.verticalGradient(listOf(Color.Transparent, Color.Black)))
        )
        Column(
            modifier = Modifier
                .align(Alignment.BottomStart)
                .padding(24.dp)
        ) {
            Text("PRIVATE", style = MaterialTheme.typography.labelSmall.copy(color = GoldPrimary))
            Text("ATELIER", style = MaterialTheme.typography.displayLarge.copy(color = Color.White))
        }
    }
}

@Composable
fun GameCard(title: String, subtitle: String, imageRes: Int, modifier: Modifier, onClick: () -> Unit) {
    Surface(
        modifier = modifier
            .height(180.dp)
            .clickable(onClick = onClick),
        color = MaterialTheme.colorScheme.surfaceVariant,
        shape = RoundedCornerShape(4.dp)
    ) {
        Box {
            Image(painter = painterResource(id = imageRes), contentDescription = null, modifier = Modifier.fillMaxSize(), contentScale = ContentScale.Crop)
            Box(Modifier.fillMaxSize().background(Color.Black.copy(alpha = 0.4f)))
            Column(Modifier.align(Alignment.BottomStart).padding(12.dp)) {
                Text(title, style = MaterialTheme.typography.titleMedium.copy(color = Color.White))
                Text(subtitle, style = TextStyle(color = GoldPrimary, fontSize = 10.sp))
            }
        }
    }
}

@Composable
fun VipBanner(isVip: Boolean) {
    Surface(
        modifier = Modifier.fillMaxWidth().padding(horizontal = 24.dp),
        color = MaterialTheme.colorScheme.surfaceVariant,
        border = BorderStroke(1.dp, GoldPrimary.copy(alpha = 0.3f))
    ) {
        Row(Modifier.padding(24.dp), verticalAlignment = Alignment.CenterVertically) {
            Icon(Icons.Outlined.Diamond, contentDescription = null, tint = GoldPrimary, modifier = Modifier.size(32.dp))
            Spacer(Modifier.width(24.dp))
            Column {
                Text(if (isVip) "PLATINUM ACCESS" else "JOIN THE CIRCLE", style = MaterialTheme.typography.titleMedium.copy(color = Color.White))
                Text("Exclusive high-stakes tables.", style = TextStyle(color = MaterialTheme.colorScheme.onSurfaceVariant, fontSize = 12.sp))
            }
        }
    }
}

@Composable
fun LobbyStats() {
    Row(Modifier.fillMaxWidth().padding(24.dp), horizontalArrangement = Arrangement.SpaceBetween) {
        StatItem(label = "PLAYED", value = "$14.5k")
        StatItem(label = "ROI", value = "+12%")
        StatItem(label = "HANDS", value = "1,204")
    }
}

@Composable
fun StatItem(label: String, value: String) {
    Column {
        Text(label, style = MaterialTheme.typography.labelSmall.copy(color = MaterialTheme.colorScheme.onSurfaceVariant))
        Text(value, style = MaterialTheme.typography.titleMedium.copy(color = Color.White))
    }
}

@Composable
fun LobbyGameTitle(text: String) {
    Row(verticalAlignment = Alignment.CenterVertically, modifier = Modifier.padding(24.dp)) {
        Box(Modifier.width(30.dp).height(1.dp).background(GoldPrimary))
        Spacer(Modifier.width(8.dp))
        Text(text, style = MaterialTheme.typography.labelSmall.copy(color = GoldPrimary))
    }
}
