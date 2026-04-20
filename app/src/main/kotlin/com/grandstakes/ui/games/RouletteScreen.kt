package com.grandstakes.ui.games

import androidx.compose.material.icons.automirrored.filled.ArrowForward

import androidx.compose.animation.*
import androidx.compose.animation.core.*
import kotlinx.coroutines.coroutineScope
import androidx.compose.foundation.*
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.shape.CircleShape
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.History
import androidx.compose.material.icons.filled.Undo
import androidx.compose.material3.*
import androidx.compose.runtime.*
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.geometry.Offset
import androidx.compose.ui.geometry.Rect
import androidx.compose.ui.graphics.Brush
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.graphics.drawscope.rotate
import androidx.compose.ui.graphics.drawscope.Stroke
import androidx.compose.ui.platform.LocalDensity
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.text.style.TextAlign
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import androidx.compose.ui.text.TextStyle
import androidx.hilt.navigation.compose.hiltViewModel
import com.grandstakes.ui.main.LobbyViewModel
import com.grandstakes.ui.components.GrandStakesButton
import com.grandstakes.ui.theme.GoldPrimary
import kotlinx.coroutines.launch
import kotlin.math.*
import kotlin.random.Random

// European Roulette Sequence
private val ROULETTE_SEQUENCE = listOf(
    0, 32, 15, 19, 4, 21, 2, 25, 17, 34, 6, 27, 13, 36, 11, 30, 8, 23, 10, 5,
    24, 16, 33, 1, 20, 14, 31, 9, 22, 18, 29, 7, 28, 12, 35, 3, 26
)

private val RED_NUMBERS = setOf(1, 3, 5, 7, 9, 12, 14, 16, 18, 19, 21, 23, 25, 27, 30, 32, 34, 36)

