class AppConstants {
  static const String appName = 'Ludo Masters';
  static const String appVersion = '1.0.0';

  // Coins
  static const int SIGN_UP_BONUS = 100;
  static const int DAILY_REWARD = 10;

  // Entry Fees
  static const int ENTRY_FEE_2P = 10;
  static const int ENTRY_FEE_3P = 15;
  static const int ENTRY_FEE_4P = 20;

  // Tournament
  static const int TOURNAMENT_FEE_8 = 50;
  static const int TOURNAMENT_FEE_16 = 100;

  // Game
  static const int MAX_DICE_VALUE = 6;
  static const int TOTAL_SQUARES = 52;
  static const int HOME_SQUARES = 6;
  static const List<int> SAFE_ZONES = [0, 8, 13, 21, 26, 34, 39, 47, 52];
}
