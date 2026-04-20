package com.grandstakes.ui.auth

import androidx.compose.foundation.layout.*
import androidx.compose.foundation.rememberScrollState
import androidx.compose.foundation.verticalScroll
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.outlined.AlternateEmail
import androidx.compose.material.icons.outlined.Lock
import androidx.compose.material3.*
import androidx.compose.runtime.*
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.text.font.FontStyle
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.text.style.TextAlign
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import androidx.hilt.navigation.compose.hiltViewModel
import com.grandstakes.ui.components.GrandStakesButton
import com.grandstakes.ui.components.GrandStakesTextField
import com.grandstakes.ui.theme.GoldPrimary

@Composable
fun LoginScreen(
    onNavigateToRegister: () -> Unit,
    onLoginSuccess: () -> Unit,
    viewModel: AuthViewModel = hiltViewModel()
) {
    var username by remember { mutableStateOf("") }
    var password by remember { mutableStateOf("") }
    val isLoading by viewModel.isLoading.collectAsState()
    val error by viewModel.error.collectAsState()

    Surface(
        modifier = Modifier.fillMaxSize(),
        color = Color.Black
    ) {
        Column(
            modifier = Modifier
                .fillMaxSize()
                .padding(24.dp)
                .verticalScroll(rememberScrollState()),
            horizontalAlignment = Alignment.CenterHorizontally
        ) {
            Spacer(modifier = Modifier.height(48.dp))
            
            Text(
                "GRAND STAKES",
                style = MaterialTheme.typography.displayLarge.copy(
                    fontStyle = FontStyle.Italic,
                    color = GoldPrimary,
                    letterSpacing = 2.sp
                ),
                textAlign = TextAlign.Center
            )
            
            Text(
                "THE HIGH-ROLLER'S PRIVATE ATELIER",
                style = MaterialTheme.typography.labelSmall.copy(
                    color = MaterialTheme.colorScheme.onSurfaceVariant,
                    letterSpacing = 4.sp
                ),
                textAlign = TextAlign.Center
            )
            
            Spacer(modifier = Modifier.height(48.dp))
            
            Surface(
                color = MaterialTheme.colorScheme.surfaceVariant,
                shape = androidx.compose.foundation.shape.RoundedCornerShape(4.dp),
                shadowElevation = 8.dp
            ) {
                Column(
                    modifier = Modifier.padding(32.dp),
                    horizontalAlignment = Alignment.CenterHorizontally
                ) {
                    Text(
                        "Welcome Back",
                        style = MaterialTheme.typography.headlineMedium.copy(color = Color.White),
                        textAlign = TextAlign.Center
                    )
                    
                    Spacer(modifier = Modifier.height(32.dp))
                    
                    error?.let {
                        Text(it, color = MaterialTheme.colorScheme.secondary, textAlign = TextAlign.Center)
                        Spacer(modifier = Modifier.height(16.dp))
                    }
                    
                    GrandStakesTextField(
                        value = username,
                        onValueChange = { username = it },
                        label = "IDENTITY",
                        placeholder = "Username or Email",
                        leadingIcon = { Icon(Icons.Outlined.AlternateEmail, contentDescription = null, tint = MaterialTheme.colorScheme.onSurfaceVariant) }
                    )
                    
                    Spacer(modifier = Modifier.height(24.dp))
                    
                    GrandStakesTextField(
                        value = password,
                        onValueChange = { password = it },
                        label = "CREDENTIAL",
                        placeholder = "••••••••",
                        leadingIcon = { Icon(Icons.Outlined.Lock, contentDescription = null, tint = MaterialTheme.colorScheme.onSurfaceVariant) }
                    )
                    
                    Spacer(modifier = Modifier.height(32.dp))
                    
                    GrandStakesButton(
                        text = if (isLoading) "VERIFYING..." else "ENTER THE ATELIER",
                        onClick = { viewModel.login(username, password, onLoginSuccess) },
                        enabled = !isLoading
                    )
                }
            }
            
            Spacer(modifier = Modifier.height(48.dp))
            
            Row(verticalAlignment = Alignment.CenterVertically) {
                Text("Not a member of the circle? ", color = MaterialTheme.colorScheme.onSurfaceVariant, fontSize = 12.sp)
                TextButton(onClick = onNavigateToRegister) {
                    Text("Request Invitation", color = GoldPrimary, fontWeight = FontWeight.Bold, fontSize = 12.sp)
                }
            }
        }
    }
}
