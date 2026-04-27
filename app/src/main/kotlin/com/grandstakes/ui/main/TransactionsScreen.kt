package com.grandstakes.ui.main

import androidx.compose.foundation.background
import androidx.compose.foundation.clickable
import androidx.compose.foundation.border
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.lazy.LazyColumn
import androidx.compose.foundation.lazy.items
import androidx.compose.foundation.shape.CircleShape
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.*
import androidx.compose.material3.*
import androidx.compose.runtime.*
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.graphics.vector.ImageVector
import androidx.compose.ui.text.font.FontStyle
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import androidx.hilt.navigation.compose.hiltViewModel
import com.grandstakes.data.model.Transaction
import com.grandstakes.ui.components.GrandStakesButton
import com.grandstakes.ui.theme.GoldPrimary
import com.grandstakes.ui.theme.OnSurfaceVariant
import com.grandstakes.ui.theme.PinkSecondary
import java.text.SimpleDateFormat
import java.util.*

@Composable
fun TransactionsScreen(
    onNavigateBack: () -> Unit,
    viewModel: LobbyViewModel = hiltViewModel()
) {
    val txs by viewModel.transactions.collectAsState(initial = emptyList())
    val user by viewModel.currentUser.collectAsState()
    
    var showDepositDialog by remember { mutableStateOf(false) }
    var showWithdrawDialog by remember { mutableStateOf(false) }

    if (showDepositDialog) {
        MoneyDialog(
            title = "Deposit Funds",
            onDismiss = { showDepositDialog = false },
            onConfirm = { amount ->
                viewModel.updateBalance(amount, "Deposit")
                showDepositDialog = false
            }
        )
    }

    if (showWithdrawDialog) {
        MoneyDialog(
            title = "Withdraw Funds",
            onDismiss = { showWithdrawDialog = false },
            onConfirm = { amount ->
                if ((user?.balance ?: 0) >= amount) {
                    viewModel.updateBalance(-amount, "Withdrawal")
                    showWithdrawDialog = false
                }
            }
        )
    }

    LazyColumn(
        modifier = Modifier
            .fillMaxSize()
            .background(Color.Black)
            .padding(horizontal = 24.dp)
    ) {
        item { Spacer(Modifier.height(48.dp)) }
        
        // Header
        item {
            Column {
                Text(
                    "THE LEDGER", 
                    style = MaterialTheme.typography.labelSmall.copy(
                        color = GoldPrimary, 
                        fontWeight = FontWeight.Bold, 
                        letterSpacing = 4.sp
                    )
                )
                Text(
                    "Transaction\nHistory", 
                    style = MaterialTheme.typography.displayLarge.copy(
                        color = Color.White, 
                        fontSize = 52.sp, 
                        lineHeight = 56.sp
                    )
                )
            }
        }
        
        item { Spacer(Modifier.height(32.dp)) }
        
        // Actions
        item {
            Row(modifier = Modifier.fillMaxWidth()) {
                GrandStakesButton(
                    text = "DEPOSIT",
                    onClick = { showDepositDialog = true },
                    modifier = Modifier.weight(1f)
                )
                Spacer(Modifier.width(16.dp))
                GrandStakesButton(
                    text = "WITHDRAW",
                    onClick = { showWithdrawDialog = true },
                    modifier = Modifier.weight(1f),
                    containerColor = Color.Transparent,
                    contentColor = Color.White
                )
            }
        }
        
        item { Spacer(Modifier.height(48.dp)) }
        
        // Filters
        item {
            Row(modifier = Modifier.fillMaxWidth()) {
                FilterCard("SCOPE", "All Records", true, Modifier.weight(1f))
                Spacer(Modifier.width(16.dp))
                FilterCard("PERIOD", "Last 30 Days", false, Modifier.weight(1f))
            }
        }
        
        item { Spacer(Modifier.height(48.dp)) }
        
        // List
        if (txs.isEmpty()) {
            item {
                Box(Modifier.fillMaxWidth().padding(vertical = 40.dp), contentAlignment = Alignment.Center) {
                    Text("No transactions recorded yet.", color = OnSurfaceVariant)
                }
            }
        } else {
            items(txs) { tx ->
                TransactionCard(tx)
                Spacer(Modifier.height(1.dp)) // Thin separator
            }
        }
        
        item { Spacer(Modifier.height(32.dp)) }
        
        item {
            Box(
                modifier = Modifier
                    .fillMaxWidth()
                    .clickable { /* Load more */ }
                    .padding(vertical = 24.dp),
                contentAlignment = Alignment.Center
            ) {
                Text(
                    "LOAD PREVIOUS RECORDS", 
                    style = MaterialTheme.typography.labelSmall.copy(
                        color = GoldPrimary, 
                        fontWeight = FontWeight.ExtraBold, 
                        letterSpacing = 2.sp
                    )
                )
            }
        }
        
        item { Spacer(Modifier.height(96.dp)) } // Padding for bottom nav
    }
}

