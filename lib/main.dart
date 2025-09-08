import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:path_provider/path_provider.dart';

import 'feature/home/cubit/issues_cubit.dart';
import 'feature/home/screen/home.dart';
import 'core/state/settings_state.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SettingsCubit.setDataDir(await getTemporaryDirectory());
  runApp(
    MultiBlocProvider(
      providers: [
        BlocProvider(create: (context) => SettingsCubit()),
        BlocProvider(create: (context) => ComicIssuesCubit()),
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
