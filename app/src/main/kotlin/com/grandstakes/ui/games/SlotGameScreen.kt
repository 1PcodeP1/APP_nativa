package com.grandstakes.ui.games

import androidx.compose.animation.core.*
import androidx.compose.foundation.background
import androidx.compose.foundation.layout.*
import androidx.compose.material3.*
import androidx.compose.runtime.*
import androidx.compose.ui.Alignment
import androidx.compose.material3.ExperimentalMaterial3Api
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.Brush
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.text.font.FontStyle
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import androidx.hilt.navigation.compose.hiltViewModel
import com.grandstakes.ui.main.LobbyViewModel
import com.grandstakes.ui.theme.GoldPrimary
import kotlinx.coroutines.delay
import kotlinx.coroutines.launch
import kotlin.random.Random

data class SlotTheme(
    val title: String,
    val symbols: List<String>,
    val primaryColor: Color
)

@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun SlotGameScreen(
    slotTheme: SlotTheme,
    onNavigateBack: () -> Unit,
    viewModel: LobbyViewModel = hiltViewModel()
) {
    val user by viewModel.currentUser.collectAsState()
    val scope = rememberCoroutineScope()
    
    var reels by remember { mutableStateOf(listOf("?", "?", "?")) }
    var spinning by remember { mutableStateOf(false) }
    var message by remember { mutableStateOf("SPIN TO WIN") }

    fun spin() {
        if (spinning || (user?.balance ?: 0) < 100) return
        spinning = true
        message = "SPINNING..."
        viewModel.updateBalance(-100, "Slot Play: ${slotTheme.title}")

        scope.launch {
            repeat(10) {
                delay(100)
                reels = List(3) { slotTheme.symbols[Random.nextInt(slotTheme.symbols.size)] }
            }
            spinning = false
            checkWin(reels, slotTheme, viewModel) { msg -> message = msg }
        }
    }

    Scaffold(
        containerColor = Color.Black,
        topBar = {
            CenterAlignedTopAppBar(
                title = { Text(slotTheme.title.uppercase(), style = MaterialTheme.typography.titleLarge) },
                colors = TopAppBarDefaults.centerAlignedTopAppBarColors(containerColor = Color.Transparent, titleContentColor = slotTheme.primaryColor)
            )
        }
    ) { padding ->
        Column(
            modifier = Modifier.fillMaxSize().padding(padding),
            horizontalAlignment = Alignment.CenterHorizontally,
            verticalArrangement = Arrangement.Center
        ) {
            Text(message, style = MaterialTheme.typography.headlineMedium.copy(color = GoldPrimary))
            Spacer(modifier = Modifier.height(48.dp))
            
            Row(
                modifier = Modifier
                    .fillMaxWidth()
                    .padding(24.dp)
                    .background(Brush.verticalGradient(listOf(Color.DarkGray, Color.Black)))
                    .padding(24.dp),
                horizontalArrangement = Arrangement.SpaceEvenly
            ) {
                reels.forEach { symbol ->
                    Surface(
                        modifier = Modifier.size(80.dp),
                        color = Color.Black,
                        border = androidx.compose.foundation.BorderStroke(2.dp, slotTheme.primaryColor)
                    ) {
                        Box(contentAlignment = Alignment.Center) {
                            Text(symbol, fontSize = 48.sp)
                        }
                    }
                }
            }
            
            Spacer(modifier = Modifier.height(48.dp))
            
            Button(
                onClick = ::spin,
                enabled = !spinning,
                modifier = Modifier.size(width = 200.dp, height = 64.dp),
                colors = ButtonDefaults.buttonColors(containerColor = slotTheme.primaryColor)
            ) {
                Text("SPIN LOGIC", style = MaterialTheme.typography.titleMedium.copy(color = Color.Black))
            }
        }
    }
}

private fun checkWin(reels: List<String>, theme: SlotTheme, viewModel: LobbyViewModel, onResult: (String) -> Unit) {
    if (reels[0] == reels[1] && reels[1] == reels[2]) {
        viewModel.updateBalance(1000, "Slot Jackpot")
        onResult("JACKPOT! +$1000")
    } else if (reels[0] == reels[1] || reels[1] == reels[2] || reels[0] == reels[2]) {
        viewModel.updateBalance(200, "Slot Small Win")
        onResult("WINNER! +$200")
    } else {
        onResult("NOTHING.")
    }
}
