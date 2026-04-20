package com.grandstakes.ui.games

import androidx.compose.foundation.background
import androidx.compose.foundation.clickable
import androidx.compose.foundation.layout.*
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.automirrored.filled.ArrowBack
import androidx.compose.material3.*
import androidx.compose.runtime.*
import androidx.compose.ui.Alignment
import androidx.compose.material3.ExperimentalMaterial3Api
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import androidx.hilt.navigation.compose.hiltViewModel
import com.grandstakes.logic.Deck
import com.grandstakes.logic.PlayingCard
import com.grandstakes.ui.main.LobbyViewModel
import com.grandstakes.ui.theme.GoldPrimary
import kotlinx.coroutines.delay
import kotlinx.coroutines.launch

@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun BaccaratScreen(
    onNavigateBack: () -> Unit,
    viewModel: LobbyViewModel = hiltViewModel()
) {
    val deck = remember { Deck() }
    val scope = rememberCoroutineScope()
    
    var playerHand by remember { mutableStateOf(mutableListOf<PlayingCard>()) }
    var bankerHand by remember { mutableStateOf(mutableListOf<PlayingCard>()) }
    var message by remember { mutableStateOf("Select a bet zone.")}
    var isPlaying by remember { mutableStateOf(false) }

    fun calculateBaccarat(hand: List<PlayingCard>): Int {
        return hand.sumOf { it.baccaratValue } % 10
    }

    fun play(betType: Int) { // 0: Banker, 1: Player, 2: Tie
        if (isPlaying) return
        isPlaying = true
        message = "Dealing..."
        
        scope.launch {
            deck.reset()
            playerHand = mutableListOf(deck.draw(), deck.draw())
            bankerHand = mutableListOf(deck.draw(), deck.draw())
            delay(1000)
            
            val pVal = calculateBaccarat(playerHand)
            val bVal = calculateBaccarat(bankerHand)
            
            // Winning logic
            val winner = when {
                pVal > bVal -> 1
                bVal > pVal -> 0
                else -> 2
            }
            
            message = if (winner == betType) "YOU WON!" else "YOU LOST."
            if (winner == betType) {
                val multiplier = when(winner) {
                    0 -> 1.95f
                    1 -> 2.0f
                    else -> 9.0f
                }
                viewModel.updateBalance((100 * multiplier).toInt(), "Baccarat Win")
            } else {
                viewModel.updateBalance(-100, "Baccarat bet")
            }
            isPlaying = false
        }
    }

    Scaffold(
        containerColor = Color(0xFF1A1A1A),
        topBar = {
             CenterAlignedTopAppBar(
                title = { Text("BACCARAT PUNTO BANCO", style = MaterialTheme.typography.titleLarge) },
                navigationIcon = { IconButton(onClick = onNavigateBack) { Icon(Icons.AutoMirrored.Filled.ArrowBack, contentDescription = null, tint = GoldPrimary) } },
                colors = TopAppBarDefaults.centerAlignedTopAppBarColors(containerColor = Color.Transparent, titleContentColor = GoldPrimary)
            )
        }
    ) { padding ->
        Column(
            modifier = Modifier.fillMaxSize().padding(padding).padding(24.dp),
            horizontalAlignment = Alignment.CenterHorizontally
        ) {
            Text(message, style = MaterialTheme.typography.headlineMedium.copy(color = GoldPrimary))
            Spacer(modifier = Modifier.height(32.dp))
            
            if (playerHand.isNotEmpty()) {
                Row(Modifier.fillMaxWidth(), horizontalArrangement = Arrangement.SpaceEvenly) {
                    HandColumn("BANKER", bankerHand)
                    HandColumn("PLAYER", playerHand)
                }
            }
            
            Spacer(modifier = Modifier.height(64.dp))
            
            BetZone("BANKER", "PAYS 0.95 TO 1", Color(0xFFD95252)) { play(0) }
            Spacer(modifier = Modifier.height(16.dp))
            BetZone("PLAYER", "PAYS 1 TO 1", GoldPrimary) { play(1) }
            Spacer(modifier = Modifier.height(16.dp))
            BetZone("TIE", "PAYS 8 TO 1", Color.DarkGray) { play(2) }
        }
    }
}

@Composable
fun HandColumn(title: String, hand: List<PlayingCard>) {
    Column(horizontalAlignment = Alignment.CenterHorizontally) {
        Text(title, color = Color.White.copy(alpha = 0.6f), fontWeight = FontWeight.Bold)
        Text("${hand.sumOf { it.baccaratValue } % 10}", fontSize = 48.sp, color = Color.White)
    }
}

@Composable
fun BetZone(title: String, payout: String, color: Color, onClick: () -> Unit) {
    Surface(
        modifier = Modifier.fillMaxWidth().height(80.dp).clickable(onClick = onClick),
        color = color.copy(alpha = 0.8f),
        shape = androidx.compose.foundation.shape.RoundedCornerShape(2.dp)
    ) {
        Column(Modifier.padding(8.dp), horizontalAlignment = Alignment.CenterHorizontally, verticalArrangement = Arrangement.Center) {
            Text(title, fontSize = 24.sp, fontWeight = FontWeight.Bold, color = if (color == GoldPrimary) Color.Black else Color.White)
            Text(payout, fontSize = 10.sp, color = if (color == GoldPrimary) Color.Black else Color.White)
        }
    }
}
