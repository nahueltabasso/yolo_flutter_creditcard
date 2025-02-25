import 'package:flutter_yolo_creditcard/presentation/screens/home_screen.dart';
import 'package:flutter_yolo_creditcard/presentation/screens/result_screen.dart';
import 'package:go_router/go_router.dart';

final appRouter = GoRouter(
  routes: [
    GoRoute(path: HomeScreen.routeName, builder: (context, state) => HomeScreen()),
    GoRoute(path: ResultScreen.routeName, builder: (context, state) => const ResultScreen()),
  ]
);