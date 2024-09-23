import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:talk_up/layout/cubit/cubit.dart';

PreferredSizeWidget buildCustomAppBar({
  required ThemeData theme,
  required bool isSearching,
  required TextEditingController searchController,
  required VoidCallback startSearch,
  required VoidCallback stopSearch,
  required void Function()? iconButtonOnPressed,
  required BuildContext context,
}) {
  return PreferredSize(
    preferredSize: const Size.fromHeight(kToolbarHeight),
    child: isSearching
        ? AppBar(
            key: const ValueKey('searchAppBar'),
            leading: IconButton(
              icon: Icon(Icons.arrow_back, color: theme.canvasColor),
              onPressed: stopSearch,
            ),
            title: TextFormField(
              textInputAction: TextInputAction.search,
              style: TextStyle(color: theme.secondaryHeaderColor),
              controller: searchController,
              validator: (String? value) {
                if (value!.isNotEmpty) {
                  AppCubit.get(context).searchAbout(
                      isSearchAboutUsers: true,
                      searchQuery: searchController.text);
                }
                return;
              },
              onChanged: (String? value) {
                if (value!.isNotEmpty) {
                  AppCubit.get(context).searchAbout(
                      isSearchAboutUsers: true,
                      searchQuery: searchController.text);
                }
                return;
              },
              autofocus: true,
              cursorColor: theme.secondaryHeaderColor,
              decoration: InputDecoration(
                hintText: 'Search...',
                border: InputBorder.none,
                hintStyle: TextStyle(color: theme.secondaryHeaderColor),
              ),
            ),
            backgroundColor: theme.scaffoldBackgroundColor,
            elevation: 0.0,
            bottom: PreferredSize(
              preferredSize: const Size.fromHeight(2.0),
              child: Container(
                color: theme.secondaryHeaderColor,
                height: 1.0,
              ),
            ),
          )
        : AppBar(
            key: const ValueKey('defaultAppBar'),
            title: Text(
              'Pulse',
              style:
                  TextStyle(color: theme.canvasColor, fontSize: 27.0,fontWeight: FontWeight.w900),
            ),
            backgroundColor: theme.scaffoldBackgroundColor,
            elevation: 0.0,
            bottom: PreferredSize(
              preferredSize: const Size.fromHeight(2.0),
              child: Container(
                color: theme.secondaryHeaderColor,
                height: 1.0,
              ),
            ),
            actions: [
              if(AppCubit.get(context).currentIndex == 0)
              IconButton(
                onPressed: startSearch,
                icon: Icon(Icons.search,
                    color: theme.canvasColor, size: 30.0),
              ),
              IconButton(
                  onPressed: iconButtonOnPressed,
                  icon: Icon(
                    Icons.settings,
                    size: 30.0,
                    color: theme.canvasColor,
                  )),
            ],
          ),
  );
}

PreferredSizeWidget defaultAppBar({
  required ThemeData theme,
  required String title,
  Widget moreFunction = const SizedBox(),
  bool isChat = false,
  String image = '',
  required void Function()? arrowBackFunction,
}) {
  return PreferredSize(
    preferredSize: const Size.fromHeight(kToolbarHeight),
    child: AppBar(
      leading: IconButton(
        onPressed: arrowBackFunction,
        icon: Icon(
          Icons.arrow_back,
          color: theme.secondaryHeaderColor,
        ),
      ),
      automaticallyImplyLeading: false,
      key: const ValueKey('defaultAppBar'),
      title: Row(
        children: [
          if (isChat)
            Container(
              width: 55.0,
              height: 55.0,
              decoration: BoxDecoration(
                  shape: BoxShape.circle, color: theme.canvasColor),
              child: Container(
                width: 40.0,
                height: 40.0,
                margin: const EdgeInsets.all(3.0),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  image: image != ''
                      ? DecorationImage(
                          image: NetworkImage(image), fit: BoxFit.cover)
                      : null,
                ),
                child: image == ''
                    ? Icon(
                        Icons.person,
                        size: 50.0,
                        color: theme.secondaryHeaderColor,
                      )
                    : null,
              ),
            )
          else
            const SizedBox(),
          const Spacer(),
          Text(
            title,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(color: theme.secondaryHeaderColor, fontSize: 16.0,fontWeight: FontWeight.bold),
          ),
        ],
      ),
      backgroundColor: theme.scaffoldBackgroundColor,
      elevation: 0.0,
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(2.0),
        child: Container(
          color: theme.secondaryHeaderColor,
          height: 1.0,
        ),
      ),
      actions: [
        moreFunction,
      ],
    ),
  );
}

void navigateTo(context, widget) => Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => widget,
      ),
    );

void navigateAndFinish(context, widget) => Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(
        builder: (context) => widget,
      ),
      (Route<dynamic> rout) => false,
    );

void showToast({
  required String text,
  required ToastStates state,
}) async =>
    Fluttertoast.showToast(
      msg: text,
      toastLength: Toast.LENGTH_LONG,
      gravity: ToastGravity.BOTTOM,
      timeInSecForIosWeb: 5,
      backgroundColor: chooseToastColor(state),
      textColor: Colors.white,
      fontSize: 16.0,
    );

// enum
enum ToastStates { SUCCESS, ERROR, WARNING }

Color chooseToastColor(ToastStates state) {
  Color color;

  switch (state) {
    case ToastStates.SUCCESS:
      color = Colors.green;
      break;
    case ToastStates.ERROR:
      color = Colors.red;
      break;
    case ToastStates.WARNING:
      color = Colors.amber;
      break;
  }

  return color;
}

String formatTime(Timestamp? timestamp) {
  if (timestamp == null) return '';

  try {
    DateTime dateTime = timestamp.toDate(); // Convert Timestamp to DateTime
    DateTime now = DateTime.now();
    Duration difference = now.difference(dateTime);

    if (difference.inDays == 0) {
      // Status added today
      return 'Today, ${DateFormat('h:mm a').format(dateTime)}';
    } else if (difference.inDays == 1) {
      // Status added yesterday
      return 'Yesterday, ${DateFormat('h:mm a').format(dateTime)}';
    } else if (difference.inDays < 7) {
      // Status added within the past week
      return DateFormat('EEEE, h:mm a').format(dateTime); // e.g. "Monday, 7:00 PM"
    } else {
      // Status added more than a week ago
      return DateFormat('MMM d, yyyy, h:mm a')
          .format(dateTime); // e.g. "Aug 30, 2023, 7:00 PM"
    }
  } catch (e) {
    return '';
  }
}
