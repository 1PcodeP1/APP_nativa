package com.grandstakes

import android.os.Bundle
import androidx.activity.ComponentActivity
import androidx.activity.compose.setContent
import androidx.compose.runtime.collectAsState
import androidx.compose.runtime.getValue
import androidx.hilt.navigation.compose.hiltViewModel
import androidx.navigation.compose.NavHost
import androidx.navigation.compose.composable
import androidx.navigation.compose.rememberNavController
import com.grandstakes.ui.auth.AuthViewModel
import com.grandstakes.ui.auth.LoginScreen
import com.grandstakes.ui.auth.RegisterScreen
import com.grandstakes.ui.main.MainScreen
import com.grandstakes.ui.theme.GrandStakesTheme
import dagger.hilt.android.AndroidEntryPoint

@AndroidEntryPoint
class MainActivity : ComponentActivity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContent {
            GrandStakesTheme {
                val navController = rememberNavController()
                val authViewModel: AuthViewModel = hiltViewModel()
                val currentUser by authViewModel.currentUser.collectAsState()

                NavHost(
                    navController = navController,
                    startDestination = if (currentUser == null) "login" else "main"
                ) {
                    composable("login") {
                        LoginScreen(
                            onNavigateToRegister = { navController.navigate("register") },
                            onLoginSuccess = { navController.navigate("main") { popUpTo("login") { inclusive = true } } }
                        )
                    }
                    composable("register") {
                        RegisterScreen(
                            onNavigateBack = { navController.popBackStack() },
                            onRegisterSuccess = { navController.navigate("main") { popUpTo("login") { inclusive = true } } }
                        )
                    }
                    composable("main") {
                        MainScreen(
                            onLogout = {
                                authViewModel.logout()
                                navController.navigate("login") { popUpTo("main") { inclusive = true } }
                            }
                        )
                    }
                }
            }
        }
    }
}
