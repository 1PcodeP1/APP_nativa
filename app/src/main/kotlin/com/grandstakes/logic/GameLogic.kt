package com.grandstakes.logic

enum class Suit(val symbol: String, val isRed: Boolean) {
    HEARTS("♥️", true),
    DIAMONDS("♦️", true),
    CLUBS("♣️", false),
    SPADES("♠️", false)
}

enum class Rank(val label: String) {
    TWO("2"), THREE("3"), FOUR("4"), FIVE("5"), SIX("6"), SEVEN("7"), EIGHT("8"), NINE("9"), TEN("10"),
    JACK("J"), QUEEN("Q"), KING("K"), ACE("A")
}

data class PlayingCard(
    val suit: Suit,
    val rank: Rank
) {
    val blackjackValue: Int
        get() = when (rank) {
            Rank.ACE -> 11
            Rank.JACK, Rank.QUEEN, Rank.KING -> 10
            else -> rank.ordinal + 2
        }

    val baccaratValue: Int
        get() = when (rank) {
            Rank.TEN, Rank.JACK, Rank.QUEEN, Rank.KING -> 0
            Rank.ACE -> 1
            else -> rank.ordinal + 2
        }
}

class Deck {
    private val cards = mutableListOf<PlayingCard>()

    init {
        reset()
    }

    fun reset() {
        cards.clear()
        // Standard 6-deck shoe like in the original Flutter app
        repeat(6) {
            Suit.entries.forEach { suit ->
                Rank.entries.forEach { rank ->
                    cards.add(PlayingCard(suit, rank))
                }
            }
        }
        cards.shuffle()
    }

    fun draw(): PlayingCard {
        if (cards.isEmpty()) reset()
        return cards.removeAt(cards.size - 1)
    }
}
