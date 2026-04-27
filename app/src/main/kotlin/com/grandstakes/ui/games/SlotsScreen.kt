package com.grandstakes.ui.games

import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.automirrored.filled.ArrowForward

import androidx.compose.foundation.*
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.lazy.LazyColumn
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material3.*
import androidx.compose.runtime.*
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.alpha
import androidx.compose.ui.draw.clip
import androidx.compose.ui.draw.rotate
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
import kotlinx.coroutines.delay

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
        item { SlotsTopBanner(onPlayDefault = { onPlaySlot(slotGames[0]) }, onBack = onNavigateBack) }
        
        item { 
            Row(
                modifier = Modifier.padding(horizontal = 24.dp, vertical = 32.dp),
                verticalAlignment = Alignment.CenterVertically
            ) {
                Text(
                    "PREMIUM MACHINES", 
                    style = MaterialTheme.typography.labelSmall.copy(color = GoldPrimary, letterSpacing = 3.sp)
                )
                Spacer(modifier = Modifier.width(16.dp))
                Box(modifier = Modifier.weight(1f).height(1.dp).background(GoldPrimary.copy(alpha = 0.1f)))
            }
        }
        
        items(slotGames.size) { index ->
            val slot = slotGames[index]
            SlotCard(
                slot = slot,
                onClick = { onPlaySlot(slot) }
            )
            Spacer(modifier = Modifier.height(20.dp))
        }
        
        item { VipExperienceSection() }
        
        item { Spacer(modifier = Modifier.height(48.dp)) }
    }
}

@Composable
fun SlotsTopBanner(onPlayDefault: () -> Unit, onBack: () -> Unit) {
    var jackpot by remember { mutableLongStateOf(1420000L) }
    
    LaunchedEffect(Unit) {
        while(true) {
            delay(3000)
            jackpot += (10..50).random()
        }
    }

    Box(
        modifier = Modifier
            .fillMaxWidth()
            .height(300.dp)
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
                        colors = listOf(Color.Black.copy(alpha = 0.6f), Color.Transparent, Color.Black),
                    )
                )
        )
        
        // Back Button
        IconButton(
            onClick = onBack,
            modifier = Modifier.padding(16.dp).statusBarsPadding()
        ) {
            Icon(Icons.AutoMirrored.Filled.ArrowForward, contentDescription = null, tint = Color.White, modifier = Modifier.rotate(180f))
        }

        Column(
            modifier = Modifier.align(Alignment.BottomStart).padding(24.dp),
            horizontalAlignment = Alignment.Start
        ) {
            Surface(
                color = GoldPrimary,
                shape = RoundedCornerShape(2.dp),
                modifier = Modifier.padding(bottom = 8.dp)
            ) {
                Text(
                    " HOT NOW ", 
                    style = MaterialTheme.typography.labelSmall.copy(color = Color.Black, fontWeight = FontWeight.Black, fontSize = 10.sp)
                )
            }
            Text("GRAND PROGRESSIVE", style = MaterialTheme.typography.labelSmall.copy(color = GoldPrimary, letterSpacing = 4.sp))
            Spacer(modifier = Modifier.height(4.dp))
            Text(
                "$${java.text.NumberFormat.getIntegerInstance().format(jackpot)}", 
                style = MaterialTheme.typography.displayLarge.copy(fontSize = 52.sp, color = Color.White, fontWeight = FontWeight.Black)
            )
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
        color = Color(0xFF0F0F0F),
        shape = RoundedCornerShape(4.dp),
        border = BorderStroke(1.dp, Color.White.copy(alpha = 0.05f))
    ) {
        Row(
            modifier = Modifier.padding(12.dp),
            verticalAlignment = Alignment.CenterVertically
        ) {
            Box(
                modifier = Modifier
                    .size(100.dp, 70.dp)
                    .clip(RoundedCornerShape(2.dp))
                    .border(1.dp, GoldPrimary.copy(alpha = 0.1f), RoundedCornerShape(2.dp))
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
                    style = MaterialTheme.typography.titleMedium.copy(color = Color.White, letterSpacing = 2.sp, fontWeight = FontWeight.Bold)
                )
                Text(
                    "HIGH VOLATILITY • 98.4% RTP", 
                    style = MaterialTheme.typography.labelSmall.copy(color = GoldPrimary.copy(alpha = 0.6f), fontSize = 9.sp, fontWeight = FontWeight.Bold)
                )
            }
            
            Column(horizontalAlignment = Alignment.End) {
                Icon(
                    imageVector = Icons.AutoMirrored.Filled.ArrowForward, 
                    contentDescription = null, 
                    tint = GoldPrimary,
                    modifier = Modifier.size(16.dp)
                )
                Spacer(modifier = Modifier.height(4.dp))
                Text("PLAY", style = MaterialTheme.typography.labelSmall.copy(color = GoldPrimary, fontSize = 10.sp, fontWeight = FontWeight.Black))
            }
        }
    }
}

@Composable
fun VipExperienceSection() {
    Column(
        modifier = Modifier
            .padding(top = 48.dp)
            .fillMaxWidth()
            .background(
                Brush.verticalGradient(
                    listOf(Color.Transparent, Color(0xFF101010), Color.Black)
                )
            )
            .padding(24.dp)
            .padding(vertical = 48.dp)
    ) {
        Box(modifier = Modifier.size(40.dp).background(GoldPrimary.copy(alpha = 0.1f), RoundedCornerShape(20.dp)), contentAlignment = Alignment.Center) {
            Text("VIP", color = GoldPrimary, fontWeight = FontWeight.Black, fontSize = 12.sp)
        }
        Spacer(modifier = Modifier.height(16.dp))
        Text("THE ELITE SUITE", style = MaterialTheme.typography.labelSmall.copy(color = GoldPrimary, letterSpacing = 4.sp))
        Spacer(modifier = Modifier.height(12.dp))
        Text(
            "Distinctive Gaming for Distinguished Guests", 
            style = MaterialTheme.typography.displaySmall.copy(fontSize = 32.sp, lineHeight = 38.sp, color = Color.White, fontWeight = FontWeight.Black)
        )
        Spacer(modifier = Modifier.height(16.dp))
        Text(
            "Our private suites offer the highest limits in the city, with a dedicated concierge and premium catering services.",
            style = MaterialTheme.typography.bodyMedium.copy(color = Color.White.copy(alpha = 0.5f), lineHeight = 24.sp)
        )
        Spacer(modifier = Modifier.height(32.dp))
        OutlinedButton(
            onClick = { },
            modifier = Modifier.fillMaxWidth().height(56.dp),
            border = BorderStroke(1.dp, GoldPrimary.copy(alpha = 0.3f)),
            shape = RoundedCornerShape(4.dp),
            colors = ButtonDefaults.outlinedButtonColors(contentColor = GoldPrimary)
        ) {
            Text("REQUEST PRIVATE ACCESS", style = MaterialTheme.typography.labelSmall.copy(letterSpacing = 2.sp, fontWeight = FontWeight.Black))
        }
    }
}
