import 'dart:async';
import 'package:flutter/material.dart';
import 'package:talk_up/layout/cubit/cubit.dart';
import 'package:talk_up/layout/home_screen.dart';
import 'package:talk_up/modules/authentication/Login_screen.dart';
import 'package:talk_up/modules/authentication/cubit/cubit.dart';
import 'package:talk_up/modules/authentication/cubit/states.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:talk_up/shared/components.dart';
import 'package:talk_up/shared/constant.dart';

class OpeningScreen extends StatefulWidget {
  const OpeningScreen({super.key});

  @override
  State<OpeningScreen> createState() => _OpeningScreenState();
}

class _OpeningScreenState extends State<OpeningScreen> {
  double logoOpacity = 0;
  double scale = 0.8;
  double t1 = 100;

  @override
  void initState() {
    super.initState();
    Timer(const Duration(milliseconds: 50), () {
      setState(() {
        logoOpacity = 1;
        scale = 1;
      });
    });
    Future.delayed(const Duration(seconds: 6)).then((value) async {
      if (uId != null && uId != '') {
        await AppCubit.get(context).getUsers();
        navigateAndFinish(context, const HomeScreen());
      } else {
        navigateAndFinish(context, LoginScreen());
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    ThemeData theme = Theme.of(context);
    return BlocConsumer<AuthenticationCubit, AuthenticationStates>(
      listener: (context, state) {},
      builder: (context, state) {
        return Scaffold(
          body: Container(
            width: double.infinity,
            height: double.infinity,
            color: theme.scaffoldBackgroundColor,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                AnimatedOpacity(
                  duration: const Duration(seconds: 1),
                  opacity: logoOpacity,
                  child: AnimatedScale(
                    scale: scale,
                    duration: const Duration(seconds: 1),
                    child: Image(
                      image: AppCubit.get(context).isDark
                          ? const AssetImage("assets/images/white.png")
                          : const AssetImage("assets/images/black.png"),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                const SizedBox(
                  height: 20,
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