@Composable
fun RouletteScreen(
    onNavigateBack: () -> Unit,
    viewModel: LobbyViewModel = hiltViewModel()
) {
    val user by viewModel.currentUser.collectAsState()
    val balance = user?.balance ?: 0
    val scope = rememberCoroutineScope()
    
    // State
    var selectedChip by remember { mutableIntStateOf(10) }
    val placedBets = remember { mutableStateMapOf<String, Int>() }
    var isSpinning by remember { mutableStateOf(false) }
    var winningNumber by remember { mutableStateOf<Int?>(null) }
    val history = remember { mutableStateListOf<Int>() }
    
    // Animations
    var wheelAngle by remember { mutableFloatStateOf(0f) }
    var ballAngle by remember { mutableFloatStateOf(0f) }
    var ballRadiusFactor by remember { mutableFloatStateOf(1f) } // 1: rim, 0: slot

    fun placeBet(zone: String) {
        if (isSpinning) return
        if (balance < selectedChip) return
        
        placedBets[zone] = (placedBets[zone] ?: 0) + selectedChip
        viewModel.updateBalance(-selectedChip, "Roulette Bet")
        winningNumber = null
    }

    suspend fun spin() {
        if (isSpinning || placedBets.isEmpty()) return
        
        isSpinning = true
        winningNumber = null
        
        val targetNumber = Random.nextInt(37)
        val winIndex = ROULETTE_SEQUENCE.indexOf(targetNumber)
        val segmentAngle = 360f / 37f
        val targetRelativeAngle = winIndex * segmentAngle
        
        val wheelSpins = 4f
        val ballSpins = -5f
        
        val endWheelAngle = wheelAngle + (wheelSpins * 360f) + Random.nextFloat() * 360f
        
        val normalizedTarget = (endWheelAngle + targetRelativeAngle) % 360f
        val currentBallMod = ballAngle % 360f
        var diff = normalizedTarget - currentBallMod
        if (diff > 0) diff -= 360f
        
        val endBallAngle = ballAngle + diff + (ballSpins * 360f)
        
        // Parallel animations
        coroutineScope {
            launch {
                animate(
                    initialValue = wheelAngle,
                    targetValue = endWheelAngle,
                    animationSpec = tween(4000, easing = EaseOutCubic)
                ) { value, _ -> wheelAngle = value }
            }

            launch {
                animate(
                    initialValue = ballAngle,
                    targetValue = endBallAngle,
                    animationSpec = tween(4000, easing = EaseOutCubic)
                ) { value, _ -> ballAngle = value }
            }

            launch {
                // Ball drops from rim to slot
                animate(
                    initialValue = 1f,
                    targetValue = 0f,
                    animationSpec = keyframes {
                        durationMillis = 4000
                        1f at 1200 with LinearEasing
                        0f at 4000 with EaseIn
                    }
                ) { value, _ -> ballRadiusFactor = value }
            }
        }
        
        // Calculate wins
        var totalWin = 0
        placedBets.forEach { (zone, amount) ->
            when {
                zone == targetNumber.toString() -> totalWin += amount * 36
                zone == "RED" && targetNumber != 0 && RED_NUMBERS.contains(targetNumber) -> totalWin += amount * 2
                zone == "BLACK" && targetNumber != 0 && !RED_NUMBERS.contains(targetNumber) -> totalWin += amount * 2
                zone == "EVEN" && targetNumber != 0 && targetNumber % 2 == 0 -> totalWin += amount * 2
                zone == "ODD" && targetNumber != 0 && targetNumber % 2 != 0 -> totalWin += amount * 2
                zone == "1 TO 18" && targetNumber in 1..18 -> totalWin += amount * 2
                zone == "19 TO 36" && targetNumber in 19..36 -> totalWin += amount * 2
                zone == "1ST 12" && targetNumber in 1..12 -> totalWin += amount * 3
                zone == "2ND 12" && targetNumber in 13..24 -> totalWin += amount * 3
                zone == "3RD 12" && targetNumber in 25..36 -> totalWin += amount * 3
            }
        }
        
        if (totalWin > 0) {
            viewModel.updateBalance(totalWin, "Roulette Win")
        }
        
        winningNumber = targetNumber
        history.add(0, targetNumber)
        if (history.size > 10) history.removeLast()
        placedBets.clear()
        isSpinning = false
    }

    Column(
        modifier = Modifier
            .fillMaxSize()
            .background(Color(0xFF0A0A0A))
    ) {
        // Upper: Wheel
        Box(
            modifier = Modifier
                .fillMaxWidth()
                .weight(1.2f),
            contentAlignment = Alignment.Center
        ) {
            RouletteWheelView(
                wheelAngle = wheelAngle,
                ballAngle = ballAngle,
                ballRadiusFactor = ballRadiusFactor
            )
            
            if (winningNumber != null && !isSpinning) {
                Surface(
                    modifier = Modifier
                        .size(80.dp)
                        .border(1.dp, GoldPrimary, CircleShape),
                    color = Color.Black,
                    shape = CircleShape
                ) {
                    Box(contentAlignment = Alignment.Center) {
                        Text(
                            winningNumber.toString(),
                            style = MaterialTheme.typography.displayLarge.copy(
                                color = if (winningNumber == 0) Color(0xFF00C853) else if (RED_NUMBERS.contains(winningNumber!!)) Color(0xFFFF5252) else Color.White,
                                fontSize = 40.sp
                            )
                        )
                    }
                }
            }
        }
        
        // Middle: Grid & History
        Column(
            modifier = Modifier
                .fillMaxWidth()
                .weight(1f)
                .background(Color.Black)
        ) {
            HistoryRow(history)
            Box(
                modifier = Modifier
                    .fillMaxWidth()
                    .weight(1f)
                    .horizontalScroll(rememberScrollState())
            ) {
                RouletteBettingGrid(placedBets = placedBets, onPlaceBet = ::placeBet)
            }
        }
        
        // Lower: Controls
        Surface(
            modifier = Modifier.fillMaxWidth(),
            color = Color(0xFF121212)
        ) {
            Column(
                modifier = Modifier.padding(20.dp),
                horizontalAlignment = Alignment.CenterHorizontally
            ) {
                Row(
                    modifier = Modifier.fillMaxWidth(),
                    horizontalArrangement = Arrangement.SpaceBetween,
                    verticalAlignment = Alignment.CenterVertically
                ) {
                    Text(
                        "BET: $${placedBets.values.sum()}", 
                        style = MaterialTheme.typography.labelSmall.copy(color = GoldPrimary, letterSpacing = 2.sp)
                    )
                    ChipSelection(selectedChip = selectedChip, onSelect = { selectedChip = it })
                }
                Spacer(Modifier.height(20.dp))
                Row(modifier = Modifier.fillMaxWidth()) {
                    OutlinedButton(
                        onClick = { placedBets.clear() },
                        modifier = Modifier.weight(1f).height(54.dp),
                        border = BorderStroke(1.dp, GoldPrimary.copy(alpha = 0.3f)),
                        shape = RoundedCornerShape(0.dp),
                        colors = ButtonDefaults.outlinedButtonColors(contentColor = Color.White)
                    ) {
                        Text("CLEAR", style = MaterialTheme.typography.labelSmall.copy(letterSpacing = 2.sp))
                    }
                    Spacer(Modifier.width(16.dp))
                    GrandStakesButton(
                        text = "SPIN WHEEL",
                        onClick = { scope.launch { spin() } },
                        modifier = Modifier.weight(1.5f),
                        enabled = !isSpinning && placedBets.isNotEmpty()
                    )
                }
            }
        }
    }
}

