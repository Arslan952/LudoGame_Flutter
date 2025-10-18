class LudoMoveLogic {
  static const int BOARD_SQUARES = 52;
  static const int HOME_STRETCH = 6;
  static const List<int> SAFE_ZONES = [0, 8, 13, 21, 26, 34, 39, 47];

  // Each player's path on the board
  static const Map<int, List<int>> playerPaths = {
    0: [
      0,
      1,
      2,
      3,
      4,
      5,
      6,
      7,
      8,
      9,
      10,
      11,
      12,
      13,
      14,
      29,
      44,
      59,
      58,
      57,
      56,
      55,
      54,
      53,
      52,
      51,
      50,
      49,
      48,
      47,
      32,
      17,
      16,
    ],
    1: [
      14,
      29,
      44,
      59,
      58,
      57,
      56,
      55,
      54,
      53,
      52,
      51,
      50,
      49,
      48,
      33,
      18,
      3,
      2,
      1,
      0,
      15,
      30,
      45,
      60,
      61,
      62,
      63,
      64,
      65,
      50,
      35,
      20,
    ],
    2: [210, 195, 180, 165, 150, 135, 120, 105, 90, 75, 60, 45, 30, 15, 0],
    3: [119, 104, 89, 74, 59, 44, 29, 14, 13, 12, 11, 10, 9, 8, 7],
  };

  /// Check if a token can be moved from home
  static bool canStartFromHome(int diceValue) {
    return diceValue == 6;
  }

  /// Check if player can move any token
  static bool hasValidMoves(
    List<int> tokenPositions,
    int diceValue,
    int playerIndex,
  ) {
    for (int i = 0; i < tokenPositions.length; i++) {
      if (canMoveToken(tokenPositions[i], diceValue, playerIndex)) {
        return true;
      }
    }
    return false;
  }

  /// Check if a specific token can be moved
  static bool canMoveToken(
    int currentPosition,
    int diceValue,
    int playerIndex,
  ) {
    // Token at home (-1)
    if (currentPosition == -1) {
      return diceValue == 6;
    }

    // Token on board
    if (currentPosition >= 0 && currentPosition < BOARD_SQUARES) {
      int newPosition = currentPosition + diceValue;
      return newPosition <= BOARD_SQUARES + HOME_STRETCH;
    }

    return false;
  }

  /// Calculate new position for token
  static int moveToken(int currentPosition, int diceValue, int playerIndex) {
    // Starting from home with 6
    if (currentPosition == -1 && diceValue == 6) {
      return 0;
    }

    // Moving on board
    if (currentPosition >= 0) {
      return currentPosition + diceValue;
    }

    return currentPosition;
  }

  /// Check if position is a safe zone
  static bool isSafeZone(int position, int playerIndex) {
    if (position < 0) return true; // Home is safe
    if (position >= BOARD_SQUARES) return true; // Home stretch is safe

    return SAFE_ZONES.contains(position);
  }

  /// Check if token reached home
  static bool isTokenHome(int position) {
    return position >= BOARD_SQUARES + HOME_STRETCH;
  }

  /// Check if all tokens are home
  static bool allTokensHome(List<int> tokenPositions) {
    return tokenPositions.every((pos) => pos >= BOARD_SQUARES + HOME_STRETCH);
  }

  /// Get tokens that can be captured at position
  static List<int> getCapturableTokens(
    int position,
    List<List<int>> allTokenPositions,
    int playerIndex,
  ) {
    // Can't capture in safe zones or home
    if (isSafeZone(position, playerIndex) || position < 0) {
      return [];
    }

    List<int> capturableTokens = [];

    for (int i = 0; i < allTokenPositions.length; i++) {
      if (i == playerIndex) continue; // Skip own tokens

      for (int j = 0; j < allTokenPositions[i].length; j++) {
        if (allTokenPositions[i][j] == position) {
          capturableTokens.add(i);
        }
      }
    }

    return capturableTokens;
  }

  /// Get all valid token indices that can be moved
  static List<int> getValidTokenMoves(
    List<int> tokenPositions,
    int diceValue,
    int playerIndex,
  ) {
    List<int> validTokens = [];

    for (int i = 0; i < tokenPositions.length; i++) {
      if (canMoveToken(tokenPositions[i], diceValue, playerIndex)) {
        validTokens.add(i);
      }
    }

    return validTokens;
  }

  /// Check if player gets another turn (rolled 6)
  static bool getAnotherTurn(int diceValue) {
    return diceValue == 6;
  }

  /// Calculate points from position
  static int getDistanceFromHome(int position, int playerIndex) {
    if (position == -1) return 0;
    if (position >= BOARD_SQUARES + HOME_STRETCH) {
      return BOARD_SQUARES + HOME_STRETCH;
    }
    return position;
  }

  /// Get player's custom board path
  static List<int> getPlayerPath(int playerIndex) {
    return playerPaths[playerIndex] ?? [];
  }

  /// Check if move is valid based on Ludo rules
  static bool isValidMove(
    int tokenIndex,
    int currentPosition,
    int diceValue,
    List<int> tokenPositions,
    int playerIndex,
  ) {
    // Token must exist
    if (tokenIndex < 0 || tokenIndex >= tokenPositions.length) {
      return false;
    }

    int tokenPos = tokenPositions[tokenIndex];

    // Home token needs 6
    if (tokenPos == -1) {
      return diceValue == 6;
    }

    // Token on board
    if (tokenPos >= 0 && tokenPos < BOARD_SQUARES + HOME_STRETCH) {
      int newPos = tokenPos + diceValue;
      return newPos <= BOARD_SQUARES + HOME_STRETCH;
    }

    return false;
  }

  /// Calculate winner based on token positions
  static int? getWinner(Map<String, List<int>> tokenPositions) {
    for (var entry in tokenPositions.entries) {
      if (entry.value.every((pos) => pos >= BOARD_SQUARES + HOME_STRETCH)) {
        return 0; // Return player index if needed
      }
    }
    return null;
  }
}
