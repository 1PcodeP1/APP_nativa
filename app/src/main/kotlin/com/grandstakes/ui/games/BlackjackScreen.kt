package com.grandstakes.ui.games

import androidx.compose.animation.*
import androidx.compose.animation.core.*
import androidx.compose.foundation.BorderStroke
import androidx.compose.foundation.Canvas
import androidx.compose.foundation.background
import androidx.compose.foundation.border
import androidx.compose.foundation.clickable
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.lazy.LazyRow
import androidx.compose.foundation.lazy.items
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.AddCircleOutline
import androidx.compose.material.icons.filled.Diamond
import androidx.compose.material.icons.filled.RemoveCircleOutline
import androidx.compose.material.icons.filled.Swipe
import androidx.compose.material3.*
import androidx.compose.runtime.*
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.alpha
import androidx.compose.ui.draw.clip
import androidx.compose.ui.draw.rotate
import androidx.compose.ui.graphics.Brush
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.graphics.drawscope.rotate
import androidx.compose.ui.text.font.FontStyle
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.text.style.TextAlign
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import androidx.hilt.navigation.compose.hiltViewModel
import com.grandstakes.logic.Deck
import com.grandstakes.logic.PlayingCard
import com.grandstakes.ui.main.LobbyViewModel
import com.grandstakes.ui.components.GrandStakesButton
import com.grandstakes.ui.theme.GoldPrimary