@Composable
fun RouletteWheelView(wheelAngle: Float, ballAngle: Float, ballRadiusFactor: Float) {
    Canvas(modifier = Modifier.size(320.dp)) {
        val center = Offset(size.width / 2, size.height / 2)
        val radius = size.width / 2
        
        // Polished Obsidian Frame
        drawCircle(
            brush = Brush.radialGradient(
                colors = listOf(Color(0xFF1A1A1A), Color(0xFF0A0A0A)),
                center = center,
                radius = radius
            ),
            radius = radius,
            center = center
        )
        // Gold Outer Ring
        drawCircle(GoldPrimary.copy(alpha = 0.4f), radius = radius * 0.94f, center = center, style = Stroke(width = 2.dp.toPx()))
        // Inner Ring
        drawCircle(Color(0xFF121212), radius = radius * 0.88f, center = center)
        
        rotate(wheelAngle, pivot = center) {
            val segmentSweep = 360f / 37f
            ROULETTE_SEQUENCE.forEachIndexed { i, num ->
                val start = i * segmentSweep - segmentSweep / 2
                val color = when {
                    num == 0 -> Color(0xFF00C853) // Luxury Green
                    RED_NUMBERS.contains(num) -> Color(0xFFFF5252) // Luxury Red
                    else -> Color(0xFF121212) // Deep Black
                }
                drawArc(
                    color = color,
                    startAngle = start,
                    sweepAngle = segmentSweep,
                    useCenter = true,
                    size = size * 0.88f,
                    topLeft = Offset(size.width * 0.06f, size.height * 0.06f)
                )
                // Gold separators between pockets
                drawArc(
                    color = GoldPrimary.copy(alpha = 0.2f),
                    startAngle = start,
                    sweepAngle = 0.5f,
                    useCenter = true,
                    size = size * 0.88f,
                    topLeft = Offset(size.width * 0.06f, size.height * 0.06f)
                )
            }
        }
        
        // Center piece (The Hub)
        drawCircle(Color(0xFF1A1A1A), radius = radius * 0.55f, center = center)
        drawCircle(GoldPrimary.copy(alpha = 0.3f), radius = radius * 0.53f, center = center, style = Stroke(width = 1.dp.toPx()))
        drawCircle(Color(0xFF0A0A0A), radius = radius * 0.45f, center = center)
        
        // Spindle (Gold)
        drawCircle(
            brush = Brush.radialGradient(
                colors = listOf(GoldPrimary, Color(0xFFAA8A25)),
                center = center,
                radius = radius * 0.15f
            ),
            radius = radius * 0.15f,
            center = center
        )
        
        // Draw Ball
        val outerDist = radius * 0.93f
        val innerDist = radius * 0.82f
        val ballDist = innerDist + (outerDist - innerDist) * ballRadiusFactor
        
        val ballX = center.x + ballDist * cos(Math.toRadians(ballAngle.toDouble())).toFloat()
        val ballY = center.y + ballDist * sin(Math.toRadians(ballAngle.toDouble())).toFloat()
        
        drawCircle(Color.White, radius = 5.dp.toPx(), center = Offset(ballX, ballY))
        drawCircle(Color.White.copy(alpha = 0.3f), radius = 7.dp.toPx(), center = Offset(ballX, ballY), style = Stroke(width = 1.dp.toPx()))
    }
}

