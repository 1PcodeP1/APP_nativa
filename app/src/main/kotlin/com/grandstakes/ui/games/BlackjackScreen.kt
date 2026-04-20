package com.grandstakes.ui.games

import androidx.compose.animation.core.*
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
import androidx.compose.ui.draw.clip
import androidx.compose.ui.draw.rotate
import androidx.compose.ui.draw.shadow
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
            delay(300)
            dealerHand = dealerHand + deck.draw()
            delay(300)
            userHand = userHand + deck.draw()
            delay(300)
            dealerHand = dealerHand + deck.draw()
            delay(300)

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
                delay(500)
            }
            message = ""
            endGame()
            isProcessing = false
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
        // Subtle Background Watermark
        Box(modifier = Modifier.fillMaxSize(), contentAlignment = Alignment.Center) {
            Text(
                "GRAND\nSTAKES",
                textAlign = TextAlign.Center,
                modifier = Modifier.rotate(-15f).alpha(0.03f),
                style = MaterialTheme.typography.displayLarge.copy(
                    fontSize = 120.sp,
                    color = Color.White,
                    fontWeight = FontWeight.Black,
                    lineHeight = 100.sp
                )
            )
        }

        Column(
            modifier = Modifier
                .fillMaxSize()
                .statusBarsPadding()
                .navigationBarsPadding()
                .padding(24.dp),
            horizontalAlignment = Alignment.CenterHorizontally
        ) {
            // Immersive Header
            Row(
                modifier = Modifier.fillMaxWidth(),
                horizontalArrangement = Arrangement.SpaceBetween,
                verticalAlignment = Alignment.CenterVertically
            ) {
                TextButton(onClick = onNavigateBack) {
                    Text("← EXIT", color = GoldPrimary, style = MaterialTheme.typography.labelMedium)
                }
                
                Surface(
                    color = GoldPrimary.copy(alpha = 0.1f),
                    shape = RoundedCornerShape(20.dp),
                    border = BorderStroke(1.dp, GoldPrimary.copy(alpha = 0.3f))
                ) {
                    Text(
                        "DEALER STANDS ON 17",
                        modifier = Modifier.padding(horizontal = 16.dp, vertical = 4.dp),
                        style = MaterialTheme.typography.labelSmall.copy(color = GoldPrimary, letterSpacing = 2.sp)
                    )
                }
                
                Box(modifier = Modifier.size(40.dp)) // Placeholder for balance spacer
            }
            
            Spacer(modifier = Modifier.weight(1f))

            // Dealer Area
            Column(horizontalAlignment = Alignment.CenterHorizontally) {
                BJHandView(hand = dealerHand, isDealer = true, isHidden = !gameOver && isPlaying)
                Spacer(modifier = Modifier.height(12.dp))
                if (dealerHand.isNotEmpty()) {
                    ScoreBadge(
                        score = if (!gameOver && isPlaying) "?" else calculateHand(dealerHand).toString(),
                        isDealer = true
                    )
                }
            }

            Spacer(modifier = Modifier.weight(1.5f))

            // Center felt banner
            Box(
                modifier = Modifier
                    .width(280.dp)
                    .height(1.dp)
                    .background(
                        Brush.horizontalGradient(
                            listOf(Color.Transparent, GoldPrimary.copy(alpha = 0.3f), Color.Transparent)
                        )
                    )
            )
            
            Spacer(modifier = Modifier.height(16.dp))
            
            Text(
                message.uppercase(),
                style = MaterialTheme.typography.headlineMedium.copy(
                    color = GoldPrimary,
                    fontWeight = FontWeight.ExtraBold,
                    textAlign = TextAlign.Center,
                    letterSpacing = 2.sp
                ),
                modifier = Modifier.height(48.dp)
            )
            
            Spacer(modifier = Modifier.height(16.dp))

            Box(
                modifier = Modifier
                    .width(280.dp)
                    .height(1.dp)
                    .background(
                        Brush.horizontalGradient(
                            listOf(Color.Transparent, GoldPrimary.copy(alpha = 0.3f), Color.Transparent)
                        )
                    )
            )

            Spacer(modifier = Modifier.weight(1.5f))

            // Player Area
            Column(horizontalAlignment = Alignment.CenterHorizontally) {
                if (userHand.isNotEmpty()) {
                    ScoreBadge(score = calculateHand(userHand).toString(), isDealer = false)
                }
                Spacer(modifier = Modifier.height(12.dp))
                BJHandView(hand = userHand)
            }

            Spacer(modifier = Modifier.weight(1f))

            // Controls
            Box(
                modifier = Modifier
                    .fillMaxWidth()
                    .height(120.dp),
                contentAlignment = Alignment.BottomCenter
            ) {
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
}

@Composable
fun ScoreBadge(score: String, isDealer: Boolean) {
    Surface(
        color = Color.Black.copy(alpha = 0.6f),
        shape = RoundedCornerShape(4.dp),
        border = BorderStroke(1.dp, if (isDealer) Color.White.copy(alpha = 0.2f) else GoldPrimary.copy(alpha = 0.4f))
    ) {
        Text(
            score,
            modifier = Modifier.padding(horizontal = 12.dp, vertical = 2.dp),
            style = MaterialTheme.typography.titleMedium.copy(
                color = if (isDealer) Color.White else GoldPrimary,
                fontWeight = FontWeight.Bold
            )
        )
    }
}

@Composable
fun BJHandView(hand: List<PlayingCard>, isDealer: Boolean = false, isHidden: Boolean = false) {
    Row(
        modifier = Modifier
            .fillMaxWidth()
            .height(130.dp),
        horizontalArrangement = Arrangement.Center,
        verticalAlignment = Alignment.CenterVertically
    ) {
        hand.forEachIndexed { index, card ->
            val rotation = when(index) {
                0 -> -3f
                1 -> 2f
                2 -> -1f
                3 -> 4f
                else -> 0f
            }
            key(card.id) {
                BJCardView(
                    card = card,
                    isHidden = isDealer && isHidden && index == 0,
                    rotation = rotation
                )
            }
        }
    }
}

@Composable
fun BJCardView(card: PlayingCard, isHidden: Boolean, rotation: Float) {
    val slideAnim = remember { Animatable(initialValue = -1f) }
    LaunchedEffect(Unit) {
        slideAnim.animateTo(0f, animationSpec = tween(400, easing = EaseOutQuart))
    }

    Surface(
        modifier = Modifier
            .padding(horizontal = 4.dp)
            .offset(y = (slideAnim.value * 200).dp)
            .rotate(rotation)
            .size(width = 85.dp, height = 120.dp)
            .shadow(if (isHidden) 0.dp else 8.dp, RoundedCornerShape(6.dp)),
        color = if (isHidden) Color(0xFF2D2D2D) else Color.White,
        shape = RoundedCornerShape(6.dp),
        border = BorderStroke(if (isHidden) 1.dp else 0.dp, GoldPrimary.copy(alpha = 0.3f))
    ) {
        if (isHidden) {
            Box(contentAlignment = Alignment.Center) {
                Icon(
                    Icons.Default.Diamond, 
                    contentDescription = null, 
                    tint = GoldPrimary.copy(alpha = 0.2f), 
                    modifier = Modifier.size(32.dp)
                )
                Text(
                    "G", 
                    color = GoldPrimary.copy(alpha = 0.1f), 
                    fontSize = 40.sp, 
                    fontWeight = FontWeight.Black
                )
            }
        } else {
            val color = if (card.suit.isRed) Color(0xFFFF4444) else Color(0xFF1A1A1A)
            Column(modifier = Modifier.padding(8.dp)) {
                Text(
                    card.rank.label, 
                    color = color, 
                    fontWeight = FontWeight.Black, 
                    fontSize = 20.sp,
                    lineHeight = 20.sp
                )
                Text(card.suit.symbol, color = color, fontSize = 14.sp)
                
                Spacer(modifier = Modifier.weight(1f))
                Box(modifier = Modifier.fillMaxWidth(), contentAlignment = Alignment.Center) {
                    Text(
                        card.suit.symbol, 
                        color = color.copy(alpha = 0.05f), 
                        fontSize = 48.sp
                    )
                }
                Spacer(modifier = Modifier.weight(1f))
                
                Column(modifier = Modifier.rotate(180f).align(Alignment.End)) {
                    Text(
                        card.rank.label, 
                        color = color, 
                        fontWeight = FontWeight.Black, 
                        fontSize = 20.sp,
                        lineHeight = 20.sp
                    )
                    Text(card.suit.symbol, color = color, fontSize = 14.sp)
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
        Surface(
            color = Color.Black.copy(alpha = 0.7f),
            shape = RoundedCornerShape(32.dp),
            border = BorderStroke(1.dp, GoldPrimary.copy(alpha = 0.3f))
        ) {
            Row(
                modifier = Modifier.padding(horizontal = 8.dp),
                verticalAlignment = Alignment.CenterVertically
            ) {
                IconButton(onClick = { if (betAmount > 10) onBetChange(betAmount - 10) }, enabled = !disabled) {
                    Icon(Icons.Default.Remove, contentDescription = null, tint = GoldPrimary)
                }
                Text(
                    "$${betAmount}",
                    modifier = Modifier.width(100.dp),
                    textAlign = TextAlign.Center,
                    style = MaterialTheme.typography.displaySmall.copy(color = Color.White, fontSize = 32.sp)
                )
                IconButton(onClick = { if (betAmount + 10 <= balance) onBetChange(betAmount + 10) }, enabled = !disabled) {
                    Icon(Icons.Default.Add, contentDescription = null, tint = GoldPrimary)
                }
            }
        }
        Spacer(modifier = Modifier.height(16.dp))
        GrandStakesButton(
            text = "DEAL CARDS",
            onClick = onDeal,
            enabled = !disabled && balance >= betAmount,
            modifier = Modifier.width(260.dp)
        )
    }
}

@Composable
fun ActionControls(onHit: () -> Unit, onStand: () -> Unit, disabled: Boolean) {
    Row(
        modifier = Modifier.fillMaxWidth().padding(horizontal = 16.dp),
        horizontalArrangement = Arrangement.spacedBy(12.dp)
    ) {
        ObsidianActionButton("STAND", modifier = Modifier.weight(1f), onClick = onStand, disabled = disabled, isPrimary = false)
        ObsidianActionButton("HIT", modifier = Modifier.weight(1f), onClick = onHit, disabled = disabled, isPrimary = true)
    }
}

@Composable
fun ObsidianActionButton(label: String, modifier: Modifier = Modifier, onClick: () -> Unit, disabled: Boolean, isPrimary: Boolean) {
    Surface(
        modifier = modifier
            .height(60.dp)
            .clickable(enabled = !disabled, onClick = onClick),
        color = if (isPrimary) GoldPrimary else Color.Black.copy(alpha = 0.6f),
        shape = RoundedCornerShape(4.dp),
        border = BorderStroke(1.dp, GoldPrimary),
        tonalElevation = 8.dp
    ) {
        Box(contentAlignment = Alignment.Center) {
            Text(
                label, 
                color = if (isPrimary) Color.Black else GoldPrimary, 
                fontWeight = FontWeight.ExtraBold,
                letterSpacing = 2.sp
            )
        }
    }
}
