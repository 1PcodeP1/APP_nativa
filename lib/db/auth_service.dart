import 'package:hive_flutter/hive_flutter.dart';

class AuthService {
  static const String _usersBoxName = 'usersBox';
  static const String _sessionBoxName = 'sessionBox';

  static Future<void> init() async {
    await Hive.initFlutter();
    await Hive.openBox(_usersBoxName);
    await Hive.openBox(_sessionBoxName);
  }

  static Box get _users => Hive.box(_usersBoxName);
  static Box get _session => Hive.box(_sessionBoxName);

  static Future<bool> register(String username, String password, String name, String email) async {
    if (_users.containsKey(username)) return false; 
    await _users.put(username, {
      'password': password,
      'name': name,
      'email': email,
      'isVip': false,
      'balance': 5000, 
      'transactions': [], // Complete list of transactions
      'settings': {
        'jackpotAlerts': true,
        'tableOpenings': false,
        'marketingEditorial': true,
      }
    });
    await _session.put('currentUser', username);
    return true;
  }

  static Future<bool> login(String identifier, String password) async {
    dynamic userData = _users.get(identifier);
    String usernameKey = identifier;

    if (userData == null) {
      for (var key in _users.keys) {
        final userMap = _users.get(key);
        if (userMap != null && userMap['email'] == identifier) {
          userData = userMap;
          usernameKey = key;
          break;
        }
      }
    }

    if (userData != null && userData['password'] == password) {
      await _session.put('currentUser', usernameKey);
      return true;
    }
    return false;
  }

  static Future<void> logout() async {
    await _session.delete('currentUser');
  }

  static bool get isLoggedIn => _session.containsKey('currentUser');

  static String? get currentUser => _session.get('currentUser') as String?;

  static Map<dynamic, dynamic>? getUserData() {
    final user = currentUser;
    if (user == null) return null;
    return _users.get(user);
  }

  static Future<void> updateUserSettings(Map<String, dynamic> newSettings) async {
    final user = currentUser;
    if (user != null) {
      final userData = Map<String, dynamic>.from(_users.get(user) ?? {});
      if (userData.isNotEmpty) {
        final currentSettings = Map<String, dynamic>.from(userData['settings'] ?? {});
        currentSettings.addAll(newSettings);
        userData['settings'] = currentSettings;
        await _users.put(user, userData);
      }
    }
  }

  static Future<void> updateUserName(String newName) async {
    final user = currentUser;
    if (user != null) {
      final userData = Map<String, dynamic>.from(_users.get(user) ?? {});
      if (userData.isNotEmpty) {
        userData['name'] = newName;
        await _users.put(user, userData);
      }
    }
  }

  static int get currentBalance {
    final user = currentUser;
    if (user == null) return 0;
    final userData = _users.get(user);
    return userData?['balance'] ?? 0;
  }
  
  static List<dynamic> getTransactions() {
    final user = currentUser;
    if (user == null) return [];
    final userData = _users.get(user);
    return userData?['transactions'] ?? [];
  }

  static Future<void> updateBalance(int amountChange, {String? gameName}) async {
    final user = currentUser;
    if (user != null) {
      final userData = Map<String, dynamic>.from(_users.get(user) ?? {});
      if (userData.isNotEmpty) {
        int current = userData['balance'] ?? 0;
        userData['balance'] = current + amountChange;
        
        if (gameName != null) {
          List<dynamic> txs = userData['transactions'] ?? [];
          txs.insert(0, {
            'game': gameName,
            'amount': amountChange,
            'timestamp': DateTime.now().toIso8601String(),
          });
          userData['transactions'] = txs;
        }
        
        await _users.put(user, userData);
      }
    }
  }

  static bool isVip() {
    final user = currentUser;
    if (user == null) return false;
    final userData = _users.get(user);
    if (userData == null) return false;
    return userData['isVip'] == true;
  }

  static Future<void> upgradeToVip() async {
    final user = currentUser;
    if (user != null) {
      final userData = _users.get(user);
      if (userData != null) {
        userData['isVip'] = true;
        int current = userData['balance'] ?? 0;
        userData['balance'] = current + 25000; // Bono VIP
        await _users.put(user, userData);
      }
    }
  }
}

