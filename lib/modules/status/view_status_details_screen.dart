import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:talk_up/layout/cubit/cubit.dart';
import 'package:talk_up/layout/cubit/states.dart';
import 'package:talk_up/layout/home_screen.dart';
import 'package:talk_up/model/status_model.dart';
import 'package:talk_up/shared/components.dart';

class ViewStatusDetailsScreen extends StatefulWidget {
  final List<StatusModel> statuesList;

  const ViewStatusDetailsScreen({super.key, required this.statuesList});

  @override
  _ViewStatusDetailsScreenState createState() =>
      _ViewStatusDetailsScreenState();
}

class _ViewStatusDetailsScreenState extends State<ViewStatusDetailsScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  late Timer _timer;
  double _progress = 0.0;
  final Duration duration = const Duration(seconds: 10); // 30 seconds per status
  bool _isPaused = false;

  @override
  void initState() {
    super.initState();
    startTimer();
  }

  void startTimer() {
    _timer = Timer.periodic(const Duration(milliseconds: 100), (Timer timer) {
      if (!_isPaused) {
        setState(() {
          _progress +=
              0.01; // Increment progress for 10 seconds (100 ms * 100 = 10,000 ms = 10 seconds)
          if (_progress >= 1.0) {
            _progress = 0.0;
            if (_currentPage < widget.statuesList.length - 1) {
              _currentPage++;
              _pageController.animateToPage(
                _currentPage,
                duration: const Duration(milliseconds: 500),
                curve: Curves.easeInOut,
              );
            } else {
              // If last page and progress is completed, navigate to HomeScreen
              _timer.cancel();
              navigateAndFinish(context, const HomeScreen());
            }
          }
        });
      }
    });
  }

  void pauseTimer() {
    setState(() {
      _isPaused = true;
    });
  }

  void resumeTimer() {
    setState(() {
      _isPaused = false;
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AppCubit, AppStates>(
      listener: (context, state) {},
      builder: (context, state) {
        return WillPopScope(
          onWillPop: () async {
            navigateAndFinish(context, const HomeScreen());
            return true;
          },
          child: Scaffold(
            body: Stack(
              children: [
                GestureDetector(
                  onTapDown: (_) => pauseTimer(),
                  onTapUp: (_) => resumeTimer(),
                  onTapCancel: () => resumeTimer(),
                  child: PageView.builder(
                    controller: _pageController,
                    onPageChanged: (int index) {
                      setState(() {
                        _currentPage = index;
                        _progress =
                            0.0; // Reset progress when manually scrolling
                      });
                    },
                    itemCount: widget.statuesList.length,
                    itemBuilder: (context, index) {
                      return buildStatusItem(
                          widget.statuesList[index], context);
                    },
                  ),
                ),
                Positioned(
                  top: 40,
                  left: 10,
                  right: 10,
                  child: Row(
                    children: List.generate(
                      widget.statuesList.length,
                      (index) => Expanded(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 2.0),
                          child: LinearProgressIndicator(
                            value: index == _currentPage
                                ? _progress
                                : (index < _currentPage ? 1 : 0),
                            backgroundColor:
                                Theme.of(context).primaryColor,
                            color: Theme.of(context).canvasColor,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget buildStatusItem(StatusModel status, context) {
    return Container(
      color: status.isMediaStatus
          ? Theme.of(context).scaffoldBackgroundColor
          : status.color,
      width: double.infinity,
      height: double.infinity,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Fixed row at the top (Back button, avatar, user name, timestamp)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 50.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                IconButton(
                  onPressed: () {
                    navigateAndFinish(context, const HomeScreen());
                  },
                  icon: Icon(
                    Icons.arrow_back,
                    size: 30,
                    color: Theme.of(context).primaryColor,
                  ),
                ),
                CircleAvatar(
                  radius: 27.0,
                  backgroundColor: Theme.of(context).canvasColor,
                  child: status.status.isEmpty
                      ? Icon(
                          Icons.person,
                          size: 40.0,
                          color: Theme.of(context).canvasColor,
                        )
                      : Container(
                          width: 50.0,
                          height: 50.0,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            image: DecorationImage(
                              image: NetworkImage(status.image),
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                ),
                const SizedBox(width: 10.0),
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      status.name,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 21.0,
                        color: Theme.of(context).primaryColor,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      formatTime(status.time),
                      style: TextStyle(
                        fontSize: 16.0,
                        color: Theme.of(context).primaryColor,
                      ),
                    ),
                  ],
                ),
                const Spacer(),
              ],
            ),
          ),
          // Expanded area for status content
          status.isMediaStatus
              ? Expanded(
                  child: Center(
                    child: SingleChildScrollView(
                      child: Column(
                        children: [
                          Container(
                            width: double.infinity,
                            height: MediaQuery.of(context).size.height / 3 * 2,
                            decoration: BoxDecoration(
                              image: DecorationImage(
                                image: NetworkImage(status.status),
                                fit: BoxFit.contain,
                              ),
                            ),
                          ),
                          const SizedBox(height: 10.0),
                          Text(
                            status.descriptionMediaStatus,
                            style: TextStyle(
                              fontSize: 21.0,
                              fontWeight: FontWeight.bold,
                              color: Theme.of(context).secondaryHeaderColor,
                            ),
                          ),
                          const SizedBox(height: 10.0),
                        ],
                      ),
                    ),
                  ),
                )
              : Expanded(
                  child: Center(
                    child: SingleChildScrollView(
                      child: Text(
                        status.status,
                        style: TextStyle(
                          fontSize: 21.0,
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).primaryColor,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                ),
        ],
      ),
    );
  }
}
