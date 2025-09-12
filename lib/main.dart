import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'feature/home/cubit/issues_cubit.dart';
import 'feature/home/screen/home.dart';
import 'feature/settings/cubit/settings_cubit.dart';
import 'feature/settings/service/firebase_service.dart';
import 'feature/settings/service/storage_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await FirebaseService.init();
  await StorageService.init();
  final settingsCubit = SettingsCubit();
  runApp(
    MultiBlocProvider(
      providers: [
        BlocProvider.value(value: settingsCubit),
        BlocProvider(create: (context) => ComicIssuesCubit(settingsCubit)),
        BlocProvider.value(value: FirebaseService.instance.errorHandler),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.deepPurple,
          brightness: Brightness.dark,
        ),
      ),
      home: const HomePage(),
    );
  }
}
