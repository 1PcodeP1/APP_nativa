package com.grandstakes.ui.auth

import androidx.lifecycle.ViewModel
import androidx.lifecycle.viewModelScope
import com.grandstakes.data.repository.AuthRepository
import com.grandstakes.data.repository.RegisterResult
import dagger.hilt.android.lifecycle.HiltViewModel
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.asStateFlow
import kotlinx.coroutines.launch
import javax.inject.Inject

@HiltViewModel
class AuthViewModel @Inject constructor(
    private val repository: AuthRepository
) : ViewModel() {

    private val _isLoading = MutableStateFlow(false)
    val isLoading = _isLoading.asStateFlow()

    private val _error = MutableStateFlow<String?>(null)
    val error = _error.asStateFlow()

    val currentUser = repository.currentUser

    fun login(username: String, psw: String, onSelection: () -> Unit) {
        viewModelScope.launch {
            _isLoading.value = true
            _error.value = null
            if (repository.login(username.trim(), psw)) {
                onSelection()
            } else {
                _error.value = "Invalid credentials. Please try again."
            }
            _isLoading.value = false
        }
    }

    fun register(username: String, name: String, email: String, psw: String, onSelection: () -> Unit) {
        viewModelScope.launch {
            _isLoading.value = true
            _error.value = null
            
            val trimmedUsername = username.trim()
            val trimmedEmail = email.trim()
            
            when (val result = repository.register(trimmedUsername, name, trimmedEmail, psw)) {
                RegisterResult.Success -> onSelection()
                RegisterResult.UsernameTaken -> _error.value = "This identity (username) is already taken."
                RegisterResult.EmailTaken -> _error.value = "This email address is already in use."
                RegisterResult.Error -> _error.value = "An error occurred during registration. Please try again."
            }
            _isLoading.value = false
        }
    }

    fun logout() {
        repository.logout()
    }
}
