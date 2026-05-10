import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/services.dart';

class SoundService {
  // Audio players for overlapping sounds
  static final AudioPlayer _player = AudioPlayer();
  static final AudioPlayer _bgPlayer = AudioPlayer();
  static final AudioPlayer _winPlayer = AudioPlayer();

  // Sounds from assets
  static const String _cardDrawAsset = "images/Drawing Playing Cards Sound Effect.mp3";
  static const String _jazzBgAsset = "images/Jazz Music #1 (No Copyright).mp3";
  static const String _wheelSpinAsset = "images/Lucky wheel spin sound effect.mp3";
  static const String _slotJackpotAsset = "images/Slot Machine Jackpot Sound Effect.mp3";

  static Future<void> playCardDraw() async {
    try {
      HapticFeedback.lightImpact();
      await _player.play(AssetSource(_cardDrawAsset), volume: 0.8);
    } catch (e) {}
  }

  static Future<void> playBackgroundJazz() async {
    try {
      _bgPlayer.setReleaseMode(ReleaseMode.loop);
      await _bgPlayer.play(AssetSource(_jazzBgAsset), volume: 0.3);
    } catch (e) {}
  }

  static Future<void> stopBackgroundJazz() async {
    try {
      await _bgPlayer.stop();
    } catch (e) {}
  }

  static Future<void> playLuckyWheelSpin() async {
    try {
      HapticFeedback.mediumImpact();
      await _player.play(AssetSource(_wheelSpinAsset), volume: 0.8);
    } catch (e) {}
  }

  static Future<void> playSlotJackpot() async {
    try {
      HapticFeedback.heavyImpact();
      await _winPlayer.play(AssetSource(_slotJackpotAsset), volume: 1.0);
    } catch (e) {}
  }

  static Future<void> playClick() async {
    try {
      HapticFeedback.lightImpact();
    } catch (e) {}
  }

  static Future<void> playSpin() async {
    try {
      HapticFeedback.mediumImpact();
    } catch (e) {}
  }

  static Future<void> playWin() async {
    try {
      HapticFeedback.heavyImpact();
    } catch (e) {}
  }
}
