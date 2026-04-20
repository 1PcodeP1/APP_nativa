package com.grandstakes.ui.games

import androidx.compose.foundation.BorderStroke
import androidx.compose.foundation.background
import androidx.compose.foundation.border
import androidx.compose.foundation.clickable
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.Add
import androidx.compose.material.icons.filled.Diamond
import androidx.compose.material.icons.filled.Remove
import androidx.compose.material3.*
import androidx.compose.runtime.*
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.alpha
import androidx.compose.ui.draw.rotate
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
import kotlinx.coroutines.delay
import kotlinx.coroutines.launch

@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun BlackjackScreen(
    onNavigateBack: () -> Unit,
    viewModel: LobbyViewModel = hiltViewModel()
) {
    val scope = rememberCoroutineScope()
    val deck = remember { Deck() }
    
    // Game State
    var userHand by remember { mutableStateOf(listOf<PlayingCard>()) }
    var dealerHand by remember { mutableStateOf(listOf<PlayingCard>()) }
    var isPlaying by remember { mutableStateOf(false) }
    var gameOver by remember { mutableStateOf(false) }
    var isProcessing by remember { mutableStateOf(false) }
    var message by remember { mutableStateOf("PLACE YOUR BET") }
    var betAmount by remember { mutableIntStateOf(100) }
    var activeBet by remember { mutableIntStateOf(0) }

    val user by viewModel.currentUser.collectAsState()
    val balance = user?.balance ?: 0

    fun calculateHand(hand: List<PlayingCard>): Int {
        if (hand.isEmpty()) return 0
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

        if (uScore > 21) {
            message = "BUST! YOU LOSE."
        } else {
            if (uScore == 21 && userHand.size == 2 && !(dScore == 21 && dealerHand.size == 2)) {
                message = "BLACKJACK! WIN 3:2"
                viewModel.updateBalance((activeBet * 2.5).toInt(), "Blackjack Win")
            } else if (dScore > 21 || uScore > dScore) {
                message = "YOU WIN!"
                viewModel.updateBalance(activeBet * 2, "Blackjack Win")
            } else if (uScore < dScore) {
                message = "DEALER WINS."
            } else {
                message = "PUSH (TIE)."
                viewModel.updateBalance(activeBet, "Blackjack Push")
            }
        }
    }

    fun deal() {
        if (isProcessing) return
        if (balance < betAmount) {
            message = "INSUFFICIENT CREDIT"
            return
        }

        scope.launch {
            isProcessing = true
            message = "DEALING..."
            viewModel.updateBalance(-betAmount, "Blackjack Bet")
            activeBet = betAmount
            deck.reset()
            userHand = emptyList()
            dealerHand = emptyList()
            gameOver = false
            isPlaying = true

            // Animation sequence
            userHand = userHand + deck.draw()
            delay(400)
            dealerHand = dealerHand + deck.draw()
            delay(400)
            userHand = userHand + deck.draw()
            delay(400)
            dealerHand = dealerHand + deck.draw()
            delay(400)

            message = ""
            if (calculateHand(userHand) == 21) {
                endGame()
            }
            isProcessing = false
        }
    }

    fun hit() {
        if (isProcessing || gameOver) return
        scope.launch {
            isProcessing = true
            userHand = userHand + deck.draw()
            if (calculateHand(userHand) > 21) {
                endGame()
            }
            isProcessing = false
        }
    }

    fun stand() {
        if (isProcessing || gameOver) return
        scope.launch {
            isProcessing = true
            while (calculateHand(dealerHand) < 17) {
                message = "DEALER DRAWS..."
                dealerHand = dealerHand + deck.draw()
                delay(600)
            }
            message = ""
            endGame()
            isProcessing = false
        }
    }

    Scaffold(
        containerColor = Color.Black,
        topBar = {
            CenterAlignedTopAppBar(
                title = { Text("GRAND BLACKJACK", style = MaterialTheme.typography.labelSmall.copy(color = GoldPrimary, letterSpacing = 2.sp)) },
                navigationIcon = {
                    TextButton(onClick = onNavigateBack) {
                        Text("EXIT", color = GoldPrimary)
                    }
                },
                colors = TopAppBarDefaults.centerAlignedTopAppBarColors(containerColor = Color.Black)
            )
        }
    ) { padding ->
        Column(
            modifier = Modifier
                .fillMaxSize()
                .padding(padding)
                .padding(24.dp),
            horizontalAlignment = Alignment.CenterHorizontally
        ) {
            Text(
                "DEALER STANDS ON 17   •   PAYS 3:2",
                style = MaterialTheme.typography.labelSmall.copy(color = GoldPrimary.copy(alpha = 0.5f), letterSpacing = 1.sp)
            )
            
            Spacer(modifier = Modifier.weight(1f))

            // Dealer Area
            Column(horizontalAlignment = Alignment.CenterHorizontally) {
                BJHandView(hand = dealerHand, isDealer = true, isHidden = !gameOver && isPlaying)
                Spacer(modifier = Modifier.height(8.dp))
                if (dealerHand.isNotEmpty()) {
                    Text(
                        if (!gameOver && isPlaying) "?" else calculateHand(dealerHand).toString(),
                        style = MaterialTheme.typography.titleMedium.copy(color = Color.White.copy(alpha = 0.5f))
                    )
                }
            }

            Spacer(modifier = Modifier.weight(1f))

            // Message Area
            Text(
                message.uppercase(),
                style = MaterialTheme.typography.headlineSmall.copy(
                    color = GoldPrimary,
                    fontWeight = FontWeight.Bold,
                    textAlign = TextAlign.Center
                ),
                modifier = Modifier.height(40.dp)
            )

            Spacer(modifier = Modifier.weight(1f))

            // Player Area
            Column(horizontalAlignment = Alignment.CenterHorizontally) {
                if (userHand.isNotEmpty()) {
                    Text(
                        calculateHand(userHand).toString(),
                        style = MaterialTheme.typography.titleMedium.copy(color = GoldPrimary)
                    )
                }
                Spacer(modifier = Modifier.height(8.dp))
                BJHandView(hand = userHand)
            }

            Spacer(modifier = Modifier.weight(1f))

            // Controls
            if (!isPlaying || (gameOver && !isProcessing)) {
                BetControls(
                    betAmount = betAmount,
                    balance = balance,
                    onBetChange = { betAmount = it },
                    onDeal = { deal() },
                    disabled = isProcessing
                )
            } else {
                ActionControls(
                    onHit = { hit() },
                    onStand = { stand() },
                    disabled = isProcessing
                )
            }
        }
    }
}

