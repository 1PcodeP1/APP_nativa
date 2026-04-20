package com.grandstakes.ui.auth

import androidx.lifecycle.ViewModel
import androidx.lifecycle.viewModelScope
import com.grandstakes.data.repository.AuthRepository
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
            if (repository.login(username, psw)) {
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
            if (repository.register(username, name, email, psw)) {
                onSelection()
            } else {
                _error.value = "Registration failed. Username may be taken."
            }
            _isLoading.value = false
        }
    }

    fun logout() {
        repository.logout()
    }
}
