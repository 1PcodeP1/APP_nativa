package com.grandstakes.data.db

import androidx.room.*
import com.grandstakes.data.model.User
import com.grandstakes.data.model.Transaction
import kotlinx.coroutines.flow.Flow

@Dao
interface UserDao {
    @Query("SELECT * FROM users WHERE LOWER(username) = LOWER(:username) LIMIT 1")
    suspend fun getUserByUsername(username: String): User?
    
    @Query("SELECT * FROM users WHERE LOWER(username) = LOWER(:identity) OR LOWER(email) = LOWER(:identity) LIMIT 1")
    suspend fun getUserByIdentity(identity: String): User?

    @Query("SELECT * FROM users WHERE LOWER(email) = LOWER(:email) LIMIT 1")
    suspend fun getUserByEmail(email: String): User?

    @Insert(onConflict = OnConflictStrategy.REPLACE)
    suspend fun insertUser(user: User)

    @Update
    suspend fun updateUser(user: User)

    @Query("UPDATE users SET balance = balance + :amount WHERE username = :username")
    suspend fun updateBalance(username: String, amount: Int)

    @Insert
    suspend fun insertTransaction(transaction: Transaction)

    @Query("SELECT * FROM transactions WHERE username = :username ORDER BY timestamp DESC")
    fun getTransactions(username: String): Flow<List<Transaction>>
}

@Database(entities = [User::class, Transaction::class], version = 1, exportSchema = false)
abstract class AppDatabase : RoomDatabase() {
    abstract fun userDao(): UserDao
}
