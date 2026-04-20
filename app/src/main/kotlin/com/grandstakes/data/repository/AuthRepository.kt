package com.grandstakes.data.repository

import com.grandstakes.data.db.UserDao
import com.grandstakes.data.model.Transaction
import com.grandstakes.data.model.User
import kotlinx.coroutines.flow.Flow
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.asStateFlow
import javax.inject.Inject
import javax.inject.Singleton

@Singleton
class AuthRepository @Inject constructor(
    private val userDao: UserDao
) {
    private val _currentUser = MutableStateFlow<User?>(null)
    val currentUser = _currentUser.asStateFlow()

    suspend fun login(username: String, password: String): Boolean {
        val user = userDao.getUserByUsername(username)
        return if (user != null && user.passwordHash == password) {
            _currentUser.value = user
            true
        } else {
            false
        }
    }

    suspend fun register(username: String, name: String, email: String, password: String): Boolean {
        if (userDao.getUserByUsername(username) != null) return false
        val newUser = User(username = username, name = name, email = email, passwordHash = password)
        userDao.insertUser(newUser)
        _currentUser.value = newUser
        return true
    }

    fun logout() {
        _currentUser.value = null
    }

    suspend fun updateBalance(amount: Int, gameName: String) {
        val user = _currentUser.value ?: return
        userDao.updateBalance(user.username, amount)
        userDao.insertTransaction(
            Transaction(username = user.username, game = gameName, amount = amount)
        )
        // Refresh local user state
        _currentUser.value = userDao.getUserByUsername(user.username)
    }
    
    suspend fun upgradeToVip() {
        val user = _currentUser.value ?: return
        val updatedUser = user.copy(isVip = true)
        userDao.updateUser(updatedUser)
        _currentUser.value = updatedUser
    }

    fun getTransactions(): Flow<List<Transaction>> {
        return _currentUser.value?.let { userDao.getTransactions(it.username) } 
            ?: kotlinx.coroutines.flow.flowOf(emptyList())
    }
}
