package com.grandstakes.ui.components

import androidx.compose.foundation.BorderStroke
import androidx.compose.foundation.background
import androidx.compose.foundation.border
import androidx.compose.foundation.clickable
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.shape.CircleShape
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.AccountBalanceWallet
import androidx.compose.material.icons.filled.AccountCircle
import androidx.compose.material.icons.filled.ChevronRight
import androidx.compose.material.icons.filled.Menu
import androidx.compose.material3.*
import androidx.compose.runtime.*
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.text.font.FontStyle
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import com.grandstakes.ui.theme.GoldPrimary
import com.grandstakes.ui.theme.DarkSurfaceContainer
import com.grandstakes.ui.theme.OnSurfaceVariant
import androidx.compose.foundation.text.KeyboardOptions
import androidx.compose.ui.text.input.PasswordVisualTransformation
import androidx.compose.ui.text.input.VisualTransformation
import androidx.compose.ui.text.input.ImeAction
import androidx.compose.ui.text.input.KeyboardType

@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun GrandStakesAppBar(
    balance: Int,
    onNavigateToConfig: () -> Unit,
    onNavigateToBanking: () -> Unit,
    onLogout: () -> Unit,
    title: String = "GRAND STAKES"
) {
    CenterAlignedTopAppBar(
        title = {
            Column(horizontalAlignment = Alignment.CenterHorizontally) {
                Text(
                    text = title,
                    style = MaterialTheme.typography.titleLarge.copy(
                        color = GoldPrimary,
                        letterSpacing = 2.sp,
                        fontSize = 16.sp
                    )
                )
                Text(
                    text = "$${String.format("%,d", balance)}",
                    style = MaterialTheme.typography.labelSmall.copy(
                        color = OnSurfaceVariant,
                        fontSize = 10.sp,
                        letterSpacing = 1.sp
                    )
                )
            }
        },
        navigationIcon = {
            IconButton(onClick = onNavigateToConfig) {
                Icon(
                    imageVector = Icons.Default.AccountCircle,
                    contentDescription = "Profile",
                    tint = GoldPrimary,
                    modifier = Modifier.size(24.dp)
                )
            }
        },
        actions = {
            IconButton(onClick = onNavigateToBanking) {
                Icon(
                    imageVector = Icons.Default.AccountBalanceWallet,
                    contentDescription = "Banking",
                    tint = GoldPrimary,
                    modifier = Modifier.size(24.dp)
                )
            }
        },
        colors = TopAppBarDefaults.centerAlignedTopAppBarColors(
            containerColor = Color.Transparent,
            titleContentColor = GoldPrimary
        )
    )
}

@Composable
fun GrandStakesButton(
    text: String,
    onClick: () -> Unit,
    modifier: Modifier = Modifier,
    containerColor: Color = GoldPrimary,
    contentColor: Color = Color.Black,
    enabled: Boolean = true,
    trailingIcon: @Composable (() -> Unit)? = null
) {
    Surface(
        modifier = modifier
            .clickable(enabled = enabled, onClick = onClick),
        color = if (enabled) containerColor else Color.Gray.copy(alpha = 0.3f),
        shape = RoundedCornerShape(0.dp), // Sharper corners for luxury feel
        border = if (!enabled) BorderStroke(1.dp, Color.Gray.copy(alpha = 0.5f)) else null
    ) {
        Row(
            modifier = Modifier.padding(vertical = 14.dp, horizontal = 24.dp),
            verticalAlignment = Alignment.CenterVertically,
            horizontalArrangement = Arrangement.Center
        ) {
            Text(
                text = text.uppercase(),
                style = MaterialTheme.typography.labelSmall.copy(
                    color = if (enabled) contentColor else Color.Gray,
                    fontWeight = FontWeight.ExtraBold,
                    letterSpacing = 2.sp
                )
            )
            if (trailingIcon != null) {
                Spacer(Modifier.width(8.dp))
                trailingIcon()
            }
        }
    }
}

@Composable
fun GrandStakesTextField(
    value: String,
    onValueChange: (String) -> Unit,
    label: String,
    modifier: Modifier = Modifier,
    placeholder: String = "",
    leadingIcon: @Composable (() -> Unit)? = null,
    isPassword: Boolean = false,
    singleLine: Boolean = true,
    keyboardType: KeyboardType = KeyboardType.Text,
    imeAction: ImeAction = ImeAction.Next
) {
    Column(modifier = modifier) {
        Text(
            text = label.uppercase(),
            style = MaterialTheme.typography.labelSmall.copy(
                color = MaterialTheme.colorScheme.onSurfaceVariant,
                fontWeight = FontWeight.Bold
            ),
            modifier = Modifier.padding(bottom = 8.dp)
        )
        TextField(
            value = value,
            onValueChange = onValueChange,
            modifier = Modifier.fillMaxWidth(),
            placeholder = { Text(placeholder, color = MaterialTheme.colorScheme.onSurfaceVariant.copy(alpha = 0.5f)) },
            leadingIcon = leadingIcon,
            visualTransformation = if (isPassword) PasswordVisualTransformation() else VisualTransformation.None,
            keyboardOptions = KeyboardOptions(
                keyboardType = if (isPassword) KeyboardType.Password else keyboardType,
                imeAction = imeAction
            ),
            singleLine = singleLine,
            colors = TextFieldDefaults.colors(
                focusedContainerColor = DarkSurfaceContainer,
                unfocusedContainerColor = DarkSurfaceContainer,
                focusedIndicatorColor = GoldPrimary,
                unfocusedIndicatorColor = Color.Transparent,
                focusedTextColor = Color.White,
                unfocusedTextColor = Color.White
            )
        )
    }
}
