package com.grandstakes.ui.games

import androidx.compose.animation.*
import androidx.compose.animation.core.*
import androidx.compose.foundation.BorderStroke
import androidx.compose.foundation.background
import androidx.compose.foundation.clickable
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material3.*
import androidx.compose.runtime.*
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.alpha
import androidx.compose.ui.draw.rotate
import androidx.compose.ui.graphics.Brush
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.text.style.TextAlign
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import androidx.hilt.navigation.compose.hiltViewModel
import com.grandstakes.logic.Deck
import com.grandstakes.logic.PlayingCard
import com.grandstakes.ui.main.LobbyViewModel
import com.grandstakes.ui.components.GrandStakesButton
import com.grandstakes.ui.theme.GoldPrimary
import com.grandstakes.ui.theme.FeltRedPrimary
import com.grandstakes.ui.theme.FeltRedDark
import kotlinx.coroutines.delay
import kotlinx.coroutines.launch

@Composable
fun BaccaratScreen(
    onNavigateBack: () -> Unit,
    viewModel: LobbyViewModel = hiltViewModel()
) {
    val deck = remember { Deck() }
    val scope = rememberCoroutineScope()
    
    val user by viewModel.currentUser.collectAsState()
    val balance = user?.balance ?: 0
    
    var playerHand by remember { mutableStateOf(listOf<PlayingCard>()) }
    var bankerHand by remember { mutableStateOf(listOf<PlayingCard>()) }
    var message by remember { mutableStateOf("PLACE YOUR BET") }
    var isPlaying by remember { mutableStateOf(false) }
    var isProcessing by remember { mutableStateOf(false) }
    var selectedBetType by remember { mutableStateOf<Int?>(null) }
    var activeBet by remember { mutableIntStateOf(0) }
    val betAmount = 100

    fun calculateBaccarat(hand: List<PlayingCard>): Int {
        return hand.sumOf { it.baccaratValue } % 10
    }

    fun play(betType: Int) { // 0: Banker, 1: Player, 2: Tie
        if (isProcessing || balance < betAmount) {
            if (balance < betAmount) message = "INSUFFICIENT FUNDS"
            return
        }
        
        scope.launch {
            isProcessing = true
            isPlaying = true
            selectedBetType = betType
            activeBet = betAmount
            message = "DEALING..."
            viewModel.updateBalance(-betAmount, "Baccarat Bet")
            
            deck.reset()
            playerHand = emptyList()
            bankerHand = emptyList()

            // Initial Deal
            delay(300)
            playerHand = playerHand + deck.draw()
            delay(400)
            bankerHand = bankerHand + deck.draw()
            delay(400)
            playerHand = playerHand + deck.draw()
            delay(400)
            bankerHand = bankerHand + deck.draw()
            delay(600)
            
            var pVal = calculateBaccarat(playerHand)
            var bVal = calculateBaccarat(bankerHand)
            
            // Third card logic
            if (pVal < 8 && bVal < 8) {
                if (pVal <= 5) {
                    message = "PLAYER DRAWS..."
                    playerHand = playerHand + deck.draw()
                    pVal = calculateBaccarat(playerHand)
                    delay(800)
                }
                if (bVal <= 5) {
                    message = "BANKER DRAWS..."
                    bankerHand = bankerHand + deck.draw()
                    bVal = calculateBaccarat(bankerHand)
                    delay(800)
                }
            }
            
            val winner = when {
                pVal > bVal -> 1
                bVal > pVal -> 0
                else -> 2
            }
            
            if (winner == betType) {
                message = "YOU WON!"
                val multiplier = when(winner) {
                    0 -> 1.95f
                    1 -> 2.0f
                    else -> 9.0f
                }
                viewModel.updateBalance((betAmount * multiplier).toInt(), "Baccarat Win")
            } else {
                message = if (winner == 0) "BANKER WINS" else if (winner == 1) "PLAYER WINS" else "TIE GAME"
            }
            
            delay(2000)
            isProcessing = false
            isPlaying = false
        }
    }

    Box(
        modifier = Modifier
            .fillMaxSize()
            .background(
                Brush.radialGradient(
                    colors = listOf(FeltRedPrimary, FeltRedDark, Color.Black),
                    radius = 3000f
                )
            )
    ) {
        // Watermark
        Box(modifier = Modifier.fillMaxSize(), contentAlignment = Alignment.Center) {
            Text(
                "GRAND\nSTAKES",
                textAlign = TextAlign.Center,
                modifier = Modifier.rotate(-15f).alpha(0.03f),
                style = MaterialTheme.typography.displayLarge.copy(
                    fontSize = 120.sp, color = Color.White, fontWeight = FontWeight.Black, lineHeight = 100.sp
                )
            )
        }

        Column(
            modifier = Modifier.fillMaxSize().statusBarsPadding().navigationBarsPadding().padding(24.dp),
            horizontalAlignment = Alignment.CenterHorizontally
        ) {
            // Header
            Row(
                modifier = Modifier.fillMaxWidth(),
                horizontalArrangement = Arrangement.SpaceBetween,
                verticalAlignment = Alignment.CenterVertically
            ) {
                TextButton(onClick = onNavigateBack) {
                    Text("← EXIT", color = GoldPrimary, fontWeight = FontWeight.Bold)
                }
                Surface(
                    color = GoldPrimary.copy(alpha = 0.1f),
                    shape = RoundedCornerShape(20.dp),
                    border = BorderStroke(1.dp, GoldPrimary.copy(alpha = 0.3f))
                ) {
                    Text(
                        "ROYAL BACCARAT",
                        modifier = Modifier.padding(horizontal = 16.dp, vertical = 4.dp),
                        style = MaterialTheme.typography.labelSmall.copy(color = GoldPrimary, letterSpacing = 2.sp)
                    )
                }
                Box(modifier = Modifier.size(40.dp))
            }
            
            Spacer(modifier = Modifier.weight(0.8f))

            // Banker Side
            Column(horizontalAlignment = Alignment.CenterHorizontally) {
                Text("BANKER", style = MaterialTheme.typography.labelSmall.copy(color = Color(0xFFFF5252), letterSpacing = 2.sp, fontWeight = FontWeight.Black))
                Spacer(modifier = Modifier.height(12.dp))
                BJHandView(hand = bankerHand)
                Spacer(modifier = Modifier.height(12.dp))
                if (bankerHand.isNotEmpty()) {
                    ScoreBadge(score = calculateBaccarat(bankerHand).toString(), isDealer = true)
                }
            }

            Spacer(modifier = Modifier.weight(1f))

            // Center message
            Text(
                message.uppercase(),
                style = MaterialTheme.typography.headlineMedium.copy(
                    color = GoldPrimary, fontWeight = FontWeight.ExtraBold, letterSpacing = 2.sp
                ),
                modifier = Modifier.height(48.dp)
            )

            Spacer(modifier = Modifier.weight(1f))

            // Player Side
            Column(horizontalAlignment = Alignment.CenterHorizontally) {
                if (playerHand.isNotEmpty()) {
                    ScoreBadge(score = calculateBaccarat(playerHand).toString(), isDealer = false)
                }
                Spacer(modifier = Modifier.height(12.dp))
                BJHandView(hand = playerHand)
                Spacer(modifier = Modifier.height(12.dp))
                Text("PLAYER", style = MaterialTheme.typography.labelSmall.copy(color = GoldPrimary, letterSpacing = 2.sp, fontWeight = FontWeight.Black))
            }

            Spacer(modifier = Modifier.weight(0.8f))

            // Betting Zones (Obsidian Style)
            Row(
                modifier = Modifier.fillMaxWidth().height(100.dp),
                horizontalArrangement = Arrangement.spacedBy(8.dp)
            ) {
                BaccaratBetZone("BANKER", "0.95:1", Color(0xFFFF5252), modifier = Modifier.weight(1f), disabled = isProcessing) { play(0) }
                BaccaratBetZone("TIE", "8:1", Color.White, modifier = Modifier.weight(0.8f), disabled = isProcessing) { play(2) }
                BaccaratBetZone("PLAYER", "1:1", GoldPrimary, modifier = Modifier.weight(1f), disabled = isProcessing) { play(1) }
            }
        }
    }
}

@Composable
fun BaccaratBetZone(title: String, payout: String, color: Color, modifier: Modifier, disabled: Boolean, onClick: () -> Unit) {
    Surface(
        modifier = modifier.fillMaxHeight().clickable(enabled = !disabled, onClick = onClick),
        color = Color.Black.copy(alpha = 0.6f),
        shape = RoundedCornerShape(4.dp),
        border = BorderStroke(1.dp, color.copy(alpha = 0.4f))
    ) {
        Column(
            modifier = Modifier.fillMaxSize(),
            verticalArrangement = Arrangement.Center,
            horizontalAlignment = Alignment.CenterHorizontally
        ) {
            Text(title, color = color, fontWeight = FontWeight.Black, fontSize = 14.sp, letterSpacing = 1.sp)
            Text(payout, color = Color.White.copy(alpha = 0.3f), fontSize = 10.sp)
        }
    }
}
