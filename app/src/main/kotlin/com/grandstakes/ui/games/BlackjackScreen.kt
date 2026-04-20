package com.grandstakes.ui.games

import androidx.compose.foundation.background
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.lazy.LazyRow
import androidx.compose.foundation.lazy.items
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

@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun BlackjackScreen(
    onNavigateBack: () -> Unit,
    viewModel: LobbyViewModel = hiltViewModel()
) {
    val deck = remember { Deck() }
    var userHand by remember { mutableStateOf(mutableListOf<PlayingCard>()) }
    var dealerHand by remember { mutableStateOf(mutableListOf<PlayingCard>()) }
    var gameMessage by remember { mutableStateOf("Place your bet.") }
    var isPlaying by remember { mutableStateOf(false) }

    fun calculateHand(hand: List<PlayingCard>): Int {
        var total = hand.sumOf { it.blackjackValue }
        var aces = hand.count { it.rank.label == "A" }
        while (total > 21 && aces > 0) {
            total -= 10
            aces--
        }
        return total
    }

    fun deal() {
        isPlaying = true
        deck.reset()
        userHand = mutableListOf(deck.draw(), deck.draw())
        dealerHand = mutableListOf(deck.draw())
        gameMessage = "Hit or Stand?"
    }

    fun hit() {
        userHand.add(deck.draw())
        userHand = userHand.toMutableList() // Force recomposition
        if (calculateHand(userHand) > 21) {
            gameMessage = "BUST! House Wins."
            isPlaying = false
            viewModel.updateBalance(-100, "Blackjack Loss")
        }
    }

    fun stand() {
        while (calculateHand(dealerHand) < 17) {
            dealerHand.add(deck.draw())
        }
        dealerHand = dealerHand.toMutableList()
        val uScore = calculateHand(userHand)
        val dScore = calculateHand(dealerHand)
        
        gameMessage = when {
            dScore > 21 -> "Dealer Busts! YOU WIN."
            uScore > dScore -> "YOU WIN!"
            dScore > uScore -> "Dealer Wins."
            else -> "PUSH."
        }
        
        if (gameMessage.contains("WIN")) viewModel.updateBalance(200, "Blackjack Win")
        else if (gameMessage.contains("PUSH")) viewModel.updateBalance(100, "Blackjack Push")
        
        isPlaying = false
    }

    Scaffold(
        containerColor = Color(0xFF0A2E0A), // Atlantic City Green
        topBar = {
            CenterAlignedTopAppBar(
                title = { Text("BLACKJACK Royale", style = MaterialTheme.typography.titleLarge) },
                navigationIcon = { IconButton(onClick = onNavigateBack) { Icon(Icons.AutoMirrored.Filled.ArrowBack, contentDescription = null, tint = Color.White) } },
                colors = TopAppBarDefaults.centerAlignedTopAppBarColors(containerColor = Color.Transparent, titleContentColor = Color.White)
            )
        }
    ) { padding ->
        Column(
            modifier = Modifier.fillMaxSize().padding(padding).padding(24.dp),
            horizontalAlignment = Alignment.CenterHorizontally,
            verticalArrangement = Arrangement.SpaceBetween
        ) {
            Text(gameMessage, style = MaterialTheme.typography.headlineMedium.copy(color = Color.White))

            Column(horizontalAlignment = Alignment.CenterHorizontally) {
                Text("DEALER: ${calculateHand(dealerHand)}", color = Color.White.copy(alpha = 0.7f))
                HandView(dealerHand)
            }

            Column(horizontalAlignment = Alignment.CenterHorizontally) {
                Text("PLAYER: ${calculateHand(userHand)}", color = Color.White.copy(alpha = 0.7f))
                HandView(userHand)
            }

            Row(Modifier.fillMaxWidth(), horizontalArrangement = Arrangement.SpaceEvenly) {
                if (!isPlaying) {
                    Button(onClick = ::deal, colors = ButtonDefaults.buttonColors(containerColor = GoldPrimary)) {
                        Text("DEAL HAND", color = Color.Black)
                    }
                } else {
                    Button(onClick = ::hit, colors = ButtonDefaults.buttonColors(containerColor = GoldPrimary)) {
                        Text("HIT")
                    }
                    Button(onClick = ::stand, colors = ButtonDefaults.buttonColors(containerColor = Color.White)) {
                        Text("STAND", color = Color.Black)
                    }
                }
            }
        }
    }
}

@Composable
fun HandView(hand: List<PlayingCard>) {
    LazyRow(modifier = Modifier.padding(16.dp)) {
        items(hand) { card ->
            CardContainer(card)
        }
    }
}

@Composable
fun CardContainer(card: PlayingCard) {
    Surface(
        modifier = Modifier.size(width = 80.dp, height = 110.dp).padding(4.dp),
        color = Color.White,
        shape = androidx.compose.foundation.shape.RoundedCornerShape(4.dp),
        shadowElevation = 4.dp
    ) {
        Column(Modifier.padding(8.dp), verticalArrangement = Arrangement.SpaceBetween) {
            Text(card.rank.label, color = if (card.suit.isRed) Color.Red else Color.Black, fontWeight = FontWeight.Bold)
            Text(card.suit.symbol, modifier = Modifier.align(Alignment.CenterHorizontally), fontSize = 24.sp)
            Text(card.rank.label, color = if (card.suit.isRed) Color.Red else Color.Black, modifier = Modifier.align(Alignment.End), fontWeight = FontWeight.Bold)
        }
    }
}
