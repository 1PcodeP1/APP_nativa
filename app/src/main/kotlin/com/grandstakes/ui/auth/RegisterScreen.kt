package com.grandstakes.ui.auth

import androidx.compose.foundation.layout.*
import androidx.compose.foundation.rememberScrollState
import androidx.compose.foundation.verticalScroll
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.automirrored.filled.ArrowBack
import androidx.compose.material.icons.automirrored.filled.ArrowForward
import androidx.compose.material.icons.outlined.Email
import androidx.compose.material.icons.outlined.Lock
import androidx.compose.material.icons.outlined.Person
import androidx.compose.material3.*
import androidx.compose.runtime.*
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.text.font.FontStyle
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import androidx.hilt.navigation.compose.hiltViewModel
import com.grandstakes.ui.components.GrandStakesButton
import com.grandstakes.ui.components.GrandStakesTextField
import com.grandstakes.ui.theme.GoldPrimary

@Composable
fun RegisterScreen(
    onNavigateBack: () -> Unit,
    onRegisterSuccess: () -> Unit,
    viewModel: AuthViewModel = hiltViewModel()
) {
    var name by remember { mutableStateOf("") }
    var email by remember { mutableStateOf("") }
    var password by remember { mutableStateOf("") }
    var dob by remember { mutableStateOf("") }
    
    val isLoading by viewModel.isLoading.collectAsState()
    val error by viewModel.error.collectAsState()

    Surface(modifier = Modifier.fillMaxSize(), color = Color.Black) {
        Column(
            modifier = Modifier
                .fillMaxSize()
                .padding(24.dp)
                .verticalScroll(rememberScrollState())
        ) {
            IconButton(onClick = onNavigateBack, modifier = Modifier.padding(top = 16.dp)) {
                Icon(Icons.AutoMirrored.Filled.ArrowBack, contentDescription = "Back", tint = GoldPrimary)
            }
            
            Spacer(modifier = Modifier.height(16.dp))
            
            Text(
                "EXCLUSIVITY AWAITS",
                style = MaterialTheme.typography.labelSmall.copy(color = GoldPrimary, letterSpacing = 2.sp)
            )
            
            Spacer(modifier = Modifier.height(16.dp))
            
            Text("Enter the", style = MaterialTheme.typography.displayLarge.copy(color = Color.White))
            Text(
                "Private Atelier",
                style = MaterialTheme.typography.displayLarge.copy(
                    color = GoldPrimary,
                    fontStyle = FontStyle.Italic
                )
            )
            
            Spacer(modifier = Modifier.height(32.dp))
            
            Surface(
                color = MaterialTheme.colorScheme.surfaceVariant,
                shape = androidx.compose.foundation.shape.RoundedCornerShape(4.dp)
            ) {
                Column(modifier = Modifier.padding(24.dp)) {
                    error?.let {
                        Text(it, color = MaterialTheme.colorScheme.secondary, modifier = Modifier.padding(bottom = 16.dp))
                    }
                    
                    GrandStakesTextField(
                        value = name,
                        onValueChange = { name = it },
                        label = "FULL LEGAL NAME",
                        placeholder = "E.g. James Vane",
                        leadingIcon = { Icon(Icons.Outlined.Person, contentDescription = null) }
                    )
                    
                    Spacer(modifier = Modifier.height(24.dp))
                    
                    GrandStakesTextField(
                        value = email,
                        onValueChange = { email = it },
                        label = "EMAIL ADDRESS",
                        placeholder = "james@vane.com",
                        leadingIcon = { Icon(Icons.Outlined.Email, contentDescription = null) }
                    )
                    
                    Spacer(modifier = Modifier.height(24.dp))
                    
                    GrandStakesTextField(
                        value = password,
                        onValueChange = { password = it },
                        label = "SECURITY PASSWORD",
                        placeholder = "••••••••",
                        leadingIcon = { Icon(Icons.Outlined.Lock, contentDescription = null) }
                    )
                    
                    Spacer(modifier = Modifier.height(48.dp))
                    
                    GrandStakesButton(
                        text = if (isLoading) "PROCESSING..." else "JOIN THE ELITE",
                        onClick = { viewModel.register(email, name, email, password, onRegisterSuccess) },
                        enabled = !isLoading && email.isNotEmpty() && password.isNotEmpty()
                    )
                }
            }
        }
    }
}