@Composable
fun BJHandView(hand: List<PlayingCard>, isDealer: Boolean = false, isHidden: Boolean = false) {
    Row(
        modifier = Modifier
            .fillMaxWidth()
            .height(120.dp),
        horizontalArrangement = Arrangement.Center,
        verticalAlignment = Alignment.CenterVertically
    ) {
        hand.forEachIndexed { index, card ->
            key(card.id) {
                BJCardView(
                    card = card,
                    isHidden = isDealer && isHidden && index == 0
                )
            }
        }
    }
}

@Composable
fun BJCardView(card: PlayingCard, isHidden: Boolean) {
    Surface(
        modifier = Modifier
            .padding(horizontal = 4.dp)
            .size(width = 70.dp, height = 100.dp),
        color = if (isHidden) Color(0xFF1E1E1E) else Color.White,
        shape = RoundedCornerShape(4.dp),
        border = BorderStroke(1.dp, GoldPrimary.copy(alpha = 0.2f))
    ) {
        if (isHidden) {
            Box(contentAlignment = Alignment.Center) {
                Icon(Icons.Default.Diamond, contentDescription = null, tint = GoldPrimary, modifier = Modifier.size(24.dp))
            }
        } else {
            val color = if (card.suit.isRed) Color(0xFFFF5252) else Color.Black
            Column(modifier = Modifier.padding(6.dp)) {
                Text(card.rank.label, color = color, fontWeight = FontWeight.Black, fontSize = 16.sp)
                Text(card.suit.symbol, color = color, fontSize = 12.sp)
                Spacer(modifier = Modifier.weight(1f))
                Box(modifier = Modifier.fillMaxWidth(), contentAlignment = Alignment.Center) {
                    Icon(Icons.Default.Diamond, contentDescription = null, tint = color.copy(alpha = 0.05f), modifier = Modifier.size(32.dp))
                }
                Spacer(modifier = Modifier.weight(1f))
                Column(modifier = Modifier.rotate(180f).align(Alignment.End)) {
                    Text(card.rank.label, color = color, fontWeight = FontWeight.Black, fontSize = 16.sp)
                    Text(card.suit.symbol, color = color, fontSize = 12.sp)
                }
            }
        }
    }
}

@Composable
fun BetControls(
    betAmount: Int,
    balance: Int,
    onBetChange: (Int) -> Unit,
    onDeal: () -> Unit,
    disabled: Boolean
) {
    Column(horizontalAlignment = Alignment.CenterHorizontally) {
        Row(verticalAlignment = Alignment.CenterVertically) {
            IconButton(onClick = { if (betAmount > 10) onBetChange(betAmount - 10) }, enabled = !disabled) {
                Icon(Icons.Default.Remove, contentDescription = null, tint = GoldPrimary)
            }
            Text(
                "$${betAmount}",
                style = MaterialTheme.typography.displayMedium.copy(color = Color.White, fontSize = 42.sp)
            )
            IconButton(onClick = { if (betAmount + 10 <= balance) onBetChange(betAmount + 10) }, enabled = !disabled) {
                Icon(Icons.Default.Add, contentDescription = null, tint = GoldPrimary)
            }
        }
        Spacer(modifier = Modifier.height(16.dp))
        GrandStakesButton(
            text = "PLACE BET",
            onClick = onDeal,
            enabled = !disabled && balance >= betAmount,
            modifier = Modifier.width(220.dp)
        )
    }
}

@Composable
fun ActionControls(onHit: () -> Unit, onStand: () -> Unit, disabled: Boolean) {
    Row(
        modifier = Modifier.fillMaxWidth().padding(horizontal = 32.dp),
        horizontalArrangement = Arrangement.spacedBy(16.dp)
    ) {
        Button(
            onClick = onStand,
            modifier = Modifier.weight(1f).height(56.dp),
            enabled = !disabled,
            colors = ButtonDefaults.buttonColors(containerColor = Color.Transparent),
            border = BorderStroke(1.dp, GoldPrimary),
            shape = RoundedCornerShape(4.dp)
        ) {
            Text("STAND", color = GoldPrimary, fontWeight = FontWeight.Bold)
        }
        Button(
            onClick = onHit,
            modifier = Modifier.weight(1f).height(56.dp),
            enabled = !disabled,
            colors = ButtonDefaults.buttonColors(containerColor = GoldPrimary),
            shape = RoundedCornerShape(4.dp)
        ) {
            Text("HIT", color = Color.Black, fontWeight = FontWeight.Bold)
        }
    }
}
