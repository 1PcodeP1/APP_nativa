package com.grandstakes.ui.main

import androidx.compose.foundation.*
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.lazy.LazyColumn
import androidx.compose.foundation.lazy.items
import androidx.compose.foundation.shape.CircleShape
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.PlayArrow
import androidx.compose.material.icons.outlined.Diamond
import androidx.compose.material3.*
import androidx.compose.runtime.*
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.graphics.Brush
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.layout.ContentScale
import androidx.compose.ui.res.painterResource
import androidx.compose.ui.text.font.FontStyle
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import androidx.hilt.navigation.compose.hiltViewModel
import com.grandstakes.R
import com.grandstakes.ui.theme.GoldPrimary
import com.grandstakes.ui.theme.OnSurfaceVariant
import com.grandstakes.ui.components.GrandStakesButton

@Composable
fun LobbyScreen(
    onNavigateToGame: (String) -> Unit,
    viewModel: LobbyViewModel = hiltViewModel()
) {
    val user by viewModel.currentUser.collectAsState()

    LazyColumn(
        modifier = Modifier
            .fillMaxSize()
            .background(Color.Black)
    ) {
        item { LobbyHero() }
        
        item { Spacer(Modifier.height(48.dp)) }
        
        item { 
            Text(
                "THE COLLECTION", 
                modifier = Modifier.padding(horizontal = 24.dp),
                style = MaterialTheme.typography.labelSmall.copy(color = GoldPrimary, letterSpacing = 2.sp)
            ) 
        }
        
        item { Spacer(Modifier.height(16.dp)) }
        
        item {
            CollectionItem(
                title = "Midnight Roulette",
                subtitle = "Exclusive High Stakes",
                imageRes = R.drawable.roulette_cover,
                onTap = { onNavigateToGame("roulette") }
            )
        }
        
        item { Spacer(Modifier.height(48.dp)) }
        
        item { 
            Text(
                "THE PIT FLOOR", 
                modifier = Modifier.padding(horizontal = 24.dp),
                style = MaterialTheme.typography.labelSmall.copy(color = GoldPrimary, letterSpacing = 2.sp)
            ) 
        }
        
        item { Spacer(Modifier.height(16.dp)) }
        
        item {
            Column(modifier = Modifier.padding(horizontal = 24.dp)) {
                PitFloorItem(
                    title = "Blackjack & Poker",
                    subtitle = "Table Limits: $500 - $50,000",
                    imageRes = R.drawable.blackjack_cover,
                    onTap = { onNavigateToGame("blackjack") }
                )
                Spacer(Modifier.height(16.dp))
                PitFloorItem(
                    title = "Grand Slots",
                    subtitle = "Jackpot: $1,420,000",
                    imageRes = R.drawable.slots_cover,
                    onTap = { onNavigateToGame("slots") }
                )
                Spacer(Modifier.height(16.dp))
                PitFloorItem(
                    title = "French Roulette",
                    subtitle = "Table Limits: $100 - $25,000",
                    imageRes = R.drawable.roulette_cover,
                    onTap = { onNavigateToGame("roulette") }
                )
            }
        }
        
        item { Spacer(Modifier.height(48.dp)) }
        
        item { VipLoungeCard(onEnter = { onNavigateToGame("baccarat") }) }
        
        item { Spacer(Modifier.height(48.dp)) }
        
        item { LobbyStats() }
        
        item { Spacer(Modifier.height(48.dp)) }
    }
}

@Composable
fun LobbyHero() {
    Column(modifier = Modifier.padding(top = 48.dp, start = 24.dp, end = 24.dp)) {
        Text(
            text = "The High-Roller's",
            style = MaterialTheme.typography.labelSmall.copy(color = GoldPrimary, letterSpacing = 3.sp)
        )
        Text(
            text = "Private Atelier",
            style = MaterialTheme.typography.displayLarge.copy(fontSize = 52.sp, lineHeight = 56.sp)
        )
        Spacer(Modifier.height(24.dp))
        GrandStakesButton(
            text = "REQUEST INVITATION",
            onClick = { /* TODO */ },
            modifier = Modifier.width(200.dp)
        )
    }
}

