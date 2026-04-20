package com.grandstakes.ui.theme

import android.app.Activity
import androidx.compose.ui.graphics.Color
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.darkColorScheme
import androidx.compose.runtime.Composable
import androidx.compose.runtime.SideEffect
import androidx.compose.ui.graphics.toArgb
import androidx.compose.ui.platform.LocalView
import androidx.core.view.WindowCompat

private val DarkColorScheme = darkColorScheme(
    primary = GoldPrimary,
    onPrimary = OnGoldPrimary,
    primaryContainer = DarkSurfaceContainer,
    onPrimaryContainer = GoldPrimary,
    secondary = PinkSecondary,
    onSecondary = OnGoldPrimary,
    secondaryContainer = FeltRedPrimary,
    onSecondaryContainer = Color.White,
    background = DarkSurfaceContainerLowest,
    onBackground = OnSurface,
    surface = DarkSurface,
    onSurface = OnSurface,
    surfaceVariant = DarkSurfaceContainer,
    onSurfaceVariant = OnSurfaceVariant,
    outline = Outline,
    outlineVariant = OutlineVariant,
    tertiary = PurpleTertiary
)

@Composable
fun GrandStakesTheme(
    content: @Composable () -> Unit
) {
    val colorScheme = DarkColorScheme
    val view = LocalView.current
    if (!view.isInEditMode) {
        SideEffect {
            val window = (view.context as Activity).window
            window.statusBarColor = DarkSurfaceContainerLowest.toArgb()
            window.navigationBarColor = DarkSurfaceContainerLowest.toArgb()
            WindowCompat.getInsetsController(window, view).isAppearanceLightStatusBars = false
        }
    }

    MaterialTheme(
        colorScheme = colorScheme,
        typography = GrandStakesTypography,
        content = content
    )
}
