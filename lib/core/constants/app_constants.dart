class AppConstants {
  // App Info
  static const String appName = 'Memora';
  static const String appTagline = 'Watch Your Love Grow';
  static const String appVersion = '1.0.0';

  // Firebase Collections
  static const String usersCollection = 'users';
  static const String couplesCollection = 'couples';
  static const String treesCollection = 'trees';
  static const String memosCollection = 'memos';

  // Storage Paths
  static const String memoPhotosPath = 'memos';
  static const String profilePhotosPath = 'profiles';
  static const String voiceNotesPath = 'voices';

  // Growth Constants
  static const int maxLovePointsPerDay = 100;
  static const int memoTextPoints = 5;
  static const int memoPhotoPoints = 7;
  static const int memoVoicePoints = 8;
  static const int reactionPoints = 2;
  static const double growthPerPoint = 0.5;

  // Decay Settings
  static const int daysBeforeDecay = 3;
  static const double dailyDecayRate = 0.01;

  // Tree Types
  static const List<String> treeTypes = [
    'SakuraTree',
    'MapleTree',
    'OakTree',
    'PineTree',
    'RoseTree',
  ];

  // Validation
  static const int minPasswordLength = 8;
  static const int maxMemoLength = 500;
  static const int pairingCodeLength = 6;

  // Notification Messages
  static const String reminderTitle = '🌱 Your tree misses you!';
  static const String reminderBody = 'Add a memory to keep your love growing';

  // Error Messages
  static const String errorGeneric = 'Something went wrong. Please try again.';
  static const String errorNetwork = 'Network error. Check your connection.';
  static const String errorAuth = 'Authentication failed.';
  static const String errorPairing = 'Invalid pairing code.';
}