@Composable
fun CollectionItem(title: String, subtitle: String, imageRes: Int, onTap: () -> Unit) {
    Box(
        modifier = Modifier
            .fillMaxWidth()
            .height(340.dp)
            .padding(horizontal = 24.dp)
            .clickable(onClick = onTap)
    ) {
        Image(
            painter = painterResource(id = imageRes),
            contentDescription = null,
            modifier = Modifier.fillMaxSize(),
            contentScale = ContentScale.Crop
        )
        Box(
            modifier = Modifier
                .fillMaxSize()
                .background(
                    Brush.verticalGradient(
                        colors = listOf(Color.Transparent, Color.Black.copy(alpha = 0.8f))
                    )
                )
        )
        Column(
            modifier = Modifier
                .align(Alignment.BottomStart)
                .padding(24.dp)
        ) {
            Text(
                subtitle.uppercase(), 
                style = MaterialTheme.typography.labelSmall.copy(color = GoldPrimary, letterSpacing = 2.sp)
            )
            Spacer(Modifier.height(4.dp))
            Text(
                title, 
                style = MaterialTheme.typography.headlineLarge.copy(color = Color.White)
            )
            Spacer(Modifier.height(16.dp))
            Box(
                modifier = Modifier
                    .size(48.dp)
                    .border(1.dp, GoldPrimary, CircleShape),
                contentAlignment = Alignment.Center
            ) {
                Icon(Icons.Default.PlayArrow, contentDescription = null, tint = GoldPrimary, modifier = Modifier.size(24.dp))
            }
        }
    }
}

@Composable
fun PitFloorItem(title: String, subtitle: String, imageRes: Int, onTap: () -> Unit) {
    Surface(
        modifier = Modifier
            .fillMaxWidth()
            .height(140.dp)
            .clickable(onClick = onTap),
        color = Color(0xFF0F0F0F),
        border = BorderStroke(1.dp, GoldPrimary.copy(alpha = 0.05f))
    ) {
        Row(modifier = Modifier.fillMaxSize()) {
            Box(modifier = Modifier.weight(1.5f)) {
                Image(
                    painter = painterResource(id = imageRes),
                    contentDescription = null,
                    modifier = Modifier.fillMaxSize(),
                    contentScale = ContentScale.Crop
                )
                Box(Modifier.fillMaxSize().background(Color.Black.copy(alpha = 0.3f)))
            }
            Column(
                modifier = Modifier
                    .weight(3f)
                    .padding(20.dp)
            ) {
                Text(
                    title, 
                    style = MaterialTheme.typography.titleMedium.copy(color = Color.White, fontWeight = FontWeight.Bold)
                )
                Text(
                    subtitle, 
                    style = MaterialTheme.typography.bodySmall.copy(color = OnSurfaceVariant, fontSize = 11.sp)
                )
                Spacer(Modifier.weight(1f))
                Row(
                    modifier = Modifier.fillMaxWidth(),
                    horizontalArrangement = Arrangement.SpaceBetween,
                    verticalAlignment = Alignment.CenterVertically
                ) {
                    Text(
                        "ENTER THE PIT  →", 
                        style = MaterialTheme.typography.labelSmall.copy(color = GoldPrimary, fontSize = 10.sp, fontWeight = FontWeight.ExtraBold)
                    )
                }
            }
        }
    }
}

@Composable
fun VipLoungeCard(onEnter: () -> Unit) {
    Box(
        modifier = Modifier
            .fillMaxWidth()
            .padding(horizontal = 24.dp)
            .clip(RoundedCornerShape(8.dp))
            .background(
                Brush.linearGradient(
                    colors = listOf(Color(0xFF382A2A), Color.Black)
                )
            )
            .border(1.dp, GoldPrimary.copy(alpha = 0.3f), RoundedCornerShape(8.dp))
            .padding(24.dp)
    ) {
        Column {
            Text("The VIP Lounge", style = MaterialTheme.typography.titleLarge.copy(color = GoldPrimary))
            Spacer(Modifier.height(8.dp))
            Text("Reserved for our most prestigious members.", style = MaterialTheme.typography.bodySmall.copy(color = Color.White.copy(alpha = 0.7f)))
            Spacer(Modifier.height(16.dp))
            Text(
                "ENTER LOUNGE  →",
                modifier = Modifier.clickable(onClick = onEnter),
                style = MaterialTheme.typography.labelSmall.copy(color = GoldPrimary, letterSpacing = 2.sp)
            )
        }
    }
}

@Composable
fun LobbyStats() {
    Surface(
        modifier = Modifier.fillMaxWidth(),
        color = Color(0xFF0F0F0F)
    ) {
        Row(
            modifier = Modifier.padding(vertical = 24.dp, horizontal = 16.dp),
            horizontalArrangement = Arrangement.SpaceAround
        ) {
            StatItem("GAMES PLAYED", "1,248")
            StatItem("TOTAL WINNINGS", "$4,250,900")
            StatItem("RECENT WIN", "+$12,500")
            StatItem("STATUS", "Platinum")
        }
    }
}

@Composable
fun StatItem(label: String, value: String) {
    Column(horizontalAlignment = Alignment.CenterHorizontally) {
        Text(value, style = MaterialTheme.typography.titleSmall.copy(color = Color.White, fontWeight = FontWeight.Bold))
        Spacer(Modifier.height(4.dp))
        Text(label, style = MaterialTheme.typography.labelSmall.copy(color = GoldPrimary, fontSize = 8.sp))
    }
}
