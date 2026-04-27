package com.grandstakes.ui.theme

import androidx.compose.material3.Typography
import androidx.compose.ui.text.TextStyle
import androidx.compose.ui.text.font.FontFamily
import androidx.compose.ui.text.font.FontStyle
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.text.googlefonts.Font
import androidx.compose.ui.text.googlefonts.GoogleFont
import androidx.compose.ui.unit.sp
import com.grandstakes.R

private val provider = GoogleFont.Provider(
    providerAuthority = "com.google.android.gms.fonts",
    providerPackage = "com.google.android.gms",
    certificates = R.array.com_google_android_gms_fonts_certs
)

val DMSerifDisplay = FontFamily(
    Font(googleFont = GoogleFont("DM Serif Display"), fontProvider = provider),
    Font(googleFont = GoogleFont("DM Serif Display"), fontProvider = provider, style = FontStyle.Italic, weight = FontWeight.Normal)
)

val Manrope = FontFamily(
    Font(googleFont = GoogleFont("Manrope"), fontProvider = provider),
    Font(googleFont = GoogleFont("Manrope"), fontProvider = provider, weight = FontWeight.Bold),
    Font(googleFont = GoogleFont("Manrope"), fontProvider = provider, weight = FontWeight.Light),
    Font(googleFont = GoogleFont("Manrope"), fontProvider = provider, weight = FontWeight.Medium)
)

val GrandStakesTypography = Typography(
    displayLarge = TextStyle(
        fontFamily = DMSerifDisplay,
        fontWeight = FontWeight.Normal,
        fontSize = 56.sp,
        letterSpacing = (-0.25).sp,
        color = OnSurface
    ),
    headlineLarge = TextStyle(
        fontFamily = DMSerifDisplay,
        fontWeight = FontWeight.Normal,
        fontSize = 32.sp,
        color = OnSurface
    ),
    headlineMedium = TextStyle(
        fontFamily = DMSerifDisplay,
        fontWeight = FontWeight.Normal,
        fontSize = 28.sp,
        color = OnSurface
    ),
    titleLarge = TextStyle(
        fontFamily = Manrope,
        fontWeight = FontWeight.Bold,
        fontSize = 22.sp,
        color = OnSurface
    ),
    titleMedium = TextStyle(
        fontFamily = Manrope,
        fontWeight = FontWeight.Medium,
        fontSize = 18.sp,
        color = OnSurface
    ),
    bodyLarge = TextStyle(
        fontFamily = Manrope,
        fontWeight = FontWeight.Normal,
        fontSize = 16.sp,
        color = OnSurface
    ),
    bodyMedium = TextStyle(
        fontFamily = Manrope,
        fontWeight = FontWeight.Normal,
        fontSize = 14.sp,
        color = OnSurface
    ),
    labelSmall = TextStyle(
        fontFamily = Manrope,
        fontWeight = FontWeight.Bold,
        fontSize = 10.sp,
        letterSpacing = 2.0.sp
    )
)
