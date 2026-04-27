package com.grandstakes.data.repository

import com.grandstakes.data.db.UserDao
import com.grandstakes.data.model.Transaction
import com.grandstakes.data.model.User
import kotlinx.coroutines.ExperimentalCoroutinesApi
import kotlinx.coroutines.flow.*
import javax.inject.Inject
import javax.inject.Singleton

sealed class RegisterResult {
    object Success : RegisterResult()
    object UsernameTaken : RegisterResult()
    object EmailTaken : RegisterResult()
    object Error : RegisterResult()
}

@Singleton
class AuthRepository @Inject constructor(
    private val userDao: UserDao
) {
    private val _currentUser = MutableStateFlow<User?>(null)
    val currentUser = _currentUser.asStateFlow()

    suspend fun login(identity: String, password: String): Boolean {
        val user = userDao.getUserByIdentity(identity)
        return if (user != null && user.passwordHash == password) {
            _currentUser.value = user
            true
        } else {
            false
        }
    }

    suspend fun register(username: String, name: String, email: String, password: String): RegisterResult {
        if (userDao.getUserByUsername(username) != null) return RegisterResult.UsernameTaken
        if (userDao.getUserByEmail(email) != null) return RegisterResult.EmailTaken
        
        return try {
            val newUser = User(username = username, name = name, email = email, passwordHash = password)
            userDao.insertUser(newUser)
            _currentUser.value = newUser
            RegisterResult.Success
        } catch (e: Exception) {
            RegisterResult.Error
        }
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

    @OptIn(ExperimentalCoroutinesApi::class)
    fun getTransactions(): Flow<List<Transaction>> {
        return _currentUser.flatMapLatest { user ->
            if (user == null) flowOf(emptyList())
            else userDao.getTransactions(user.username)
        }
    }
}
