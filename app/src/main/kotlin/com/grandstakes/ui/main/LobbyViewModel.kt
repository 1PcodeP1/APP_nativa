package com.grandstakes.ui.main

import androidx.lifecycle.ViewModel
import androidx.lifecycle.viewModelScope
import com.grandstakes.data.repository.AuthRepository
import dagger.hilt.android.lifecycle.HiltViewModel
import kotlinx.coroutines.flow.SharingStarted
import kotlinx.coroutines.flow.stateIn
import kotlinx.coroutines.launch
import javax.inject.Inject

@HiltViewModel
class LobbyViewModel @Inject constructor(
    private val repository: AuthRepository
) : ViewModel() {

    val currentUser = repository.currentUser

    val transactions = repository.getTransactions().stateIn(
        scope = viewModelScope,
        started = SharingStarted.WhileSubscribed(5000),
        initialValue = emptyList()
    )

    fun updateBalance(amount: Int, game: String) {
        viewModelScope.launch {
            repository.updateBalance(amount, game)
        }
    }
    
    fun upgradeToVip() {
        viewModelScope.launch {
            repository.upgradeToVip()
        }
    }

    fun logout() {
        repository.logout()
    }
}