@Composable
fun BlackjackScreen(
    onNavigateBack: () -> Unit,
    viewModel: LobbyViewModel = hiltViewModel()
) {
    val deck = remember { Deck() }
    var userHand by remember { mutableStateOf(listOf<PlayingCard>()) }
    var dealerHand by remember { mutableStateOf(listOf<PlayingCard>()) }
    var isPlaying by remember { mutableStateOf(false) }
    var gameOver by remember { mutableStateOf(false) }
    var gameMessage by remember { mutableStateOf("Place your bet.") }
    var betAmount by remember { mutableIntStateOf(100) }
    var activeBet by remember { mutableIntStateOf(0) }
    
    val userBalance by viewModel.currentUser.collectAsState()
    val balance = userBalance?.balance ?: 0

    fun calculateHand(hand: List<PlayingCard>): Int {
        var total = hand.sumOf { it.blackjackValue }
        var aces = hand.count { it.rank.label == "A" }
        while (total > 21 && aces > 0) {
            total -= 10
            aces--
        }
        return total
    }

    fun endGame() {
        gameOver = true
        isPlaying = false
        val uScore = calculateHand(userHand)
        val dScore = calculateHand(dealerHand)

        if (uScore <= 21) {
            if (uScore == 21 && userHand.size == 2 && !(dScore == 21 && dealerHand.size == 2)) {
                gameMessage = "BLACKJACK! YOU WIN 3:2"
                viewModel.updateBalance((activeBet * 2.5).toInt(), "Blackjack Win")
            } else if (dScore > 21 || uScore > dScore) {
                gameMessage = "YOU WIN!"
                viewModel.updateBalance(activeBet * 2, "Blackjack Win")
            } else if (uScore < dScore) {
                gameMessage = "DEALER WINS."
            } else {
                gameMessage = "PUSH (TIE)."
                viewModel.updateBalance(activeBet, "Blackjack Push")
            }
        } else {
            gameMessage = "BUST! YOU LOSE."
        }
    }

    fun deal() {
        if (balance < betAmount) {
            gameMessage = "Not enough funds."
            return
        }
        viewModel.updateBalance(-betAmount, "Blackjack Bet")
        activeBet = betAmount
        deck.reset()
        userHand = listOf(deck.draw(), deck.draw())
        dealerHand = listOf(deck.draw(), deck.draw())
        isPlaying = true
        gameOver = false
        gameMessage = ""
        
        if (calculateHand(userHand) == 21) {
            endGame()
        }
    }

    fun hit() {
        userHand = userHand + deck.draw()
        if (calculateHand(userHand) > 21) {
            endGame()
        }
    }

    fun stand() {
        while (calculateHand(dealerHand) < 17) {
            dealerHand = dealerHand + deck.draw()
        }
        endGame()
    }

    Box(modifier = Modifier.fillMaxSize().background(Color(0xFF0A0A0A))) {
        // Red Felt background overlay (Subtle)
        Box(
            modifier = Modifier
                .fillMaxSize()
                .padding(-50.dp)
                .clip(RoundedCornerShape(400.dp))
                .background(Color(0xFF8B0000).copy(alpha = 0.15f))
                .border(1.dp, GoldPrimary.copy(alpha = 0.05f), RoundedCornerShape(400.dp))
        )
        
        // Watermark
        Box(modifier = Modifier.fillMaxSize(), contentAlignment = Alignment.Center) {
            Text(
                "GRAND\nSTAKES",
                textAlign = TextAlign.Center,
                style = MaterialTheme.typography.displayLarge.copy(
                    fontSize = 80.sp,
                    color = Color.White.copy(alpha = 0.02f),
                    lineHeight = 70.sp
                )
            )
        }

        Column(
            modifier = Modifier.fillMaxSize().statusBarsPadding().navigationBarsPadding(),
            horizontalAlignment = Alignment.CenterHorizontally
        ) {
            Spacer(modifier = Modifier.height(32.dp))
            Text("DEALER STANDS ON 17", style = MaterialTheme.typography.labelSmall.copy(color = GoldPrimary, letterSpacing = 4.sp))
            Spacer(modifier = Modifier.height(24.dp))

            // Dealer Hand
            if (dealerHand.isNotEmpty()) {
                HandView(hand = dealerHand, isDealer = true, hideFirst = !gameOver)
            }

            Spacer(modifier = Modifier.weight(1f))

            // Center Banner
            Surface(
                color = GoldPrimary.copy(alpha = 0.1f),
                border = BorderStroke(0.5.dp, GoldPrimary.copy(alpha = 0.3f)),
                shape = RoundedCornerShape(0.dp)
            ) {
                Text(
                    "BLACKJACK PAYS 3 TO 2",
                    modifier = Modifier.padding(horizontal = 32.dp, vertical = 6.dp),
                    style = MaterialTheme.typography.labelSmall.copy(color = GoldPrimary, fontWeight = FontWeight.ExtraBold)
                )
            }

            Spacer(modifier = Modifier.weight(1f))

            // Player Hand
            if (userHand.isNotEmpty()) {
                HandView(hand = userHand)
            }

            Spacer(modifier = Modifier.height(16.dp))

            if (gameMessage.isNotEmpty()) {
                Text(gameMessage, style = MaterialTheme.typography.headlineMedium.copy(color = GoldPrimary))
            }

            Spacer(modifier = Modifier.height(24.dp))

            // Controls
            if (!isPlaying && !gameOver || (gameOver && !isPlaying)) {
                Column(horizontalAlignment = Alignment.CenterHorizontally) {
                    Row(verticalAlignment = Alignment.CenterVertically) {
                        IconButton(onClick = { if (betAmount > 10) betAmount -= 10 }) {
                            Icon(Icons.Default.RemoveCircleOutline, contentDescription = null, tint = GoldPrimary)
                        }
                        Text("$${betAmount}", style = MaterialTheme.typography.displayLarge.copy(color = Color.White, fontSize = 48.sp))
                        IconButton(onClick = { if (betAmount + 10 <= balance) betAmount += 10 }) {
                            Icon(Icons.Default.AddCircleOutline, contentDescription = null, tint = GoldPrimary)
                        }
                    }
                    Spacer(modifier = Modifier.height(24.dp))
                    GrandStakesButton(
                        text = "PLACE BET",
                        onClick = { deal() },
                        modifier = Modifier.width(240.dp)
                    )
                }
            } else {
                Row(
                    modifier = Modifier.fillMaxWidth().padding(horizontal = 16.dp),
                    horizontalArrangement = Arrangement.SpaceEvenly
                ) {
                    GameActionButton("FOLD", onClick = { /* Surrender logic */ })
                    GameActionButton("STAND", onClick = { stand() })
                    GameActionButton("HIT", onClick = { hit() }, isPrimary = true)
                    GameActionButton("DOUBLE", onClick = { /* Double down */ })
                }
            }
            Spacer(modifier = Modifier.height(32.dp))
        }
    }
}

