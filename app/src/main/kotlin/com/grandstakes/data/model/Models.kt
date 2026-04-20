package com.grandstakes.data.model

import androidx.room.Entity
import androidx.room.PrimaryKey

@Entity(tableName = "users")
data class User(
    @PrimaryKey val username: String,
    val name: String,
    val email: String,
    val passwordHash: String, // Mocked as plaintext or simple hash for replication
    val balance: Int = 1000,
    val isVip: Boolean = false,
    val jackpotAlerts: Boolean = true,
    val tableOpenings: Boolean = false,
    val marketingEditorial: Boolean = true
)

@Entity(tableName = "transactions")
data class Transaction(
    @PrimaryKey(autoGenerate = true) val id: Long = 0,
    val username: String,
    val game: String,
    val amount: Int,
    val timestamp: Long = System.currentTimeMillis()
)
