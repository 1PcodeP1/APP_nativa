package com.grandstakes.ui.games

import androidx.compose.animation.*
import androidx.compose.animation.core.*
import androidx.compose.foundation.BorderStroke
import androidx.compose.foundation.background
import androidx.compose.foundation.border
import androidx.compose.foundation.clickable
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.ChevronLeft
import androidx.compose.material.icons.filled.Diamond
import androidx.compose.material3.*
import androidx.compose.runtime.*
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.alpha
import androidx.compose.ui.draw.clip
import androidx.compose.ui.draw.shadow
import androidx.compose.ui.graphics.Brush
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.text.style.TextAlign
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import androidx.hilt.navigation.compose.hiltViewModel
import com.grandstakes.data.model.SlotTheme
import com.grandstakes.ui.main.LobbyViewModel
import com.grandstakes.ui.components.GrandStakesButton
import com.grandstakes.ui.theme.GoldPrimary
import kotlinx.coroutines.delay
import kotlinx.coroutines.launch
import kotlin.random.Random

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
            SlotTheme("Grand Pit", listOf("💰", "💎", "7️⃣", "🔔", "🌟"), 0xFFD4AF37)
        ).find { it.title == themeTitle } ?: SlotTheme("Grand Pit", listOf("💰", "💎", "7️⃣", "🔔", "🌟"), 0xFFD4AF37)
    }

    val user by viewModel.currentUser.collectAsState()
    val scope = rememberCoroutineScope()
    
    var reels by remember { mutableStateOf(listOf(slotTheme.symbols[0], slotTheme.symbols[1], slotTheme.symbols[2])) }
    var spinning by remember { mutableStateOf(false) }
    var message by remember { mutableStateOf("READY TO SPIN") }
    var winAmount by remember { mutableIntStateOf(0) }
    var showWinBanner by remember { mutableStateOf(false) }

    val themeColor = Color(slotTheme.primaryColorHex)

    fun checkWin(currentReels: List<String>) {
        if (currentReels[0] == currentReels[1] && currentReels[1] == currentReels[2]) {
            val amount = 2000
            viewModel.updateBalance(amount, "Slot Jackpot")
            winAmount = amount
            message = "MEGA JACKPOT!"
            showWinBanner = true
        } else if (currentReels[0] == currentReels[1] || currentReels[1] == currentReels[2] || currentReels[0] == currentReels[2]) {
            val amount = 400
            viewModel.updateBalance(amount, "Slot Win")
            winAmount = amount
            message = "WINNER!"
            showWinBanner = true
        } else {
            message = "BET AGAIN"
            showWinBanner = false
        }
    }

    fun spin() {
        if (spinning || (user?.balance ?: 0) < 100) return
        
        scope.launch {
            spinning = true
            showWinBanner = false
            message = "SPINNING..."
            viewModel.updateBalance(-100, "Slot Spin")
            
            // Parallel reel spins starting together
            val spinDuration = 1500L
            val startTime = System.currentTimeMillis()
            
            val reel1 = launch {
                while (System.currentTimeMillis() - startTime < spinDuration) {
                    reels = reels.toMutableList().apply { this[0] = slotTheme.symbols[Random.nextInt(slotTheme.symbols.size)] }
                    delay(50)
                }
            }
            val reel2 = launch {
                delay(100) // Slight offset for feel
                while (System.currentTimeMillis() - startTime < spinDuration + 200) {
                    reels = reels.toMutableList().apply { this[1] = slotTheme.symbols[Random.nextInt(slotTheme.symbols.size)] }
                    delay(50)
                }
            }
            val reel3 = launch {
                delay(200) // Slight offset for feel
                while (System.currentTimeMillis() - startTime < spinDuration + 400) {
                    reels = reels.toMutableList().apply { this[2] = slotTheme.symbols[Random.nextInt(slotTheme.symbols.size)] }
                    delay(50)
                }
            }
            
            reel1.join()
            reel2.join()
            reel3.join()
            
            spinning = false
            checkWin(reels)
        }
    }

    Box(
        modifier = Modifier
            .fillMaxSize()
            .background(
                Brush.radialGradient(
                    colors = listOf(themeColor.copy(alpha = 0.3f), Color.Black),
                    radius = 2500f
                )
            )
    ) {
        // Immersive Header
        Row(
            modifier = Modifier
                .fillMaxWidth()
                .statusBarsPadding()
                .padding(24.dp),
            horizontalArrangement = Arrangement.SpaceBetween,
            verticalAlignment = Alignment.CenterVertically
        ) {
            TextButton(onClick = onNavigateBack) {
                Text("← EXIT", color = GoldPrimary, fontWeight = FontWeight.Bold)
            }
            
            Column(horizontalAlignment = Alignment.CenterHorizontally) {
                Text(slotTheme.title.uppercase(), style = MaterialTheme.typography.labelSmall.copy(color = GoldPrimary, letterSpacing = 2.sp))
                Text("PIT LEVEL 4", style = MaterialTheme.typography.labelSmall.copy(color = Color.White.copy(alpha = 0.4f), fontSize = 8.sp))
            }
            
            Box(modifier = Modifier.size(40.dp))
        }

        Column(
            modifier = Modifier
                .fillMaxSize()
                .padding(24.dp),
            horizontalAlignment = Alignment.CenterHorizontally,
            verticalArrangement = Arrangement.Center
        ) {
            // Win Banner
            AnimatedVisibility(
                visible = showWinBanner,
                enter = fadeIn() + expandVertically(),
                exit = fadeOut() + shrinkVertically()
            ) {
                Column(horizontalAlignment = Alignment.CenterHorizontally) {
                    Text(
                        message,
                        style = MaterialTheme.typography.displayMedium.copy(color = GoldPrimary, fontWeight = FontWeight.Black)
                    )
                    Text(
                        "+$${winAmount}",
                        style = MaterialTheme.typography.headlineLarge.copy(color = Color.White, fontWeight = FontWeight.Bold)
                    )
                    Spacer(modifier = Modifier.height(24.dp))
                }
            }

            if (!showWinBanner) {
                Text(
                    message, 
                    style = MaterialTheme.typography.labelSmall.copy(color = GoldPrimary, letterSpacing = 4.sp)
                )
                Spacer(modifier = Modifier.height(32.dp))
            }

            // Reel Container
            Surface(
                modifier = Modifier
                    .fillMaxWidth()
                    .padding(horizontal = 8.dp)
                    .shadow(if (showWinBanner) 32.dp else 4.dp, RoundedCornerShape(8.dp), ambientColor = themeColor, spotColor = themeColor),
                color = Color.Black.copy(alpha = 0.8f),
                border = BorderStroke(1.dp, if (showWinBanner) GoldPrimary else themeColor.copy(alpha = 0.3f)),
                shape = RoundedCornerShape(8.dp)
            ) {
                Row(
                    modifier = Modifier.padding(24.dp),
                    horizontalArrangement = Arrangement.spacedBy(12.dp)
                ) {
                    reels.forEachIndexed { index, symbol ->
                        SlotReelBox(
                            symbol = symbol, 
                            modifier = Modifier.weight(1f),
                            isSpinning = spinning,
                            delayIndex = index,
                            themeColor = themeColor
                        )
                    }
                }
            }

            Spacer(modifier = Modifier.height(64.dp))

            // Control Panel
            Surface(
                color = Color.Black.copy(alpha = 0.6f),
                shape = RoundedCornerShape(32.dp),
                border = BorderStroke(1.dp, GoldPrimary.copy(alpha = 0.1f))
            ) {
                Row(
                    modifier = Modifier.padding(horizontal = 32.dp, vertical = 12.dp),
                    verticalAlignment = Alignment.CenterVertically
                ) {
                    Column(horizontalAlignment = Alignment.Start) {
                        Text("TOTAL BET", style = MaterialTheme.typography.labelSmall.copy(color = Color.White.copy(alpha = 0.4f), fontSize = 8.sp))
                        Text("$100", style = MaterialTheme.typography.titleMedium.copy(color = Color.White, fontWeight = FontWeight.Bold))
                    }
                    Spacer(modifier = Modifier.width(48.dp))
                    GrandStakesButton(
                        text = if (spinning) "SPINNING" else "PULL LEVER",
                        onClick = { spin() },
                        enabled = !spinning && (user?.balance ?: 0) >= 100,
                        modifier = Modifier.width(160.dp)
                    )
                }
            }
            
            Spacer(modifier = Modifier.height(24.dp))
            Text(
                "MATCH 3 FOR JACKPOT  •  MATCH 2 FOR WIN",
                style = MaterialTheme.typography.labelSmall.copy(color = Color.White.copy(alpha = 0.3f), fontSize = 10.sp)
            )
        }
    }
}

