import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_yolo_creditcard/config/routes/app_router.dart';
import 'package:flutter_yolo_creditcard/config/theme/app_theme.dart';
import 'package:flutter_yolo_creditcard/presentation/blocs/yolo_process/yolo_process_bloc.dart';
import 'package:flutter_yolo_creditcard/services/api_service.dart';
import 'package:provider/provider.dart';

void main() => runApp(AppState());


class AppState extends StatelessWidget {
    @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => ApiService()),
        BlocProvider(create: (context) => YoloProcessBloc(apiService: context.read<ApiService>())),
      ],
      child: const MyApp(),
    );
  }

}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Material App',
      debugShowCheckedModeBanner: false,
      theme: AppTheme().getTheme(),
      routerConfig: appRouter,
    );
  }
}