@Composable
fun GameActionButton(label: String, onClick: () -> Unit, isPrimary: Boolean = false) {
    Surface(
        modifier = Modifier
            .size(70.dp)
            .clickable(onClick = onClick),
        color = if (isPrimary) GoldPrimary else Color.Transparent,
        border = if (isPrimary) null else BorderStroke(1.dp, GoldPrimary.copy(alpha = 0.5f)),
        shape = RoundedCornerShape(0.dp)
    ) {
        Box(contentAlignment = Alignment.Center) {
            Text(
                label,
                style = MaterialTheme.typography.labelSmall.copy(
                    color = if (isPrimary) Color.Black else Color.White,
                    fontSize = 10.sp,
                    fontWeight = FontWeight.ExtraBold,
                    letterSpacing = 1.sp
                )
            )
        }
    }
}

@Composable
fun HandView(hand: List<PlayingCard>, isDealer: Boolean = false, hideFirst: Boolean = false) {
    Row(
        modifier = Modifier.fillMaxWidth(),
        horizontalArrangement = Arrangement.Center
    ) {
        hand.forEachIndexed { index, card ->
            val isHidden = isDealer && hideFirst && index == 0
            PlayingCardView(card = card, isHidden = isHidden)
        }
    }
}

@Composable
fun PlayingCardView(card: PlayingCard, isHidden: Boolean) {
    val slideAnim = remember { Animatable(initialValue = -1f) }
    LaunchedEffect(Unit) {
        slideAnim.animateTo(0f, animationSpec = tween(500, easing = EaseOutCubic))
    }

    Box(
        modifier = Modifier
            .padding(horizontal = 4.dp)
            .offset(y = (slideAnim.value * 100).dp)
            .size(width = 80.dp, height = 110.dp)
            .background(if (isHidden) Color(0xFF1E1E1E) else Color(0xFFEAEAEA))
            .border(
                if (isHidden) BorderStroke(1.dp, GoldPrimary.copy(alpha = 0.3f)) else BorderStroke(0.dp, Color.Transparent),
                RoundedCornerShape(0.dp)
            )
    ) {
        if (isHidden) {
            Icon(Icons.Default.Diamond, contentDescription = null, tint = GoldPrimary, modifier = Modifier.align(Alignment.Center).size(24.dp))
        } else {
            val color = if (card.suit.isRed) Color(0xFFFF5252) else Color(0xFF0A0A0A)
            Column(modifier = Modifier.padding(6.dp)) {
                Text(card.rank.label, color = color, fontWeight = FontWeight.ExtraBold, fontSize = 18.sp)
                Text(card.suit.symbol, color = color.copy(alpha = 0.5f), fontSize = 12.sp)
                Spacer(modifier = Modifier.weight(1f))
                Icon(Icons.Default.Diamond, contentDescription = null, tint = color.copy(alpha = 0.05f), modifier = Modifier.align(Alignment.CenterHorizontally).size(32.dp))
                Spacer(modifier = Modifier.weight(1f))
                Column(modifier = Modifier.rotate(180f).align(Alignment.End)) {
                    Text(card.rank.label, color = color, fontWeight = FontWeight.ExtraBold, fontSize = 18.sp)
                    Text(card.suit.symbol, color = color.copy(alpha = 0.5f), fontSize = 12.sp)
                }
            }
        }
    }
}