@Composable
fun FilterCard(label: String, value: String, isSelected: Boolean, modifier: Modifier) {
    Surface(
        modifier = modifier,
        color = MaterialTheme.colorScheme.surfaceContainerLowest,
        shape = RoundedCornerShape(4.dp)
    ) {
        Column(
            modifier = Modifier
                .padding(16.dp)
                .fillMaxWidth()
        ) {
            Text(label, style = MaterialTheme.typography.labelSmall.copy(color = GoldPrimary, fontSize = 8.sp, fontWeight = FontWeight.Bold, letterSpacing = 1.5.sp))
            Spacer(Modifier.height(8.dp))
            Text(value, style = MaterialTheme.typography.titleSmall.copy(color = Color.White, fontWeight = FontWeight.Bold))
            if (isSelected) {
                Spacer(Modifier.height(8.dp))
                Box(Modifier.fillMaxWidth().height(2.dp).background(GoldPrimary))
            }
        }
    }
}

@Composable
fun TransactionCard(tx: Transaction) {
    val isPositive = tx.amount > 0
    val sdf = SimpleDateFormat("MMM d, yyyy · hh:mm a", Locale.getDefault())
    val dateStr = sdf.format(Date(tx.timestamp))
    
    val icon = when {
        tx.game.contains("Deposit", true) -> Icons.Default.AccountBalanceWallet
        tx.game.contains("Withdrawal", true) -> Icons.Default.AccountBalance
        else -> Icons.Default.Casino
    }
    
    Surface(
        modifier = Modifier.fillMaxWidth(),
        color = Color.Transparent
    ) {
        Row(
            modifier = Modifier.padding(vertical = 20.dp),
            verticalAlignment = Alignment.CenterVertically
        ) {
            Icon(
                icon, 
                contentDescription = null, 
                tint = if (isPositive) GoldPrimary else OnSurfaceVariant, 
                modifier = Modifier.size(24.dp)
            )
            Spacer(Modifier.width(20.dp))
            Column(Modifier.weight(1f)) {
                Text(
                    tx.game.uppercase(), 
                    style = MaterialTheme.typography.titleSmall.copy(color = Color.White, fontWeight = FontWeight.Bold, letterSpacing = 1.sp)
                )
                Text(
                    dateStr, 
                    style = MaterialTheme.typography.labelSmall.copy(color = OnSurfaceVariant, fontSize = 10.sp)
                )
            }
            Column(horizontalAlignment = Alignment.End) {
                Text(
                    if (isPositive) "+$${String.format("%,d", tx.amount)}" else "-$${String.format("%,d", kotlin.math.abs(tx.amount))}",
                    style = MaterialTheme.typography.titleMedium.copy(
                        color = if (isPositive) GoldPrimary else Color.White,
                        fontWeight = FontWeight.ExtraBold
                    )
                )
                Text(
                    "PROCESSED", 
                    style = MaterialTheme.typography.labelSmall.copy(color = OnSurfaceVariant, fontSize = 8.sp, letterSpacing = 1.sp)
                )
            }
        }
    }
}

@Composable
fun MoneyDialog(title: String, onDismiss: () -> Unit, onConfirm: (Int) -> Unit) {
    var amountText by remember { mutableStateOf("") }
    AlertDialog(
        onDismissRequest = onDismiss,
        title = { Text(title, color = GoldPrimary) },
        text = {
            TextField(
                value = amountText,
                onValueChange = { amountText = it },
                label = { Text("Amount") },
                prefix = { Text("$ ", color = GoldPrimary) },
                colors = TextFieldDefaults.colors(
                    focusedContainerColor = Color.Transparent,
                    unfocusedContainerColor = Color.Transparent,
                    focusedTextColor = Color.White,
                    unfocusedTextColor = Color.White
                )
            )
        },
        confirmButton = {
            TextButton(onClick = { amountText.toIntOrNull()?.let { onConfirm(it) } }) {
                Text("CONFIRM", color = GoldPrimary)
            }
        },
        dismissButton = {
            TextButton(onClick = onDismiss) {
                Text("CANCEL", color = MaterialTheme.colorScheme.onSurfaceVariant)
            }
        },
        containerColor = MaterialTheme.colorScheme.surfaceContainerHigh
    )
}