@OptIn(ExperimentalAnimationApi::class)
@Composable
fun SlotReelBox(symbol: String, modifier: Modifier = Modifier, isSpinning: Boolean, delayIndex: Int, themeColor: Color) {
    Surface(
        modifier = modifier
            .aspectRatio(1f),
        color = Color(0xFF101010),
        shape = RoundedCornerShape(4.dp),
        border = BorderStroke(0.5.dp, GoldPrimary.copy(alpha = 0.1f))
    ) {
        Box(contentAlignment = Alignment.Center) {
            // Background glow
            Icon(
                Icons.Default.Diamond, 
                contentDescription = null, 
                tint = themeColor.copy(alpha = 0.03f), 
                modifier = Modifier.size(60.dp)
            )
            
            AnimatedContent(
                targetState = symbol,
                transitionSpec = {
                    if (isSpinning) {
                        (slideInVertically { it } + fadeIn() with slideOutVertically { -it } + fadeOut())
                            .using(SizeTransform(clip = false))
                    } else {
                        fadeIn(animationSpec = tween(300)) with fadeOut(animationSpec = tween(300))
                    }
                },
                label = "SlotSpin"
            ) { targetSymbol ->
                Text(
                    targetSymbol, 
                    style = androidx.compose.ui.text.TextStyle(
                        fontSize = 44.sp,
                        shadow = androidx.compose.ui.graphics.Shadow(
                            color = Color.Black,
                            offset = androidx.compose.ui.geometry.Offset(2f, 2f),
                            blurRadius = 4f
                        )
                    )
                )
            }
        }
    }
}
