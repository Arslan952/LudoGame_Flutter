import 'package:flutter/material.dart';
import '../../screens/auth/login_screen.dart';
import '../../screens/auth/signup_screen.dart';
import '../../screens/game/game_board_screen.dart';
import '../../screens/lobby/lobby_screen.dart';
import '../../screens/profile/profile_screen.dart';
import '../../screens/splashScreen/splashScreen.dart';
import '../../screens/tournament/create_tournament_screen.dart';


class AppRoutes {
  static const String splash = '/splash';
  static const String login = '/login';
  static const String signup = '/signup';
  static const String lobby = '/lobby';
  static const String gameBoard = '/game-board';
  static const String tournaments = '/tournaments';
  static const String createTournament = '/create-tournament';
  static const String profile = '/profile';
  static const String leaderboard = '/leaderboard';

  static final Map<String, WidgetBuilder> routes = {
    splash: (context) => const SplashScreen(),
    login: (context) => const LoginScreen(),
    signup: (context) => const SignupScreen(),
    lobby: (context) => const LobbyScreen(),
    gameBoard: (context) => const GameBoardScreen(),
    // tournaments: (context) => const TournamentListScreen(),
    createTournament: (context) => const CreateTournamentScreen(),
    profile: (context) => const ProfileScreen(),
    // leaderboard: (context) => const LeaderboardScreen(),
  };
}