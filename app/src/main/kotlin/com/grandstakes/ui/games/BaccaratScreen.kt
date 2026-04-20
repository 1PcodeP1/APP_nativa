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
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.Diamond
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import androidx.hilt.navigation.compose.hiltViewModel
import com.grandstakes.ui.components.GrandStakesButton
import com.grandstakes.logic.Deck
import com.grandstakes.logic.PlayingCard
import com.grandstakes.ui.main.LobbyViewModel
import com.grandstakes.ui.theme.GoldPrimary
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
    var message by remember { mutableStateOf("Select a bet zone.")}
    var isPlaying by remember { mutableStateOf(false) }
    var selectedBetType by remember { mutableStateOf<Int?>(null) }
    val betAmount = 100

    fun calculateBaccarat(hand: List<PlayingCard>): Int {
        return hand.sumOf { it.baccaratValue } % 10
    }

    fun play(betType: Int) { // 0: Banker, 1: Player, 2: Tie
        if (isPlaying || balance < betAmount) return
        
        isPlaying = true
        selectedBetType = betType
        message = "Dealing..."
        viewModel.updateBalance(-betAmount, "Baccarat Bet")
        
        scope.launch {
            deck.reset()
            playerHand = listOf(deck.draw(), deck.draw())
            bankerHand = listOf(deck.draw(), deck.draw())
            delay(1000)
            
            var pVal = calculateBaccarat(playerHand)
            var bVal = calculateBaccarat(bankerHand)
            
            // Third card logic
            if (pVal < 8 && bVal < 8) {
                if (pVal <= 5) {
                    playerHand = playerHand + deck.draw()
                    pVal = calculateBaccarat(playerHand)
                    delay(800)
                }
                if (bVal <= 5) {
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
                message = "YOU LOST."
            }
            isPlaying = false
        }
    }

    Column(
        modifier = Modifier
            .fillMaxSize()
            .background(Color(0xFF0A0A0A))
            .statusBarsPadding()
            .navigationBarsPadding(),
        horizontalAlignment = Alignment.CenterHorizontally
    ) {
        Spacer(modifier = Modifier.height(32.dp))
        Text(
            message.uppercase(), 
            style = MaterialTheme.typography.labelSmall.copy(color = GoldPrimary, letterSpacing = 4.sp)
        )
        
        Spacer(modifier = Modifier.weight(1f))
        
        // HUD
        Row(
            modifier = Modifier.fillMaxWidth().padding(horizontal = 32.dp),
            horizontalArrangement = Arrangement.SpaceBetween,
            verticalAlignment = Alignment.CenterVertically
        ) {
            ScoreColumn("BANKER", bankerHand, calculateBaccarat(bankerHand), Color(0xFFFF5252))
            Box(modifier = Modifier.size(1.dp, 80.dp).background(GoldPrimary.copy(alpha = 0.1f)))
            ScoreColumn("PLAYER", playerHand, calculateBaccarat(playerHand), GoldPrimary)
        }
        
        Spacer(modifier = Modifier.weight(1f))
        
        // Betting Zones
        Column(
            modifier = Modifier
                .padding(24.dp)
                .fillMaxWidth()
        ) {
            BetZone("BANKER", "PAYS 0.95 TO 1", Color(0xFFFF5252), isPlaying) { play(0) }
            Spacer(modifier = Modifier.height(16.dp))
            BetZone("PLAYER", "PAYS 1 TO 1", GoldPrimary, isPlaying) { play(1) }
            Spacer(modifier = Modifier.height(16.dp))
            BetZone("TIE", "PAYS 8 TO 1", Color.White, isPlaying) { play(2) }
        }
        
        Spacer(modifier = Modifier.height(48.dp))
    }
}

@Composable
fun ScoreColumn(title: String, hand: List<PlayingCard>, score: Int, color: Color) {
    Column(horizontalAlignment = Alignment.CenterHorizontally) {
        Text(title, style = MaterialTheme.typography.labelSmall.copy(color = color, letterSpacing = 2.sp))
        Spacer(modifier = Modifier.height(8.dp))
        AnimatedContent(
            targetState = score,
            transitionSpec = { fadeIn() togetherWith fadeOut() },
            label = "score"
        ) { targetScore ->
            Text(
                if (hand.isEmpty()) "0" else targetScore.toString(),
                style = MaterialTheme.typography.displayLarge.copy(color = Color.White, fontSize = 72.sp)
            )
        }
    }
}

@Composable
fun BetZone(
    title: String, 
    payout: String, 
    color: Color, 
    disabled: Boolean,
    onClick: () -> Unit
) {
    Surface(
        modifier = Modifier
            .fillMaxWidth()
            .height(80.dp)
            .clickable(enabled = !disabled, onClick = onClick),
        color = Color.Transparent,
        border = BorderStroke(1.dp, color.copy(alpha = 0.5f)),
        shape = RoundedCornerShape(0.dp)
    ) {
        Row(
            modifier = Modifier.fillMaxSize().padding(horizontal = 24.dp),
            verticalAlignment = Alignment.CenterVertically,
            horizontalArrangement = Arrangement.SpaceBetween
        ) {
            Column {
                Text(
                    title, 
                    style = MaterialTheme.typography.titleLarge.copy(
                        color = color,
                        letterSpacing = 2.sp
                    )
                )
                Text(
                    payout, 
                    style = MaterialTheme.typography.labelSmall.copy(
                        color = Color.White.copy(alpha = 0.4f),
                        fontSize = 9.sp,
                        letterSpacing = 1.sp
                    )
                )
            }
            Icon(
                Icons.Default.Diamond, 
                contentDescription = null, 
                tint = color.copy(alpha = 0.2f),
                modifier = Modifier.size(24.dp)
            )
        }
    }
}