@Composable
fun RouletteBettingGrid(placedBets: Map<String, Int>, onPlaceBet: (String) -> Unit) {
    Row(modifier = Modifier.height(200.dp)) {
        // 0
        BetZone("0", Color(0xFF008000), width = 60.dp, height = 150.dp, betAmount = placedBets["0"] ?: 0, onClick = { onPlaceBet("0") })
        
        Column {
            Row {
                for (i in 0 until 12) {
                    val num = 3 + (i * 3)
                    BetZone(num.toString(), if (RED_NUMBERS.contains(num)) Color(0xFFD32F2F) else Color.Black, betAmount = placedBets[num.toString()] ?: 0, onClick = { onPlaceBet(num.toString()) })
                }
            }
            Row {
                for (i in 0 until 12) {
                    val num = 2 + (i * 3)
                    BetZone(num.toString(), if (RED_NUMBERS.contains(num)) Color(0xFFD32F2F) else Color.Black, betAmount = placedBets[num.toString()] ?: 0, onClick = { onPlaceBet(num.toString()) })
                }
            }
            Row {
                for (i in 0 until 12) {
                    val num = 1 + (i * 3)
                    BetZone(num.toString(), if (RED_NUMBERS.contains(num)) Color(0xFFD32F2F) else Color.Black, betAmount = placedBets[num.toString()] ?: 0, onClick = { onPlaceBet(num.toString()) })
                }
            }
            // Dozens
            Row {
                BetZone("1ST 12", Color.Transparent, width = 200.dp, height = 40.dp, isLabel = true, betAmount = placedBets["1ST 12"] ?: 0, onClick = { onPlaceBet("1ST 12") })
                BetZone("2ND 12", Color.Transparent, width = 200.dp, height = 40.dp, isLabel = true, betAmount = placedBets["2ND 12"] ?: 0, onClick = { onPlaceBet("2ND 12") })
                BetZone("3RD 12", Color.Transparent, width = 200.dp, height = 40.dp, isLabel = true, betAmount = placedBets["3RD 12"] ?: 0, onClick = { onPlaceBet("3RD 12") })
            }
            // Outside
            Row {
                BetZone("1 TO 18", Color.Transparent, width = 100.dp, height = 40.dp, isLabel = true, betAmount = placedBets["1 TO 18"] ?: 0, onClick = { onPlaceBet("1 TO 18") })
                BetZone("EVEN", Color.Transparent, width = 100.dp, height = 40.dp, isLabel = true, betAmount = placedBets["EVEN"] ?: 0, onClick = { onPlaceBet("EVEN") })
                BetZone("RED", Color(0xFFD32F2F), width = 100.dp, height = 40.dp, isLabel = true, betAmount = placedBets["RED"] ?: 0, onClick = { onPlaceBet("RED") })
                BetZone("BLACK", Color.Black, width = 100.dp, height = 40.dp, isLabel = true, betAmount = placedBets["BLACK"] ?: 0, onClick = { onPlaceBet("BLACK") })
                BetZone("ODD", Color.Transparent, width = 100.dp, height = 40.dp, isLabel = true, betAmount = placedBets["ODD"] ?: 0, onClick = { onPlaceBet("ODD") })
                BetZone("19 TO 36", Color.Transparent, width = 100.dp, height = 40.dp, isLabel = true, betAmount = placedBets["19 TO 36"] ?: 0, onClick = { onPlaceBet("19 TO 36") })
            }
        }
    }
}

