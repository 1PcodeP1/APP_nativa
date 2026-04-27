package com.grandstakes.ui.main

import androidx.compose.foundation.*
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.lazy.LazyColumn
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.automirrored.filled.ArrowForward
import androidx.compose.material3.*
import androidx.compose.runtime.Composable
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.layout.ContentScale
import androidx.compose.ui.res.painterResource
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import com.grandstakes.R
import com.grandstakes.ui.theme.GoldPrimary
import com.grandstakes.ui.theme.OnSurfaceVariant

@Composable
fun TablesScreen(
    onNavigateToGame: (String) -> Unit
) {
    LazyColumn(
        modifier = Modifier
            .fillMaxSize()
            .background(Color.Black)
            .padding(horizontal = 24.dp)
    ) {
        item {
            Column(modifier = Modifier.padding(vertical = 48.dp)) {
                Text(
                    "THE HIGH STAKES",
                    style = MaterialTheme.typography.labelSmall.copy(color = GoldPrimary, letterSpacing = 3.sp)
                )
                Text(
                    "Table Games",
                    style = MaterialTheme.typography.displayLarge.copy(fontSize = 52.sp, lineHeight = 56.sp)
                )
            }
        }

        item {
            TableGameItem(
                title = "Midnight Roulette",
                subtitle = "LIMITS: $100 - $50,000",
                imageRes = R.drawable.roulette_cover,
                onClick = { onNavigateToGame("roulette") }
            )
        }

        item { Spacer(Modifier.height(24.dp)) }

        item {
            TableGameItem(
                title = "Grand Blackjack",
                subtitle = "LIMITS: $500 - $100,000",
                imageRes = R.drawable.blackjack_cover,
                onClick = { onNavigateToGame("blackjack") }
            )
        }

        item { Spacer(Modifier.height(24.dp)) }

        item {
            TableGameItem(
                title = "Elite Baccarat",
                subtitle = "LIMITS: $1,000 - $250,000",
                imageRes = R.drawable.baccarat_cover,
                onClick = { onNavigateToGame("baccarat") }
            )
        }

        item { Spacer(Modifier.height(24.dp)) }

        item {
            TableGameItem(
                title = "Poker Atelier",
                subtitle = "COMING SOON",
                imageRes = R.drawable.blackjack_cover, // Placeholder until poker is added
                onClick = { /* Coming soon */ },
                isComingSoon = true
            )
        }

        item { Spacer(Modifier.height(48.dp)) }
    }
}

@Composable
fun TableGameItem(
    title: String,
    subtitle: String,
    imageRes: Int,
    onClick: () -> Unit,
    isComingSoon: Boolean = false
) {
    Surface(
        modifier = Modifier
            .fillMaxWidth()
            .height(160.dp)
            .clickable(enabled = !isComingSoon, onClick = onClick),
        color = Color(0xFF0F0F0F),
        shape = RoundedCornerShape(0.dp),
        border = BorderStroke(1.dp, GoldPrimary.copy(alpha = 0.1f))
    ) {
        Row(modifier = Modifier.fillMaxSize()) {
            Box(modifier = Modifier.weight(1.5f)) {
                Image(
                    painter = painterResource(id = imageRes),
                    contentDescription = null,
                    modifier = Modifier.fillMaxSize(),
                    contentScale = ContentScale.Crop
                )
                if (isComingSoon) {
                    Box(Modifier.fillMaxSize().background(Color.Black.copy(alpha = 0.6f)))
                }
            }
            Column(
                modifier = Modifier
                    .weight(3f)
                    .padding(20.dp)
            ) {
                Text(
                    title.uppercase(),
                    style = MaterialTheme.typography.titleMedium.copy(color = Color.White, fontWeight = FontWeight.Bold, letterSpacing = 1.sp)
                )
                Text(
                    subtitle,
                    style = MaterialTheme.typography.bodySmall.copy(color = if (isComingSoon) GoldPrimary else OnSurfaceVariant, fontSize = 10.sp, fontWeight = FontWeight.Bold)
                )
                Spacer(Modifier.weight(1f))
                if (!isComingSoon) {
                    Row(
                        modifier = Modifier.fillMaxWidth(),
                        horizontalArrangement = Arrangement.SpaceBetween,
                        verticalAlignment = Alignment.CenterVertically
                    ) {
                        Text(
                            "ENTER TABLE  →",
                            style = MaterialTheme.typography.labelSmall.copy(color = GoldPrimary, fontSize = 10.sp, fontWeight = FontWeight.ExtraBold)
                        )
                        Icon(Icons.AutoMirrored.Filled.ArrowForward, contentDescription = null, tint = GoldPrimary, modifier = Modifier.size(16.dp))
                    }
                }
            }
        }
    }
}
