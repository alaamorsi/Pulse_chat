import 'package:flutter/material.dart';
import 'package:talk_up/layout/cubit/cubit.dart';
import 'package:talk_up/layout/cubit/states.dart';
import 'package:talk_up/layout/home_screen.dart';
import 'package:talk_up/modules/authentication/Login_screen.dart';
import 'package:talk_up/modules/personal_information/personal_information_screen.dart';
import 'package:talk_up/shared/cache_helper.dart';
import 'package:talk_up/shared/components.dart';
import 'package:talk_up/shared/constant.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool isLoading = false;

  @override
  Widget build(BuildContext context) {
    ThemeData theme = Theme.of(context);
    return BlocConsumer<AppCubit,AppStates>(
      listener: (context, state) {},
      builder: (context, state) {
        return WillPopScope(
          onWillPop: () async {
            navigateAndFinish(context, const HomeScreen());
            return true;
          },
          child: Scaffold(
            appBar: defaultAppBar(
                arrowBackFunction: () {
                  navigateAndFinish(context, const HomeScreen());
                },
                theme: theme,
                title: 'Settings'),
            body: Container(
              width: double.infinity,
              height: double.infinity,
              color: theme.scaffoldBackgroundColor,
              padding: const EdgeInsets.all(15.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ElevatedButton(
                    style: ButtonStyle(
                        shape: WidgetStateProperty.all(RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15.0))),
                        elevation: WidgetStateProperty.all(0.0),
                        backgroundColor:
                            WidgetStateProperty.all(theme.canvasColor),
                        fixedSize:
                            WidgetStateProperty.all(const Size.fromHeight(70.0))),
                    onPressed: () {
                      AppCubit.get(context).getUserData();
                      navigateTo(context, const PersonalInformationScreen());
                    },
                    child: Row(
                      children: [
                        Text(
                          'Personal Information',
                          style: TextStyle(
                              fontSize: 21.0,
                              fontWeight: FontWeight.bold,
                              color: theme.primaryColor),
                        ),
                        const Spacer(),
                        Icon(
                          Icons.person,
                          size: 35.0,
                          color: theme.primaryColor,
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(
                    height: 15.0,
                  ),
                  ElevatedButton(
                    style: ButtonStyle(
                        shape: WidgetStateProperty.all(RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15.0))),
                        elevation: WidgetStateProperty.all(0.0),
                        backgroundColor:
                            WidgetStateProperty.all(theme.canvasColor),
                        fixedSize:
                            WidgetStateProperty.all(const Size.fromHeight(70.0))),
                    onPressed: () {
                    },
                    child: Row(
                      children: [
                        Text(
                          'Dark mode',
                          style: TextStyle(
                              fontSize: 21.0,
                              fontWeight: FontWeight.bold,
                              color: theme.primaryColor),
                        ),
                        const Spacer(),
                        Switch(
                          value: AppCubit.get(context).isDark,
                          onChanged: (value) {
                            AppCubit.get(context).changeMode(value);
                          },
                          thumbIcon: WidgetStateProperty.all(
                            const Icon(
                              Icons.dark_mode,
                              color: Colors.black87,
                            ),
                          ),
                          thumbColor: WidgetStateProperty.all(Colors.white),
                          activeTrackColor: Colors.black87,
                          inactiveTrackColor: Colors.grey[300],
                          overlayColor: WidgetStateProperty.all(Colors.black87),
                        )
                      ],
                    ),
                  ),
                  const SizedBox(
                    height: 15.0,
                  ),
                  ElevatedButton(
                    style: ButtonStyle(
                      shape: WidgetStateProperty.all(
                        RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15.0),
                        ),
                      ),
                      elevation: WidgetStateProperty.all(0.0),
                      backgroundColor: WidgetStateProperty.all(
                        theme.canvasColor, // Apply the selected color here
                      ),
                      fixedSize: WidgetStateProperty.all(const Size.fromHeight(70.0)),
                    ),
                    onPressed: () {
                    },
                    child: Row(
                      children: [
                        Text(
                          'Theme',
                          style: TextStyle(
                            fontSize: 21.0,
                            fontWeight: FontWeight.bold,
                            color: theme.primaryColor,
                          ),
                        ),
                        const Spacer(),
                        DropdownButton<String>(
                          value: AppCubit.get(context).canvasColor,
                          style: TextStyle(
                            color: theme.primaryColor,
                            fontSize: 16.0,
                          ),
                          onChanged: (String? newValue) {
                            AppCubit.get(context).changeTheme(newValue);
                          },
                          icon: Icon(Icons.arrow_drop_down, size: 30.0, color: theme.primaryColor),
                          items: AppCubit.get(context)
                              .canvasColors
                              .keys
                              .map<DropdownMenuItem<String>>((String key) {
                            return DropdownMenuItem<String>(
                              value: key,
                              child: Text(
                                key,
                                style: const TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold),
                              ),
                            );
                          }).toList(),
                        ),

                      ],
                    ),
                  ),
                  const SizedBox(
                    height: 15.0,
                  ),
                  ElevatedButton(
                    style: ButtonStyle(
                        shape: WidgetStateProperty.all(RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15.0))),
                        elevation: WidgetStateProperty.all(0.0),
                        backgroundColor:
                        WidgetStateProperty.all(Colors.red),
                        fixedSize:
                        WidgetStateProperty.all(const Size.fromHeight(70.0))),
                    onPressed: () async {
                      setState(() {
                        isLoading = true;
                      });
                      CacheHelper.removeData(key: 'uId');
                      uId = '';
                      AppCubit.get(context).usersList = [];
                      await FirebaseAuth.instance.signOut();
                      await GoogleSignIn().signOut();
                      navigateAndFinish(context, LoginScreen());
                      setState(() {
                        isLoading = false;
                      });
                    },
                    child: isLoading
                        ? Center(
                        child: CircularProgressIndicator(
                          color: theme.primaryColor,
                        ))
                        : Row(
                      children: [
                        Text(
                          'Sign out',
                          style: TextStyle(
                              fontSize: 21.0,
                              fontWeight: FontWeight.bold,
                              color: theme.primaryColor),
                        ),
                        const Spacer(),
                        Icon(
                          Icons.logout_outlined,
                          size: 35.0,
                          color: theme.primaryColor,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
