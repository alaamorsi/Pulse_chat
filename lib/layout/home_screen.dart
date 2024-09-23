import 'package:flutter/material.dart';
import 'package:talk_up/layout/cubit/cubit.dart';
import 'package:talk_up/layout/cubit/states.dart';
import 'package:talk_up/modules/settings_screen.dart';
import 'package:talk_up/shared/components.dart';
import 'package:salomon_bottom_bar/salomon_bottom_bar.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  TextEditingController searchController = TextEditingController();
  bool isSearching = false;

  @override
  Widget build(BuildContext context) {
    ThemeData theme = Theme.of(context);
    AppCubit cubit = AppCubit.get(context);
    return BlocConsumer<AppCubit, AppStates>(
      listener: (context, state) {},
      builder: (context, state) {
        return Scaffold(
          appBar: buildCustomAppBar(
            theme: theme,
            isSearching: isSearching,
            searchController: searchController,
            startSearch: () {
              setState(() {
                isSearching = true;
              });
            },
            stopSearch: () {
              setState(() {
                isSearching = false;
                AppCubit.get(context).getUsers();
              });
            },
            iconButtonOnPressed: () {
              navigateTo(context, const SettingsScreen());
            }, context: context,
          ),
          body: cubit.screens[cubit.currentIndex],
          bottomNavigationBar: Container(
            decoration: BoxDecoration(
                border: BorderDirectional(
                    top: BorderSide(
                        width: 1.0, color: theme.secondaryHeaderColor))),
            child: SalomonBottomBar(
              backgroundColor: theme.scaffoldBackgroundColor,
              currentIndex: cubit.currentIndex,
              onTap: (index) => cubit.changeBottomNav(index),
              items: [
                SalomonBottomBarItem(
                  icon: Icon(
                    Icons.chat_outlined,
                    color: theme.canvasColor,
                    size: 35.0,
                  ),
                  title: Text(
                    "Chats",
                    style: TextStyle(
                        color: theme.secondaryHeaderColor,
                        fontSize: 18.0,
                        fontWeight: FontWeight.bold),
                  ),
                  selectedColor: theme.canvasColor,
                ),
                SalomonBottomBarItem(
                  icon: Icon(
                    Icons.donut_large,
                    color: theme.canvasColor,
                    size: 35.0,
                  ),
                  title: Text(
                    "Status",
                    style: TextStyle(
                        color: theme.secondaryHeaderColor,
                        fontSize: 18.0,
                        fontWeight: FontWeight.bold),
                  ),
                  selectedColor: theme.canvasColor,
                ),
                // SalomonBottomBarItem(
                //   icon: Icon(
                //     Icons.call,
                //     color: theme.secondaryHeaderColor,
                //     size: 35.0,
                //   ),
                //   title: Text(
                //     "Calls",
                //     style: TextStyle(
                //         color: theme.secondaryHeaderColor,
                //         fontSize: 18.0,
                //         fontWeight: FontWeight.bold),
                //   ),
                //   selectedColor: theme.secondaryHeaderColor,
                // ),
              ],
            ),
          ),
        );
      },
    );
  }
}
