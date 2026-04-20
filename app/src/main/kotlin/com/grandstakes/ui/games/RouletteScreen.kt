package com.grandstakes.ui.games

import androidx.compose.animation.core.*
import androidx.compose.foundation.Canvas
import androidx.compose.foundation.background
import androidx.compose.foundation.layout.*
import androidx.compose.material3.*
import androidx.compose.runtime.*
import androidx.compose.ui.Alignment
import androidx.compose.material3.ExperimentalMaterial3Api
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.automirrored.filled.ArrowBack
import androidx.compose.ui.Modifier
import androidx.compose.ui.geometry.Offset
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.graphics.drawscope.rotate
import androidx.compose.ui.unit.dp
import androidx.hilt.navigation.compose.hiltViewModel
import com.grandstakes.ui.main.LobbyViewModel
import com.grandstakes.ui.theme.GoldPrimary
import kotlinx.coroutines.launch
import kotlin.math.PI
import kotlin.math.cos
import kotlin.math.sin
import kotlin.random.Random

@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun RouletteScreen(
    onNavigateBack: () -> Unit,
    viewModel: LobbyViewModel = hiltViewModel()
) {
    val user by viewModel.currentUser.collectAsState()
    val scope = rememberCoroutineScope()
    
    var rotationAngle by remember { mutableFloatStateOf(0f) }
    var spinning by remember { mutableStateOf(false) }
    
    val numbers = listOf(0, 32, 15, 19, 4, 21, 2, 25, 17, 34, 6, 27, 13, 36, 11, 30, 8, 23, 10, 5, 24, 16, 33, 1, 20, 14, 31, 9, 22, 18, 29, 7, 28, 12, 35, 3, 26)

    fun spin() {
        if (spinning) return
        spinning = true
        scope.launch {
            val targetRotation = rotationAngle + 3600f + Random.nextInt(360).toFloat()
            animate(
                initialValue = rotationAngle,
                targetValue = targetRotation,
                animationSpec = tween(durationMillis = 5000, easing = CubicBezierEasing(0.1f, 0.0f, 0.2f, 1.0f))
            ) { value, _ ->
                rotationAngle = value
            }
            spinning = false
            // Calculate winning number check logic here...
            viewModel.updateBalance(0, "Roulette Spin") // Placeholder
        }
    }

    Scaffold(
        containerColor = Color.Black,
        topBar = {
             CenterAlignedTopAppBar(
                title = { Text("ROULETTE", style = MaterialTheme.typography.headlineMedium.copy(color = GoldPrimary)) },
                navigationIcon = { IconButton(onClick = onNavigateBack) { Icon(Icons.AutoMirrored.Filled.ArrowBack, contentDescription = null, tint = GoldPrimary) } }
            )
        }
    ) { padding ->
        Column(
            modifier = Modifier
                .fillMaxSize()
                .padding(padding),
            horizontalAlignment = Alignment.CenterHorizontally
        ) {
            Spacer(modifier = Modifier.height(48.dp))
            
            Box(modifier = Modifier.size(320.dp), contentAlignment = Alignment.Center) {
                RouletteWheel(rotationAngle, numbers)
                // Static pointer
                Box(Modifier.size(10.dp).background(Color.White).align(Alignment.TopCenter))
            }
            
            Spacer(modifier = Modifier.height(64.dp))
            
            Button(
                onClick = ::spin,
                enabled = !spinning,
                colors = ButtonDefaults.buttonColors(containerColor = GoldPrimary)
            ) {
                Text(if (spinning) "SPINNING..." else "SPIN WHEEL", color = Color.Black)
            }
        }
    }
}

@Composable
fun RouletteWheel(angle: Float, numbers: List<Int>) {
    Canvas(modifier = Modifier.fillMaxSize()) {
        val center = Offset(size.width / 2, size.height / 2)
        val radius = size.width / 2
        val sweepAngle = 360f / numbers.size

        rotate(angle, pivot = center) {
            numbers.forEachIndexed { index, number ->
                val startAngle = index * sweepAngle
                val color = when {
                    number == 0 -> Color(0xFF008000)
                    listOf(32, 19, 21, 25, 34, 27, 36, 30, 23, 5, 16, 1, 14, 9, 18, 7, 12, 3).contains(number) -> Color.Red
                    else -> Color.Black
                }
                
                drawArc(
                    color = color,
                    startAngle = startAngle,
                    sweepAngle = sweepAngle,
                    useCenter = true,
                    size = size
                )
            }
        }
        
        // Draw outer ring
        drawCircle(color = GoldPrimary, radius = radius, center = center, style = androidx.compose.ui.graphics.drawscope.Stroke(width = 4.dp.toPx()))
    }
}
