package com.grandstakes.ui.games

import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.automirrored.filled.ArrowForward

import androidx.compose.foundation.*
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.lazy.LazyColumn
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material3.*
import androidx.compose.runtime.Composable
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.graphics.Brush
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.layout.ContentScale
import androidx.compose.ui.res.painterResource
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import com.grandstakes.R
import com.grandstakes.data.model.SlotTheme
import com.grandstakes.ui.components.GrandStakesButton
import com.grandstakes.ui.theme.GoldPrimary

@Composable
fun SlotsScreen(
    onNavigateBack: () -> Unit,
    onPlaySlot: (SlotTheme) -> Unit
) {
    val slotGames = listOf(
        SlotTheme(
            title = "Eye of Ra",
            symbols = listOf("👁️", "🐫", "🏺", "🦂", "🐍"),
            primaryColorHex = 0xFFF2CA50,
            imageRes = R.drawable.eye_of_ra_slot
        ),
        SlotTheme(
            title = "Royal Cherry",
            symbols = listOf("🍒", "🔔", "7️⃣", "BAR", "🍉"),
            primaryColorHex = 0xFF8B0000,
            imageRes = R.drawable.royal_cherry_slot
        ),
        SlotTheme(
            title = "Nebula Gems",
            symbols = listOf("💎", "💠", "🌟", "☄️", "🚀"),
            primaryColorHex = 0xFF5C8DF6,
            imageRes = R.drawable.nebula_gems_slot
        )
    )

    LazyColumn(
        modifier = Modifier
            .fillMaxSize()
            .background(Color.Black)
    ) {
        item { SlotsTopBanner(onPlayDefault = { onPlaySlot(slotGames[0]) }) }
        
        item { Spacer(modifier = Modifier.height(32.dp)) }
        
        items(slotGames.size) { index ->
            val slot = slotGames[index]
            SlotCard(
                slot = slot,
                onClick = { onPlaySlot(slot) }
            )
            Spacer(modifier = Modifier.height(24.dp))
        }
        
        item { VipExperienceSection() }
        
        item { Spacer(modifier = Modifier.height(48.dp)) }
    }
}

@Composable
fun SlotsTopBanner(onPlayDefault: () -> Unit) {
    Box(
        modifier = Modifier
            .fillMaxWidth()
            .height(260.dp)
    ) {
        Image(
            painter = painterResource(id = R.drawable.slots_cover),
            contentDescription = null,
            modifier = Modifier.fillMaxSize(),
            contentScale = ContentScale.Crop
        )
        Box(
            modifier = Modifier
                .fillMaxSize()
                .background(
                    Brush.verticalGradient(
                        colors = listOf(Color.Transparent, Color.Black),
                        startY = 0f,
                        endY = 1000f
                    )
                )
        )
        Column(
            modifier = Modifier.align(Alignment.BottomStart).padding(24.dp),
            horizontalAlignment = Alignment.Start
        ) {
            Text("THE GRAND JACKPOT", style = MaterialTheme.typography.labelSmall.copy(color = GoldPrimary, letterSpacing = 4.sp))
            Spacer(modifier = Modifier.height(4.dp))
            Text("$1,420,000", style = MaterialTheme.typography.displayLarge.copy(fontSize = 48.sp, color = Color.White))
            Spacer(modifier = Modifier.height(16.dp))
            GrandStakesButton(
                text = "ENTER THE PIT",
                onClick = onPlayDefault,
                modifier = Modifier.width(180.dp)
            )
        }
    }
}

@Composable
fun SlotCard(slot: SlotTheme, onClick: () -> Unit) {
    Surface(
        modifier = Modifier
            .padding(horizontal = 24.dp)
            .fillMaxWidth()
            .clickable { onClick() },
        color = Color(0xFF121212),
        shape = RoundedCornerShape(0.dp)
    ) {
        Row(
            modifier = Modifier.padding(16.dp),
            verticalAlignment = Alignment.CenterVertically
        ) {
            Box(
                modifier = Modifier
                    .size(80.dp)
                    .clip(RoundedCornerShape(0.dp))
            ) {
                if (slot.imageRes != null) {
                    Image(
                        painter = painterResource(id = slot.imageRes!!),
                        contentDescription = null,
                        modifier = Modifier.fillMaxSize(),
                        contentScale = ContentScale.Crop
                    )
                } else {
                    Box(modifier = Modifier.fillMaxSize().background(Color(slot.primaryColorHex).copy(alpha = 0.1f)))
                }
            }
            
            Spacer(modifier = Modifier.width(20.dp))
            
            Column(modifier = Modifier.weight(1f)) {
                Text(
                    slot.title.uppercase(), 
                    style = MaterialTheme.typography.titleMedium.copy(color = Color.White, letterSpacing = 1.sp)
                )
                Text(
                    "PREMIUM SELECTION", 
                    style = MaterialTheme.typography.labelSmall.copy(color = GoldPrimary.copy(alpha = 0.6f), fontSize = 10.sp)
                )
            }
            
            Icon(
                imageVector = Icons.AutoMirrored.Filled.ArrowForward, 
                contentDescription = null, 
                tint = GoldPrimary,
                modifier = Modifier.size(20.dp)
            )
        }
    }
}

@Composable
fun VipExperienceSection() {
    Column(
        modifier = Modifier
            .padding(horizontal = 24.dp)
            .fillMaxWidth()
            .background(Color(0xFF0A0A0A))
            .padding(vertical = 48.dp)
    ) {
        Text("THE VIP EXPERIENCE", style = MaterialTheme.typography.labelSmall.copy(color = GoldPrimary, letterSpacing = 4.sp))
        Spacer(modifier = Modifier.height(12.dp))
        Text(
            "Exclusive Selection for Distinguished Guests", 
            style = MaterialTheme.typography.displayLarge.copy(fontSize = 36.sp, lineHeight = 40.sp, color = Color.White)
        )
        Spacer(modifier = Modifier.height(16.dp))
        Text(
            "Access high-limit suites and enjoy personalized service from our dedicated concierge team.",
            style = MaterialTheme.typography.bodyMedium.copy(color = Color.White.copy(alpha = 0.5f), lineHeight = 24.sp)
        )
        Spacer(modifier = Modifier.height(32.dp))
        OutlinedButton(
            onClick = { },
            modifier = Modifier.fillMaxWidth().height(54.dp),
            border = BorderStroke(1.dp, GoldPrimary.copy(alpha = 0.5f)),
            shape = RoundedCornerShape(0.dp),
            colors = ButtonDefaults.outlinedButtonColors(contentColor = GoldPrimary)
        ) {
            Text("REQUEST PRIVATE SUITE ACCESS", style = MaterialTheme.typography.labelSmall.copy(letterSpacing = 2.sp))
        }
    }
}
