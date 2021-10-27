import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:path/path.dart';
// import 'package:sqflite/sqflite.dart';

import 'theme/theme_cubit.dart';
import 'utils/database_provider.dart';
import 'utils/shared_preferences_provider.dart';
import 'views/create_page/create_page.dart';
import 'views/create_page/create_page_cubit.dart';
import 'views/events/events.dart';
import 'views/events/events_cubit.dart';
import 'views/home/home.dart';
import 'views/home/home_cubit.dart';
import 'views/settings/settings.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // await deleteDatabase(join(await getDatabasesPath(), 'chat_database.db'));
  await SharedPreferencesProvider.init();
  await DatabaseProvider.init();
  return runApp(MyApp());
}

class MyApp extends StatelessWidget {
  static const String _title = 'WTF Chat Journal';

  MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<ThemeCubit>(create: (_) => ThemeCubit()),
        BlocProvider<HomeCubit>(create: (_) => HomeCubit()),
        BlocProvider<CreatePageCubit>(create: (_) => CreatePageCubit()),
        BlocProvider<EventsCubit>(create: (_) => EventsCubit()),
      ],
      child: BlocBuilder<ThemeCubit, ThemeData>(
        builder: (context, state) {
          return MaterialApp(
            title: _title,
            home: HomeScreen(),
            routes: {
              '/events-screen': (context) => EventsScreen(),
              '/create-screen': (context) => CreatePageScreen(),
              '/settings-screen': (context) => SettingsScreen(),
            },
            theme: state,
          );
        },
      ),
    );
  }
}