@Composable
fun BetZone(
    label: String,
    color: Color,
    width: androidx.compose.ui.unit.Dp = 50.dp,
    height: androidx.compose.ui.unit.Dp = 50.dp,
    isLabel: Boolean = false,
    betAmount: Int = 0,
    onClick: () -> Unit
) {
    Box(
        modifier = Modifier
            .size(width, height)
            .background(if (color == Color.Transparent) Color(0xFF1A1A1A) else color)
            .border(0.5.dp, GoldPrimary.copy(alpha = 0.15f))
            .clickable(onClick = onClick),
        contentAlignment = Alignment.Center
    ) {
        Text(
            label,
            style = MaterialTheme.typography.labelSmall.copy(
                color = Color.White,
                fontWeight = FontWeight.Bold,
                fontSize = if (isLabel) 10.sp else 14.sp
            )
        )
        if (betAmount > 0) {
            Surface(
                modifier = Modifier.size(24.dp),
                color = GoldPrimary,
                shape = CircleShape,
                border = BorderStroke(1.dp, Color.Black)
            ) {
                Box(contentAlignment = Alignment.Center) {
                    Text(
                        if (betAmount >= 1000) "${betAmount / 1000}k" else betAmount.toString(),
                        style = TextStyle(color = Color.Black, fontSize = 8.sp, fontWeight = FontWeight.Bold)
                    )
                }
            }
        }
    }
}

@Composable
fun HistoryRow(history: List<Int>) {
    Row(
        verticalAlignment = Alignment.CenterVertically,
        modifier = Modifier.fillMaxWidth().padding(16.dp),
        horizontalArrangement = Arrangement.Start
    ) {
        Text("LAST NUMBERS: ", style = MaterialTheme.typography.labelSmall.copy(color = GoldPrimary, fontSize = 9.sp, letterSpacing = 2.sp))
        Spacer(Modifier.width(8.dp))
        history.forEach { num ->
            Box(
                modifier = Modifier
                    .padding(horizontal = 4.dp)
                    .size(24.dp)
                    .clip(CircleShape)
                    .background(if (num == 0) Color(0xFF00C853) else if (RED_NUMBERS.contains(num)) Color(0xFFFF5252) else Color(0xFF1E1E1E))
                    .border(1.dp, GoldPrimary.copy(alpha = 0.2f), CircleShape),
                contentAlignment = Alignment.Center
            ) {
                Text(num.toString(), color = Color.White, fontSize = 10.sp, fontWeight = FontWeight.Bold)
            }
        }
    }
}

@Composable
fun ChipSelection(selectedChip: Int, onSelect: (Int) -> Unit) {
    val chips = listOf(1, 5, 10, 25, 100)
    Row {
        chips.forEach { chip ->
            val isSelected = selectedChip == chip
            Box(
                modifier = Modifier
                    .padding(horizontal = 4.dp)
                    .size(if (isSelected) 44.dp else 36.dp)
                    .clip(CircleShape)
                    .background(
                        when (chip) {
                            1 -> Color.DarkGray
                            5 -> Color.Blue
                            10 -> GoldPrimary
                            25 -> Color(0xFF006400)
                            100 -> Color(0xFF4B0082)
                            else -> Color.Gray
                        }
                    )
                    .border(
                        if (isSelected) 2.dp else 1.dp,
                        if (isSelected) Color.White else Color.White.copy(alpha = 0.3f),
                        CircleShape
                    )
                    .clickable { onSelect(chip) },
                contentAlignment = Alignment.Center
            ) {
                Text(
                    chip.toString(),
                    color = if (isSelected && chip == 10) Color.Black else Color.White,
                    fontWeight = FontWeight.Bold,
                    fontSize = if (isSelected) 16.sp else 12.sp
                )
            }
        }
    }
}
