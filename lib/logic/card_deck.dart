import 'dart:math';

enum Suit { hearts, diamonds, clubs, spades }
enum Rank { two, three, four, five, six, seven, eight, nine, ten, jack, queen, king, ace }

class PlayingCard {
  final Suit suit;
  final Rank rank;

  PlayingCard(this.suit, this.rank);

  String get label {
    switch (rank) {
      case Rank.ace: return "A";
      case Rank.jack: return "J";
      case Rank.queen: return "Q";
      case Rank.king: return "K";
      case Rank.two: return "2";
      case Rank.three: return "3";
      case Rank.four: return "4";
      case Rank.five: return "5";
      case Rank.six: return "6";
      case Rank.seven: return "7";
      case Rank.eight: return "8";
      case Rank.nine: return "9";
      case Rank.ten: return "10";
    }
  }

  String get suitSymbol {
    switch (suit) {
      case Suit.hearts: return "♥️";
      case Suit.diamonds: return "♦️";
      case Suit.clubs: return "♣️";
      case Suit.spades: return "♠️";
    }
  }

  int get blackjackValue {
    if (rank == Rank.ace) return 11;
    if (rank == Rank.jack || rank == Rank.queen || rank == Rank.king) return 10;
    return rank.index + 2; 
  }

  int get baccaratValue {
    if (rank == Rank.ten || rank == Rank.jack || rank == Rank.queen || rank == Rank.king) return 0;
    if (rank == Rank.ace) return 1;
    return rank.index + 2;
  }
  
  bool get isRed => suit == Suit.hearts || suit == Suit.diamonds;
}

class Deck {
  List<PlayingCard> cards = [];

  Deck() {
    _initDeck();
  }

  void _initDeck() {
    cards.clear();
    for (int i = 0; i < 6; i++) { // 6 Decks estándar de mesa real
      for (var suit in Suit.values) {
        for (var rank in Rank.values) {
          cards.add(PlayingCard(suit, rank));
        }
      }
    }
    cards.shuffle(Random());
  }

  PlayingCard draw() {
    if (cards.isEmpty) _initDeck();
    return cards.removeLast();
  }
}
