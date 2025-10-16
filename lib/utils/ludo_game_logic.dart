class LudoGameLogic {
  static const int TOTAL_SQUARES = 52;
  static const int HOME_SQUARES = 6;
  static const List<int> SAFE_ZONES = [0, 8, 13, 21, 26, 34, 39, 47, 52];

  static bool canMoveToken(
      int currentPosition,
      int diceValue,
      bool isAtHome,
      List<int> allTokenPositions,
      int playerIndex,
      ) {
    if (isAtHome && diceValue != 6) {
      return false;
    }

    int newPosition = currentPosition + diceValue;

    if (newPosition > TOTAL_SQUARES + HOME_SQUARES) {
      return false;
    }

    return true;
  }

  static int calculateNewPosition(int currentPos, int diceValue) {
    return currentPos + diceValue;
  }

  static bool isSafeZone(int position) {
    return SAFE_ZONES.contains(position);
  }

  static bool isFinished(int position) {
    return position >= TOTAL_SQUARES + HOME_SQUARES;
  }

  static List<int> getCapturable(
      int newPosition,
      List<int> opponentTokens,
      int playerIndex,
      ) {
    if (isSafeZone(newPosition)) {
      return [];
    }

    return opponentTokens.where((pos) => pos == newPosition).toList();
  }

  static bool allTokensFinished(List<int> tokenPositions) {
    return tokenPositions.every((pos) => pos >= TOTAL_SQUARES + HOME_SQUARES);
  }

  static List<int> getValidMoves(
      List<int> playerTokens,
      int diceValue,
      List<List<int>> allPlayersTokens,
      ) {
    List<int> validMoves = [];

    for (int i = 0; i < playerTokens.length; i++) {
      int currentPos = playerTokens[i];

      if (currentPos < 0) continue;

      int newPos = currentPos + diceValue;

      if (newPos <= TOTAL_SQUARES + HOME_SQUARES) {
        validMoves.add(i);
      }
    }

    return validMoves;
  }

  static int calculateWinnings(
      int entryFee,
      int numPlayers,
      int ranking,
      ) {
    int totalPool = entryFee * numPlayers;

    switch (numPlayers) {
      case 2:
        return ranking == 1 ? (totalPool * 90) ~/ 100 : 0;
      case 3:
        return ranking == 1
            ? (totalPool * 50) ~/ 100
            : ranking == 2
            ? (totalPool * 30) ~/ 100
            : (totalPool * 20) ~/ 100;
      case 4:
        return ranking == 1
            ? (totalPool * 40) ~/ 100
            : ranking == 2
            ? (totalPool * 30) ~/ 100
            : ranking == 3
            ? (totalPool * 20) ~/ 100
            : (totalPool * 10) ~/ 100;
      default:
        return 0;
    }
  }
}