# Grand Stakes Pro Simulator

**Grand Stakes Pro Simulator** is a high-fidelity, risk-free casino simulator built entirely in Flutter. It is designed to recreate the luxurious experience of a private "high-roller" atelier, offering an elegant UI, realistic sound design, and robust state management for a persistent local gaming experience.

## 💎 Features

- **Exclusive Authentication System:** 
  - Strict local authentication utilizing Hive for persistent data storage.
  - Case-insensitive login supporting both email and usernames.
  - Multi-session handling where each user has an isolated balance, transaction history, and unique settings.
  - "Guest Mode" for quick, anonymous entry.

- **Immersive Gaming Modules:**
  - **Blackjack:** Fully functional logic including Hit, Stand, Double Down, Split, and Surrender.
  - **Roulette:** Smooth physics-based wheel spinning animations and varied betting options.
  - **Slots (The Pit):** Dynamic multi-reel spinning with randomized payouts (Minor, Major, Grand Jackpots).
  - **Baccarat:** Authentic ruleset and card dealing.

- **Reactive State & Persistence:**
  - Powered by **Hive** (`hive_flutter`), ensuring that balances and statistics update in real-time across the application (`ValueListenableBuilder`).
  - Comprehensive player profiles, cool-off (Time-out) features, and simulated Two-Factor Authentication settings.

- **Audio-Visual Experience:**
  - Custom soundboard powered by the `audioplayers` package.
  - Seamless background Jazz music on loop.
  - Contextual sound effects for card drawing, slot jackpots, roulette spinning, and interactions.
  - Premium dark-mode UI with rich gold (`#D4AF37`) and ruby accents, designed with responsive constraints to avoid overflows on desktop and web browsers.

## 🚀 Getting Started

### Prerequisites
  - Flutter SDK (latest stable version recommended)
  - Dart SDK

### Installation

1. Clone or download the repository to your local machine.
2. Ensure you have the required assets configured in `pubspec.yaml` (including all mp3 and video files placed in `assets/images/`).
3. Run the following commands to initialize the project:

```bash
flutter clean
flutter pub get
```

### Running the App

To run the application on your default browser (Chrome) for web testing:

```bash
flutter run -d chrome
```

To run on an iOS Simulator:
1. Open the Simulator: `open -a Simulator`
2. Run the app: `flutter run` (Select the iOS simulator from the list).

## 📁 Project Structure

- `lib/db/`: Contains the `auth_service.dart` which manages all Hive local storage interactions, account creation, and transaction history.
- `lib/screens/`: Contains all the UI views.
  - `/auth`: Registration and strict Login flows.
  - `main_layout.dart`: The core navigation scaffold with the BottomNavigationBar.
  - `lobby_screen.dart`: The homepage and promotional banners.
  - `score_screen.dart`: A reactive dashboard displaying the current balance and transaction history.
  - `config_screen.dart`: Profile settings, password changes, and responsible gaming limits.
  - `blackjack_screen.dart`, `roulette_screen.dart`, `slot_game_screen.dart`, etc.: Individual game logic screens.
- `lib/services/`: Contains `sound_service.dart` for global audio handling.
- `lib/theme.dart`: Global color palettes and text themes.

## 🛠 Built With
- [Flutter](https://flutter.dev/)
- [Hive](https://docs.hivedb.dev/) - Lightweight and blazing fast local database written in pure Dart.
- [Audioplayers](https://pub.dev/packages/audioplayers) - For playing local audio assets seamlessly.

## 🤝 Credits
Developed by:
- Daniel Gonzales Cardona
- Santiago Posso Acevedo
- Carlos Andrés Baena Moncada

*Disclaimer: This is a simulated environment intended solely for entertainment and portfolio demonstration purposes. No real money or actual gambling is involved.*
