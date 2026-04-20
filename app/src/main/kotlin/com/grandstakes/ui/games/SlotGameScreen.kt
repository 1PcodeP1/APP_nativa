package com.grandstakes.ui.games

import androidx.compose.animation.*
import androidx.compose.animation.core.*
import androidx.compose.foundation.background
import androidx.compose.foundation.border
import androidx.compose.foundation.clickable
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material3.*
import androidx.compose.runtime.*
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.graphics.Brush
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import androidx.hilt.navigation.compose.hiltViewModel
import com.grandstakes.data.model.SlotTheme
import com.grandstakes.ui.main.LobbyViewModel
import androidx.compose.foundation.BorderStroke
import androidx.compose.material.icons.automirrored.filled.ArrowBack
import androidx.compose.material.icons.filled.ArrowBack
import com.grandstakes.ui.components.GrandStakesButton
import com.grandstakes.ui.theme.GoldPrimary
import kotlinx.coroutines.delay
import kotlinx.coroutines.launch
import kotlin.random.Random

@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun SlotGameScreen(
    themeTitle: String,
    onNavigateBack: () -> Unit,
    viewModel: LobbyViewModel = hiltViewModel()
) {
    val slotTheme = remember(themeTitle) {
        listOf(
            SlotTheme("Eye of Ra", listOf("👁️", "🐫", "🏺", "🦂", "🐍"), 0xFFF2CA50),
            SlotTheme("Royal Cherry", listOf("🍒", "🔔", "7️⃣", "BAR", "🍉"), 0xFF8B0000),
            SlotTheme("Nebula Gems", listOf("💎", "💠", "🌟", "☄️", "🚀"), 0xFF5C8DF6),
            SlotTheme("Grand Pit", listOf("💰", "💎", "7️⃣", "🔔", "🌟"), 0xFFF2CA50)
        ).find { it.title == themeTitle } ?: SlotTheme("Grand Pit", listOf("💰", "💎", "7️⃣", "🔔", "🌟"), 0xFFF2CA50)
    }

    val user by viewModel.currentUser.collectAsState()
    val scope = rememberCoroutineScope()
    
    var reels by remember { mutableStateOf(listOf("?", "?", "?")) }
    var spinning by remember { mutableStateOf(false) }
    var message by remember { mutableStateOf("SPIN TO WIN") }

    fun checkWin(currentReels: List<String>) {
        if (currentReels[0] == currentReels[1] && currentReels[1] == currentReels[2]) {
            viewModel.updateBalance(1000, "Slot Jackpot")
            message = "JACKPOT! +$1000"
        } else if (currentReels[0] == currentReels[1] || currentReels[1] == currentReels[2] || currentReels[0] == currentReels[2]) {
            viewModel.updateBalance(200, "Slot Small Win")
            message = "WINNER! +$200"
        } else {
            message = "NOTHING."
        }
    }

    fun spin() {
        if (spinning || (user?.balance ?: 0) < 100) {
            if ((user?.balance ?: 0) < 100) message = "LACK OF FUNDS"
            return
        }
        spinning = true
        message = "SPINNING..."
        viewModel.updateBalance(-100, "Slot Play: ${slotTheme.title}")

        scope.launch {
            repeat(15) {
                delay(100)
                reels = List(3) { slotTheme.symbols[Random.nextInt(slotTheme.symbols.size)] }
            }
            spinning = false
            checkWin(reels)
        }
    }

    Scaffold(
        containerColor = Color(0xFF0A0A0A),
        topBar = {
            Column {
                Spacer(Modifier.height(16.dp))
                Row(
                    modifier = Modifier.fillMaxWidth().padding(horizontal = 24.dp),
                    horizontalArrangement = Arrangement.SpaceBetween,
                    verticalAlignment = Alignment.CenterVertically
                ) {
                    IconButton(onClick = onNavigateBack) {
                        Icon(androidx.compose.material.icons.Icons.AutoMirrored.Filled.ArrowBack, contentDescription = null, tint = GoldPrimary)
                    }
                    Text(
                        slotTheme.title.uppercase(), 
                        style = MaterialTheme.typography.titleLarge.copy(color = Color.White, letterSpacing = 2.sp)
                    )
                    Spacer(Modifier.width(48.dp))
                }
            }
        }
    ) { padding ->
        Column(
            modifier = Modifier.fillMaxSize().padding(padding),
            horizontalAlignment = Alignment.CenterHorizontally,
            verticalArrangement = Arrangement.Center
        ) {
            Text(
                message.uppercase(), 
                style = MaterialTheme.typography.labelSmall.copy(color = GoldPrimary, letterSpacing = 4.sp)
            )
            Spacer(modifier = Modifier.height(48.dp))
            
            // Reel Frame
            Surface(
                modifier = Modifier
                    .fillMaxWidth()
                    .padding(horizontal = 32.dp),
                color = Color(0xFF1A1A1A),
                border = BorderStroke(1.dp, GoldPrimary.copy(alpha = 0.3f)),
                shape = RoundedCornerShape(0.dp)
            ) {
                Row(
                    modifier = Modifier.padding(24.dp),
                    horizontalArrangement = Arrangement.SpaceEvenly
                ) {
                    reels.forEach { symbol ->
                        Surface(
                            modifier = Modifier
                                .size(80.dp),
                            color = Color.Black,
                            border = BorderStroke(0.5.dp, GoldPrimary.copy(alpha = 0.1f))
                        ) {
                            Box(contentAlignment = Alignment.Center) {
                                Text(
                                    symbol, 
                                    style = androidx.compose.ui.text.TextStyle(fontSize = 40.sp)
                                )
                            }
                        }
                    }
                }
            }
            
            Spacer(modifier = Modifier.height(64.dp))
            
            GrandStakesButton(
                text = if (spinning) "SPINNING..." else "SPIN REELS",
                onClick = { spin() },
                enabled = !spinning,
                modifier = Modifier.width(220.dp)
            )
            
            if (!spinning) {
                Spacer(Modifier.height(24.dp))
                Text(
                    "JACKPOT: $1,420,000", 
                    style = MaterialTheme.typography.labelSmall.copy(color = GoldPrimary.copy(alpha = 0.5f), letterSpacing = 2.sp)
                )
            }
        }
    }
}
