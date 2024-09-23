import 'package:flutter/material.dart';
import 'package:talk_up/layout/cubit/cubit.dart';
import 'package:talk_up/layout/cubit/states.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:talk_up/modules/authentication/cubit/cubit.dart';
import 'package:talk_up/modules/opening_screen.dart';
import 'package:talk_up/shared/app_theme.dart';
import 'package:talk_up/shared/bloc_observer.dart';
import 'package:talk_up/shared/cache_helper.dart';
import 'package:talk_up/shared/constant.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  Bloc.observer = MyBlocObserver();
  await CacheHelper.init();
  uId = CacheHelper.getData(key: 'uId');
  isDark = CacheHelper.getData(key: 'isDark') ?? false;
  canvasColorConstant = CacheHelper.getColor(key: 'canvasColor') ?? Colors.blue;
  runApp(MyApp(
    isDark: isDark,
    canvasColor: canvasColorConstant,
  ));
}

class MyApp extends StatelessWidget {
  final bool? isDark;
  final Color? canvasColor;

  const MyApp({super.key, this.isDark, this.canvasColor});

  @override
  Widget build(BuildContext context) {
    screenWidth = MediaQuery.of(context).size.width;
    screenHeight = MediaQuery.of(context).size.height;
    return MultiBlocProvider(
      providers: [
        BlocProvider(
            create: (context) => AppCubit()
              ..getUserData()
              ..getUsers()),
        BlocProvider(create: (context) => AuthenticationCubit()),
      ],
      child: BlocConsumer<AppCubit, AppStates>(
        listener: (context, state) {},
        builder: (context, state) {
          return MaterialApp(
            debugShowCheckedModeBanner: false,
            theme: AppTheme.lightTheme(canvasColorConstant!),
            darkTheme: AppTheme.darkTheme(canvasColorConstant!),
            themeMode:
                AppCubit.get(context).isDark ? ThemeMode.dark : ThemeMode.light,
            home: const OpeningScreen(),
          );
        },
      ),
    );
  }
}
